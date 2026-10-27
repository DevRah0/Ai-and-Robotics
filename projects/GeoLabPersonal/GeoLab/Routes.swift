import Foundation
import CoreLocation
import FoundationXML

struct RouteWaypoint: Codable, Identifiable, Equatable {
    var id = UUID()
    var latitude: Double
    var longitude: Double
    var coordinate: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude) }
}

struct SavedRoute: Codable, Identifiable {
    var id = UUID()
    var name: String
    var waypoints: [RouteWaypoint]
    var createdAt = Date()

    var lengthMeters: Double {
        guard waypoints.count > 1 else { return 0 }
        return zip(waypoints, waypoints.dropFirst()).reduce(0) { sum, segment in
            sum + CLLocation(latitude: segment.0.latitude, longitude: segment.0.longitude)
                .distance(from: CLLocation(latitude: segment.1.latitude, longitude: segment.1.longitude))
        }
    }
}

struct SelectionHistoryEntry: Codable, Identifiable {
    var id = UUID()
    var date = Date()
    var name: String
    var latitude: Double
    var longitude: Double
    var coordinate: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude) }
}

enum RouteMath {
    /// Great-circle interpolation; result is only for an in-app test preview.
    static func interpolate(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D, fraction: Double) -> CLLocationCoordinate2D {
        let fraction = max(0, min(1, fraction))
        let phi1 = a.latitude * .pi / 180, lambda1 = a.longitude * .pi / 180
        let phi2 = b.latitude * .pi / 180, lambda2 = b.longitude * .pi / 180
        let cosD = min(1, max(-1, sin(phi1) * sin(phi2) + cos(phi1) * cos(phi2) * cos(lambda2 - lambda1)))
        let distance = acos(cosD)
        if distance < 1e-12 { return a }
        let k1 = sin((1 - fraction) * distance) / sin(distance)
        let k2 = sin(fraction * distance) / sin(distance)
        let x = k1 * cos(phi1) * cos(lambda1) + k2 * cos(phi2) * cos(lambda2)
        let y = k1 * cos(phi1) * sin(lambda1) + k2 * cos(phi2) * sin(lambda2)
        let z = k1 * sin(phi1) + k2 * sin(phi2)
        return .init(latitude: atan2(z, sqrt(x * x + y * y)) * 180 / .pi,
                     longitude: atan2(y, x) * 180 / .pi)
    }
}

enum GPXCodec {
    static func export(_ route: SavedRoute) -> String {
        let points = route.waypoints.map {
            "    <trkpt lat=\"\($0.latitude)\" lon=\"\($0.longitude)\"/>"
        }.joined(separator: "\n")
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="GeoLab Personal" xmlns="http://www.topografix.com/GPX/1/1">
          <trk><name>\(xmlEscape(route.name))</name><trkseg>
        \(points)
          </trkseg></trk>
        </gpx>
        """
    }

    static func parse(_ data: Data) throws -> SavedRoute {
        let delegate = GPXDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.shouldResolveExternalEntities = false
        guard parser.parse() else {
            throw parser.parserError ?? GPXError.invalidXML
        }
        guard delegate.points.count >= 2 else { throw GPXError.insufficientPoints }
        guard delegate.points.count <= 1000 else { throw GPXError.tooManyPoints }
        return SavedRoute(name: delegate.routeName.isEmpty ? "مسار GPX مستورد" : delegate.routeName,
                          waypoints: delegate.points)
    }

    private static func xmlEscape(_ input: String) -> String {
        input.replacingOccurrences(of: "&", with: "&amp;")
             .replacingOccurrences(of: "<", with: "&lt;")
             .replacingOccurrences(of: ">", with: "&gt;")
             .replacingOccurrences(of: "\"", with: "&quot;")
    }
}

enum GPXError: LocalizedError {
    case invalidXML, insufficientPoints, tooManyPoints
    var errorDescription: String? {
        switch self {
        case .invalidXML: return "ملف GPX غير صالح"
        case .insufficientPoints: return "يجب أن يحتوي المسار على نقطتين على الأقل"
        case .tooManyPoints: return "الحد الأقصى ألف نقطة للمسار الواحد"
        }
    }
}

private final class GPXDelegate: NSObject, XMLParserDelegate {
    var points: [RouteWaypoint] = []
    var routeName = ""
    private var readingName = false

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "trkpt" || elementName == "rtept" {
            guard let latText = attributeDict["lat"], let lonText = attributeDict["lon"],
                  let lat = Double(latText), let lon = Double(lonText),
                  lat.isFinite, lon.isFinite, (-90...90).contains(lat), (-180...180).contains(lon),
                  points.count < 1001 else { return }
            points.append(RouteWaypoint(latitude: lat, longitude: lon))
        }
        if elementName == "name" && routeName.isEmpty { readingName = true }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if readingName { routeName += string }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "name" { readingName = false }
    }
}
