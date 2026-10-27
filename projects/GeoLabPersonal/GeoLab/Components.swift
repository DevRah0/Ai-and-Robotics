import SwiftUI

struct GeoCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 26))
    }
}

struct CapsuleIconButton: View {
    var symbol: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(Color.geoDeep)
                .frame(width: 47, height: 47)
                .background(.regularMaterial, in: Circle())
                .overlay { Circle().strokeBorder(.white.opacity(0.68), lineWidth: 1) }
        }
        .buttonStyle(.plain)
    }
}

struct PrimaryButton: View {
    var title: String
    var symbol: String? = nil
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let symbol { Image(systemName: symbol) }
                Text(title)
            }
            .font(.headline)
            .foregroundStyle(Color.geoDeep)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(Color.geoGreen, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct SectionHeading: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct ValueRow: View {
    var label: String
    var value: String
    var symbol: String? = nil
    var body: some View {
        HStack(spacing: 12) {
            if let symbol { Image(systemName: symbol).foregroundStyle(Color.geoGreen) }
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.geoDeep)
                .lineLimit(2)
            Spacer()
            Text(label)
                .font(.subheadline)
        }
    }
}

enum GeoTab: Int, CaseIterable {
    case map, favorites, routes, diagnostics, settings
    var title: String {
        switch self {
        case .map: return "الخريطة"
        case .favorites: return "المفضلة"
        case .routes: return "المسارات"
        case .diagnostics: return "الفحص"
        case .settings: return "الإعدادات"
        }
    }
    var symbol: String {
        switch self {
        case .map: return "map.fill"
        case .favorites: return "bookmark.fill"
        case .routes: return "point.topleft.down.curvedto.point.bottomright.up"
        case .diagnostics: return "waveform.path.ecg.rectangle"
        case .settings: return "gearshape.fill"
        }
    }
}

struct GeoDock: View {
    @Binding var selection: GeoTab
    var body: some View {
        HStack(spacing: 4) {
            ForEach(GeoTab.allCases, id: \.rawValue) { tab in
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 22, weight: .semibold))
                        Text(tab.title)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(selection == tab ? Color.geoDeep : Color.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(selection == tab ? Color.geoGreen.opacity(0.45) : .clear, in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
            }
        }
        .padding(7)
        .background(.regularMaterial, in: Capsule())
        .overlay { Capsule().strokeBorder(.white.opacity(0.7), lineWidth: 1) }
        .shadow(color: .black.opacity(0.08), radius: 18, y: 6)
        .padding(.horizontal, 16)
        .padding(.bottom, 5)
    }
}

struct RootView: View {
    @EnvironmentObject var model: AppModel
    @State private var tab: GeoTab = .map
    var body: some View {
        ZStack {
            Color.geoBackground.ignoresSafeArea()
            Group {
                switch tab {
                case .map: GeoMapView(openFavorites: { tab = .favorites })
                case .favorites: FavoritesView(openMap: { tab = .map })
                case .routes: RoutesView(openMap: { tab = .map })
                case .diagnostics: DiagnosticsView()
                case .settings: SettingsView()
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { GeoDock(selection: $tab) }
        .tint(.geoDeep)
        .environment(\.layoutDirection, .rightToLeft)
    }
}
