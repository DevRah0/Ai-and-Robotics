import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var model: AppModel
    @State private var activeCategory: SavedCategory?
    @State private var showAdd = false
    @State private var showHistory = false
    @State private var placeName = ""
    @State private var addCategory: SavedCategory = .personal
    var openMap: () -> Void

    private var filtered: [SavedPlace] {
        guard let activeCategory else { return model.places }
        return model.places.filter { $0.category == activeCategory }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .trailing, spacing: 20) {
                HStack {
                    CapsuleIconButton(symbol: "plus") { showAdd = true }
                    Spacer()
                    Text("المفضلة")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                }
                .padding(.top, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 9) {
                        filterButton(nil, title: "الكل", icon: "square.grid.2x2.fill")
                        ForEach(SavedCategory.allCases) { category in
                            filterButton(category, title: category.title, icon: category.icon)
                        }
                    }
                }
                SectionHeading(text: "الأماكن المحفوظة (\(filtered.count))")
                LazyVStack(spacing: 0) {
                    ForEach(filtered) { place in
                        HStack(spacing: 12) {
                            Button {
                                model.choose(place)
                                openMap()
                            } label: {
                                Label("انتقال", systemImage: "bolt.fill")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color.geoDeep)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .background(Color.geoGreen.opacity(0.22), in: Capsule())
                            }
                            Spacer(minLength: 0)
                            VStack(alignment: .trailing, spacing: 6) {
                                Text(place.name).font(.headline).lineLimit(1)
                                Text(place.subtitle).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                                Text("\(place.latitude.coordinateString), \(place.longitude.coordinateString)")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                            Image(systemName: place.category.icon)
                                .font(.title3)
                                .foregroundStyle(Color.geoDeep)
                                .frame(width: 50, height: 50)
                                .background(Color.geoGreen.opacity(0.16), in: RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.vertical, 16)
                        .contextMenu {
                            Button(role: .destructive) { model.places.removeAll { $0.id == place.id } } label: {
                                Label("حذف الموقع", systemImage: "trash")
                            }
                        }
                        if place.id != filtered.last?.id { Divider() }
                    }
                }
                .padding(.horizontal, 16)
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 28))
                DisclosureGroup(isExpanded: $showHistory) {
                    ForEach(model.history.prefix(30)) { entry in
                        HStack {
                            Button("فتح") {
                                model.choose(entry.coordinate, name: entry.name)
                                openMap()
                            }
                            .font(.caption)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 3) {
                                Text(entry.name).font(.subheadline)
                                Text(entry.date, format: .dateTime.day().month().hour().minute())
                                    .font(.caption2).foregroundStyle(.secondary)
                            }
                        }.padding(.vertical, 4)
                    }
                    if model.history.isEmpty { Text("لا توجد مواقع حديثة") }
                    Button("مسح السجل", role: .destructive) { model.history.removeAll() }
                } label: {
                    Label("سجل المواقع المحددة (\(model.history.count))", systemImage: "clock.arrow.circlepath")
                        .font(.headline)
                }
                .padding().background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22))
                if filtered.isEmpty {
                    ContentUnavailableView("لا توجد مواقع", systemImage: "bookmark.slash", description: Text("أضف موقعًا من الخريطة"))
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $showAdd) {
            NavigationStack {
                Form {
                    Section("موقع الخريطة الحالي") {
                        Text("\(model.selectedCoordinate.latitude.coordinateString), \(model.selectedCoordinate.longitude.coordinateString)")
                    }
                    TextField("اسم الموقع", text: $placeName)
                    Picker("التصنيف", selection: $addCategory) {
                        ForEach(SavedCategory.allCases) { category in
                            Text(category.title).tag(category)
                        }
                    }
                }
                .navigationTitle("إضافة للمفضلة")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("إلغاء") { showAdd = false } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("حفظ") {
                            model.addPlace(name: placeName.trimmingCharacters(in: .whitespacesAndNewlines), category: addCategory)
                            placeName = ""
                            showAdd = false
                        }
                        .disabled(placeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
    }

    private func filterButton(_ category: SavedCategory?, title: String, icon: String) -> some View {
        Button {
            activeCategory = category
        } label: {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .foregroundStyle(activeCategory == category ? Color.geoDeep : .primary)
                .background(activeCategory == category ? Color.geoGreen : Color(uiColor: .secondarySystemGroupedBackground), in: Capsule())
        }
    }
}
