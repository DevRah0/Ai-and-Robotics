import Foundation
import CoreLocation
import Combine

final class AppModel: ObservableObject {
    @Published var places: [SavedPlace] {
        didSet { persistPlaces() }
    }
    @Published var records: [TestRecord] {
        didSet { persistRecords() }
    }
    @Published var routes: [SavedRoute] { didSet { Self.save(routes, key: "routes") } }
    @Published var history: [SelectionHistoryEntry] { didSet { Self.save(history, key: "history") } }
    @Published var routeDraft: [RouteWaypoint] = []
    @Published private(set) var activeRoute: SavedRoute?
    @Published private(set) var routePlaying = false
    @Published private(set) var routeFraction = 0.0
    private var routeTimer: Timer?
    private var traveledMeters = 0.0
    @Published var selectedCoordinate = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)
    @Published var selectedTitle = "المسجد الحرام"
    @Published var selectedSubtitle = "مكة المكرمة، السعودية"
    @Published var previewCoordinate: CLLocationCoordinate2D?
    @Published var movement: MovementMode = .fixed
    @Published var presentation: MapPresentation = .standard
    @Published var altitude = 35.0
    @Published var modeledAccuracy = 5.0
    @Published var radius = 100.0
    @Published var rejectSimulated = true
    @Published var smoothMovement = true
    @Published var show3D = false
    @Published var centerSerial = 0

    init() {
        places = Self.load([SavedPlace].self, key: "saved_places") ?? SavedPlace.presets
        records = Self.load([TestRecord].self, key: "test_records") ?? []
        routes = Self.load([SavedRoute].self, key: "routes") ?? []
        history = Self.load([SelectionHistoryEntry].self, key: "history") ?? []
    }

    var previewIsOn: Bool { previewCoordinate != nil }

    func choose(_ coordinate: CLLocationCoordinate2D, name: String = "موقع محدد", subtitle: String = "نقطة مختارة على الخريطة") {
        selectedCoordinate = coordinate
        selectedTitle = name
        selectedSubtitle = subtitle
        centerSerial += 1
        if let prior = history.first, prior.name == name,
           abs(prior.latitude - coordinate.latitude) < 0.00001,
           abs(prior.longitude - coordinate.longitude) < 0.00001 { return }
        history.insert(.init(name: name, latitude: coordinate.latitude, longitude: coordinate.longitude), at: 0)
        if history.count > 75 { history = Array(history.prefix(75)) }
    }

    func choose(_ place: SavedPlace) {
        choose(place.coordinate, name: place.name, subtitle: place.subtitle)
    }

    func togglePreview() {
        if previewIsOn {
            stopRoutePreview()
            previewCoordinate = nil
        } else {
            previewCoordinate = selectedCoordinate
        }
    }

    func movePreview(bearingDegrees: Double) {
        guard let previous = previewCoordinate, movement != .fixed else { return }
        let distance = movement.stepMeters
        let bearing = bearingDegrees * .pi / 180
        let latitudeRadians = previous.latitude * .pi / 180
        let deltaLat = cos(bearing) * distance / 111_111
        let deltaLon = sin(bearing) * distance / max(1, 111_111 * cos(latitudeRadians))
        previewCoordinate = .init(latitude: max(-89.9, min(89.9, previous.latitude + deltaLat)),
                                  longitude: previous.longitude + deltaLon)
        centerSerial += 1
    }

    func appendCurrentWaypoint() {
        routeDraft.append(.init(latitude: selectedCoordinate.latitude, longitude: selectedCoordinate.longitude))
    }

    func saveRoute(name: String) {
        guard routeDraft.count >= 2 else { return }
        let cleaned = String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(80))
        guard !cleaned.isEmpty else { return }
        routes.insert(SavedRoute(name: cleaned, waypoints: routeDraft), at: 0)
        routeDraft.removeAll()
    }

    func importRoute(_ route: SavedRoute) {
        guard route.waypoints.count >= 2 else { return }
        routes.insert(route, at: 0)
    }

    func deleteRoute(id: UUID) {
        if activeRoute?.id == id { stopRoutePreview() }
        routes.removeAll { $0.id == id }
    }

    func startRoutePreview(_ route: SavedRoute) {
        guard route.waypoints.count >= 2 else { return }
        stopRoutePreview()
        activeRoute = route
        routePlaying = true
        routeFraction = 0
        traveledMeters = 0
        previewCoordinate = route.waypoints[0].coordinate
        centerSerial += 1
        routeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tickRoute()
        }
    }

    func stopRoutePreview() {
        routeTimer?.invalidate()
        routeTimer = nil
        routePlaying = false
    }

    private func tickRoute() {
        guard let route = activeRoute, routePlaying else { return }
        let total = route.lengthMeters
        guard total > 0 else { stopRoutePreview(); return }
        // Speed is educational only; no CoreLocation values are modified.
        let metersPerSecond: Double
        switch movement {
        case .fixed: metersPerSecond = 1.4
        case .walking: metersPerSecond = 1.4
        case .cycling: metersPerSecond = 5
        case .driving: metersPerSecond = 14
        case .flight: metersPerSecond = 100
        }
        traveledMeters = min(total, traveledMeters + metersPerSecond)
        routeFraction = traveledMeters / total
        var remainder = traveledMeters
        for (start, end) in zip(route.waypoints, route.waypoints.dropFirst()) {
            let segment = CLLocation(latitude: start.latitude, longitude: start.longitude)
                .distance(from: CLLocation(latitude: end.latitude, longitude: end.longitude))
            if remainder <= segment && segment > 0 {
                previewCoordinate = RouteMath.interpolate(start.coordinate, end.coordinate, fraction: remainder / segment)
                centerSerial += 1
                break
            }
            remainder -= segment
        }
        if traveledMeters >= total {
            previewCoordinate = route.waypoints.last?.coordinate
            stopRoutePreview()
        }
    }

    func isSaved(_ coordinate: CLLocationCoordinate2D) -> Bool {
        places.contains { abs($0.latitude - coordinate.latitude) < 0.000001 && abs($0.longitude - coordinate.longitude) < 0.000001 }
    }

    func toggleSaved() {
        if let index = places.firstIndex(where: {
            abs($0.latitude - selectedCoordinate.latitude) < 0.000001 &&
            abs($0.longitude - selectedCoordinate.longitude) < 0.000001
        }) {
            places.remove(at: index)
        } else {
            places.insert(.init(name: selectedTitle, subtitle: selectedSubtitle,
                                latitude: selectedCoordinate.latitude,
                                longitude: selectedCoordinate.longitude,
                                category: .personal), at: 0)
        }
    }

    func addPlace(name: String, category: SavedCategory) {
        places.insert(.init(name: name, subtitle: "موقع محفوظ", latitude: selectedCoordinate.latitude,
                            longitude: selectedCoordinate.longitude, category: category), at: 0)
    }

    func runTest(location: CLLocation?) -> TestEvaluation? {
        let usePreview = previewCoordinate != nil
        guard let observed = previewCoordinate ?? location?.coordinate else { return nil }
        let simulated = usePreview ? true : location?.sourceInformation?.isSimulatedBySoftware
        let accuracy = usePreview ? modeledAccuracy : (location?.horizontalAccuracy ?? -1)
        let age = usePreview ? 0 : max(0, -(location?.timestamp.timeIntervalSinceNow ?? -999))
        let evaluation = LocalGeofenceEngine.evaluate(
            target: selectedCoordinate, observed: observed, radius: radius,
            isSimulated: simulated, rejectSimulated: rejectSimulated,
            accuracy: accuracy, fixAge: age)
        records.insert(.init(scenario: usePreview ? "موقع تجريبي داخل التطبيق" : "موقع الجهاز الحقيقي",
                             accepted: evaluation.accepted, distanceMeters: evaluation.distance,
                             details: evaluation.reason), at: 0)
        if records.count > 100 { records = Array(records.prefix(100)) }
        return evaluation
    }

    func exportJSON() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(records), let string = String(data: data, encoding: .utf8) else { return "[]" }
        return string
    }

    private func persistPlaces() { Self.save(places, key: "saved_places") }
    private func persistRecords() { Self.save(records, key: "test_records") }

    private static func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: "geolab_" + key)
    }
    private static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: "geolab_" + key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
