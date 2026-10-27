import SwiftUI
import MapKit

struct SearchView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var places: [MKMapItem] = []
    @State private var isSearching = false
    @State private var task: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                TextField("ابحث عن مدينة أو معلم", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(14)
                    .background(Color.geoBackground, in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
                    .onChange(of: query) { _, newValue in search(newValue) }
                if isSearching { ProgressView().padding() }
                List {
                    if query.isEmpty {
                        Section("أماكن مقترحة") {
                            ForEach(SavedPlace.presets) { place in
                                Button {
                                    model.choose(place)
                                    dismiss()
                                } label: {
                                    Label(place.name, systemImage: "mappin.circle")
                                }
                            }
                        }
                    } else {
                        ForEach(places, id: \.self) { item in
                            Button {
                                model.choose(item.placemark.coordinate,
                                             name: item.name ?? "موقع",
                                             subtitle: item.placemark.title ?? "نتيجة بحث")
                                dismiss()
                            } label: {
                                VStack(alignment: .trailing, spacing: 5) {
                                    Text(item.name ?? "موقع").foregroundStyle(.primary)
                                    Text(item.placemark.title ?? "")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("البحث عن مكان")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("إغلاق") { dismiss() } } }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .onDisappear { task?.cancel() }
    }

    private func search(_ text: String) {
        task?.cancel()
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            places = []
            isSearching = false
            return
        }
        isSearching = true
        task = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = text
            request.resultTypes = [.address, .pointOfInterest]
            do {
                let response = try await MKLocalSearch(request: request).start()
                guard !Task.isCancelled else { return }
                places = Array(response.mapItems.prefix(15))
            } catch {
                if !Task.isCancelled { places = [] }
            }
            if !Task.isCancelled { isSearching = false }
        }
    }
}
