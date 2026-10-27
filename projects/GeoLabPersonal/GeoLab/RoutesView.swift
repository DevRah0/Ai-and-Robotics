import SwiftUI
import CoreLocation
import UniformTypeIdentifiers

struct RoutesView: View {
    @EnvironmentObject private var model: AppModel
    @State private var routeName = "مساري التجريبي"
    @State private var showImporter = false
    @State private var importError: String?
    @State private var exportDocument: GPXDocument?
    @State private var showExporter = false
    var openMap: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .trailing, spacing: 17) {
                Text("المسارات").font(.system(size: 42, weight: .bold, design: .rounded)).padding(.top, 18)
                Text("ارسم مسارات تجريبية وشغّل حركتها داخل الخريطة فقط. يمكنك استيراد وتصدير ملفات GPX.")
                    .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                GeoCard {
                    VStack(alignment: .trailing, spacing: 12) {
                        Text("إنشاء مسار").font(.headline)
                        TextField("اسم المسار", text: $routeName)
                            .textFieldStyle(.roundedBorder)
                        HStack {
                            Button("إضافة النقطة الحالية") { model.appendCurrentWaypoint() }
                                .buttonStyle(.bordered)
                            Spacer()
                            Text("النقاط: \(model.routeDraft.count)")
                        }
                        ForEach(Array(model.routeDraft.enumerated()), id: \.element.id) { index, point in
                            HStack {
                                Button(role: .destructive) { model.routeDraft.remove(at: index) } label: {
                                    Image(systemName: "minus.circle")
                                }
                                Spacer()
                                Text("\(index + 1). \(point.latitude.coordinateString), \(point.longitude.coordinateString)")
                                    .font(.system(.caption, design: .monospaced))
                            }
                        }
                        HStack(spacing: 12) {
                            Button("مسح النقاط", role: .destructive) { model.routeDraft.removeAll() }
                            Spacer()
                            PrimaryButton(title: "حفظ المسار", symbol: "square.and.arrow.down") {
                                model.saveRoute(name: routeName)
                                routeName = "مساري التجريبي"
                            }
                            .disabled(model.routeDraft.count < 2 || routeName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
                Button { showImporter = true } label: {
                    Label("استيراد ملف GPX", systemImage: "square.and.arrow.down.on.square")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.geoDeep)

                SectionHeading(text: "المسارات المحفوظة (\(model.routes.count))")
                ForEach(model.routes) { route in
                    GeoCard {
                        VStack(alignment: .trailing, spacing: 11) {
                            HStack {
                                Spacer()
                                Text(route.name).font(.headline)
                                Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                            }
                            Text("\(route.waypoints.count) نقاط • \(Int(route.lengthMeters)) متر")
                                .foregroundStyle(.secondary).font(.caption)
                            HStack(spacing: 10) {
                                Button("معاينة") {
                                    model.startRoutePreview(route)
                                    openMap()
                                }
                                .buttonStyle(.borderedProminent).tint(.geoDeep)
                                Button("إيقاف") { model.stopRoutePreview() }
                                    .buttonStyle(.bordered)
                                Button {
                                    exportDocument = GPXDocument(xml: GPXCodec.export(route))
                                    showExporter = true
                                } label: {
                                    Label("تصدير GPX", systemImage: "square.and.arrow.up")
                                }.font(.caption)
                                Spacer()
                            }
                            if model.activeRoute?.id == route.id {
                                ProgressView(value: model.routeFraction)
                                Text(model.routePlaying ? "المسار يعمل داخل التطبيق" : "المسار متوقف")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) { model.deleteRoute(id: route.id) } label: {
                                Label("حذف", systemImage: "trash")
                            }
                        }
                    }
                }
                if model.routes.isEmpty {
                    ContentUnavailableView("لا توجد مسارات", systemImage: "point.topleft.down.curvedto.point.bottomright.up", description: Text("أنشئ مسارًا من نقطتين أو استورد GPX"))
                }
            }
            .padding(.horizontal, 18).padding(.bottom, 24)
        }
        .fileExporter(isPresented: $showExporter, document: $exportDocument,
                      contentType: UTType(filenameExtension: "gpx") ?? .xml,
                      defaultFilename: "GeoLab-Route") { result in
            if case .failure(let error) = result { importError = error.localizedDescription }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [UTType(filenameExtension: "gpx") ?? .xml, .xml]) { result in
            do {
                let url = try result.get()
                let accessed = url.startAccessingSecurityScopedResource()
                defer { if accessed { url.stopAccessingSecurityScopedResource() } }
                let data = try Data(contentsOf: url)
                guard data.count < 2_000_000 else { throw GPXError.tooManyPoints }
                let route = try GPXCodec.parse(data)
                model.importRoute(route)
            } catch { importError = error.localizedDescription }
        }
        .alert("تعذر استيراد GPX", isPresented: Binding(get: { importError != nil }, set: { if !$0 { importError = nil } })) {
            Button("موافق", role: .cancel) { importError = nil }
        } message: { Text(importError ?? "") }
    }
}
