import SwiftUI
import MapKit
import CoreLocation

struct GeoMapView: View {
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var gps: LocationService
    @State private var camera: MapCameraPosition = .region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262),
                           span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)))
    @State private var searchIsOpen = false
    var openFavorites: () -> Void

    var body: some View {
        ZStack {
            MapReader { proxy in
                Map(position: $camera) {
                    UserAnnotation()
                    Annotation("الهدف التجريبي", coordinate: model.selectedCoordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.geoDeep, Color.geoGreen)
                            .font(.system(size: 38))
                            .shadow(color: .black.opacity(0.18), radius: 5)
                    }
                    if let route = model.activeRoute, route.waypoints.count >= 2 {
                        MapPolyline(coordinates: route.waypoints.map(\.coordinate))
                            .stroke(Color.geoDeep, lineWidth: 4)
                    }
                    if let active = model.previewCoordinate {
                        Annotation("محاكاة داخل التطبيق", coordinate: active) {
                            Image(systemName: "location.north.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(.orange)
                        }
                    }
                }
                .mapStyle(model.presentation.mapStyle)
                .mapControlVisibility(.hidden)
                .simultaneousGesture(SpatialTapGesture().onEnded { tap in
                    if let coordinate = proxy.convert(tap.location, from: .local) {
                        model.choose(coordinate)
                    }
                })
                .ignoresSafeArea(edges: .top)
            }

            VStack(spacing: 12) {
                statusCapsule
                    .padding(.horizontal, 18)
                    .padding(.top, 10)

                Spacer()

                HStack {
                    VStack(spacing: 9) {
                        CapsuleIconButton(symbol: "magnifyingglass") { searchIsOpen = true }
                        CapsuleIconButton(symbol: "square.3.layers.3d") {
                            switch model.presentation {
                            case .standard: model.presentation = .hybrid
                            case .hybrid: model.presentation = .satellite
                            case .satellite: model.presentation = .standard
                            }
                        }
                        CapsuleIconButton(symbol: "location.fill") { focusOnRealLocation() }
                    }
                    Spacer()
                }
                .padding(.leading, 18)

                detailCard.padding(.horizontal, 14)
                    .padding(.bottom, 8)
            }
        }
        .sheet(isPresented: $searchIsOpen) { SearchView() }
        .onChange(of: model.centerSerial) { _, _ in centerOnSelected() }
        .onChange(of: model.show3D) { _, _ in centerOnSelected() }
    }

    private var statusCapsule: some View {
        HStack {
            HStack(spacing: 5) {
                Image(systemName: "checkmark.shield.fill")
                Text("وضع اختبار محلي")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.geoDeep)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.geoGreen.opacity(0.5), in: Capsule())

            Spacer()
            Circle().fill(model.previewIsOn ? Color.orange : Color.gray).frame(width: 9, height: 9)
            Text(model.previewIsOn ? "معاينة افتراضية" : "لا توجد معاينة")
                .font(.subheadline.weight(.bold))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(.regularMaterial, in: Capsule())
        .overlay { Capsule().strokeBorder(.white.opacity(0.5)) }
    }

    private var detailCard: some View {
        VStack(spacing: 14) {
            Capsule().fill(.secondary.opacity(0.4)).frame(width: 50, height: 5)
            HStack(alignment: .top) {
                Button(action: model.toggleSaved) {
                    Image(systemName: model.isSaved(model.selectedCoordinate) ? "star.fill" : "star")
                        .foregroundStyle(.orange)
                        .font(.title3)
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 5) {
                    Text(model.selectedTitle).font(.headline).lineLimit(1)
                    Text(model.selectedSubtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                    Text("\(model.selectedCoordinate.latitude.coordinateString), \(model.selectedCoordinate.longitude.coordinateString)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                Image(systemName: "mappin.and.ellipse")
                    .font(.title3).foregroundStyle(Color.geoDeep)
                    .frame(width: 46, height: 46)
                    .background(Color.geoGreen.opacity(0.18), in: RoundedRectangle(cornerRadius: 13))
            }
            HStack(spacing: 6) {
                ForEach(MovementMode.allCases, id: \.rawValue) { mode in
                    Button {
                        model.movement = mode
                    } label: {
                        Label(mode.title, systemImage: mode.icon)
                            .labelStyle(.titleAndIcon)
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 9)
                            .foregroundStyle(model.movement == mode ? Color.geoDeep : .primary)
                            .background(model.movement == mode ? Color.geoGreen : Color.geoBackground, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            if model.previewIsOn && model.movement != .fixed {
                HStack(spacing: 18) {
                    Button { model.movePreview(bearingDegrees: 270) } label: { Image(systemName: "arrow.left.circle.fill") }
                    VStack(spacing: 6) {
                        Button { model.movePreview(bearingDegrees: 0) } label: { Image(systemName: "arrow.up.circle.fill") }
                        Button { model.movePreview(bearingDegrees: 180) } label: { Image(systemName: "arrow.down.circle.fill") }
                    }
                    Button { model.movePreview(bearingDegrees: 90) } label: { Image(systemName: "arrow.right.circle.fill") }
                }
                .font(.title2)
                .foregroundStyle(Color.geoDeep)
                .accessibilityLabel("عصا تحكم للمحاكاة المحلية")
            }
            PrimaryButton(title: model.previewIsOn ? "إيقاف المعاينة التجريبية" : "بدء معاينة الموقع داخل التطبيق",
                          symbol: model.previewIsOn ? "stop.fill" : "pin.fill") {
                model.togglePreview()
            }
            if model.routePlaying {
                ProgressView(value: model.routeFraction)
                    .accessibilityLabel("تقدم المسار التجريبي")
            }
            Text("المعاينة لا تغيّر GPS النظام ولا موقع التطبيقات الأخرى")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 32))
        .overlay { RoundedRectangle(cornerRadius: 32).strokeBorder(.white.opacity(0.65)) }
        .shadow(color: .black.opacity(0.08), radius: 15, y: 5)
    }

    private func centerOnSelected() {
        let center = model.previewCoordinate ?? model.selectedCoordinate
        withAnimation(.smooth(duration: 0.5)) {
            if model.show3D {
                camera = .camera(MapCamera(centerCoordinate: center, distance: 1500, heading: 0, pitch: 55))
            } else {
                camera = .region(MKCoordinateRegion(center: center,
                                                    span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))
            }
        }
    }

    private func focusOnRealLocation() {
        guard let point = gps.location?.coordinate else {
            gps.requestPermission()
            return
        }
        model.choose(point, name: "الموقع الحقيقي", subtitle: "حسب CoreLocation")
    }
}
