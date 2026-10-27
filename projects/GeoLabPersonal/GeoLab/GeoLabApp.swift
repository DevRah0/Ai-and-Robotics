import SwiftUI

@main
struct GeoLabApp: App {
    @StateObject private var model = AppModel()
    @StateObject private var gps = LocationService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
                .environmentObject(gps)
                .task { gps.requestPermission() }
        }
    }
}
