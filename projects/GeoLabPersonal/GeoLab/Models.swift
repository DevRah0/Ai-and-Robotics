import Foundation
import CoreLocation
import MapKit
import SwiftUI

enum SavedCategory: String, CaseIterable, Codable, Identifiable {
    case landmark, travel, game, work, personal
    var id: String { rawValue }
    var title: String {
        switch self {
        case .landmark: return "معالم"
        case .travel: return "سياحة"
        case .game: return "ألعاب"
        case .work: return "عمل"
        case .personal: return "شخصي"
        }
    }
    var icon: String {
        switch self {
        case .landmark: return "building.columns.fill"
        case .travel: return "airplane"
        case .game: return "gamecontroller.fill"
        case .work: return "briefcase.fill"
        case .personal: return "pin.fill"
        }
    }
}

struct SavedPlace: Codable, Identifiable {
    var id = UUID()
    var name: String
    var subtitle: String
    var latitude: Double
    var longitude: Double
    var category: SavedCategory
    var coordinate: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude) }

    static let presets: [SavedPlace] = [
        .init(name: "برج خليفة", subtitle: "دبي، الإمارات", latitude: 25.19720, longitude: 55.27440, category: .landmark),
        .init(name: "المسجد الحرام", subtitle: "مكة المكرمة، السعودية", latitude: 21.42250, longitude: 39.82620, category: .landmark),
        .init(name: "برج إيفل", subtitle: "باريس، فرنسا", latitude: 48.85840, longitude: 2.29450, category: .travel),
        .init(name: "تايمز سكوير", subtitle: "نيويورك، الولايات المتحدة", latitude: 40.75800, longitude: -73.98550, category: .travel),
        .init(name: "شيبويا", subtitle: "طوكيو، اليابان", latitude: 35.65950, longitude: 139.70050, category: .game)
    ]
}

enum MovementMode: String, CaseIterable, Identifiable {
    case fixed, walking, cycling, driving, flight
    var id: String { rawValue }
    var title: String {
        switch self {
        case .fixed: return "ثابت"
        case .walking: return "مشي"
        case .cycling: return "دراجة"
        case .driving: return "سيارة"
        case .flight: return "طيران"
        }
    }
    var icon: String {
        switch self {
        case .fixed: return "mappin"
        case .walking: return "figure.walk"
        case .cycling: return "bicycle"
        case .driving: return "car.fill"
        case .flight: return "airplane"
        }
    }
    // Approximate meters per manual step, used only inside this app.
    var stepMeters: Double {
        switch self {
        case .fixed: return 0
        case .walking: return 2
        case .cycling: return 8
        case .driving: return 25
        case .flight: return 110
        }
    }
}

enum MapPresentation: String, CaseIterable, Identifiable {
    case standard, hybrid, satellite
    var id: String { rawValue }
    var title: String {
        switch self {
        case .standard: return "افتراضي"
        case .hybrid: return "مختلط"
        case .satellite: return "قمر صناعي"
        }
    }
    var mapStyle: MapStyle {
        switch self {
        case .standard: return .standard(elevation: .realistic)
        case .hybrid: return .hybrid(elevation: .realistic)
        case .satellite: return .imagery(elevation: .realistic)
        }
    }
}

struct TestRecord: Codable, Identifiable {
    var id = UUID()
    var date = Date()
    var scenario: String
    var accepted: Bool
    var distanceMeters: Double
    var details: String
}

struct TestEvaluation {
    let accepted: Bool
    let distance: Double
    let reason: String
}

enum LocalGeofenceEngine {
    /// Educational/local geofence example; it does NOT interface with employer attendance systems.
    static func evaluate(target: CLLocationCoordinate2D,
                         observed: CLLocationCoordinate2D,
                         radius: Double,
                         isSimulated: Bool?,
                         rejectSimulated: Bool,
                         accuracy: Double,
                         fixAge: TimeInterval) -> TestEvaluation {
        let targetLocation = CLLocation(latitude: target.latitude, longitude: target.longitude)
        let observedLocation = CLLocation(latitude: observed.latitude, longitude: observed.longitude)
        let distance = targetLocation.distance(from: observedLocation)
        if rejectSimulated && isSimulated == true {
            return .init(accepted: false, distance: distance, reason: "رفض: مصدر الموقع موسوم بأنه محاكى")
        }
        if fixAge > 30 {
            return .init(accepted: false, distance: distance, reason: "رفض: قراءة الموقع أقدم من 30 ثانية")
        }
        if accuracy < 0 || accuracy > 80 {
            return .init(accepted: false, distance: distance, reason: "رفض: دقة GPS غير كافية")
        }
        if distance > radius {
            return .init(accepted: false, distance: distance, reason: "رفض: الموقع خارج النطاق التجريبي")
        }
        return .init(accepted: true, distance: distance, reason: "نجاح: جميع شروط الاختبار المحلي مستوفاة")
    }
}

extension Double {
    var coordinateString: String { String(format: "%.5f", self) }
}

extension Color {
    static let geoGreen = Color(red: 0.68, green: 0.90, blue: 0.25)
    static let geoDeep = Color(red: 0.17, green: 0.29, blue: 0.11)
    static let geoBackground = Color(red: 0.953, green: 0.957, blue: 0.972)
}
