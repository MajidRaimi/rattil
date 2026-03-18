import WidgetKit
import SwiftUI

struct AyahEntry: TimelineEntry {
    let date: Date
    let smallLightImage: UIImage?
    let smallDarkImage: UIImage?
    let mediumLightImage: UIImage?
    let mediumDarkImage: UIImage?
    let largeLightImage: UIImage?
    let largeDarkImage: UIImage?
}

struct AyahProvider: TimelineProvider {
    let userDefaults = UserDefaults(suiteName: "group.app.rattil")

    func placeholder(in context: Context) -> AyahEntry {
        AyahEntry(
            date: Date(),
            smallLightImage: nil, smallDarkImage: nil,
            mediumLightImage: nil, mediumDarkImage: nil,
            largeLightImage: nil, largeDarkImage: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (AyahEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AyahEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> AyahEntry {
        AyahEntry(
            date: Date(),
            smallLightImage: loadImage(key: "ayah_widget_small_light"),
            smallDarkImage: loadImage(key: "ayah_widget_small_dark"),
            mediumLightImage: loadImage(key: "ayah_widget_light"),
            mediumDarkImage: loadImage(key: "ayah_widget_dark"),
            largeLightImage: loadImage(key: "ayah_widget_large_light"),
            largeDarkImage: loadImage(key: "ayah_widget_large_dark")
        )
    }

    private func loadImage(key: String) -> UIImage? {
        guard let path = userDefaults?.string(forKey: key) else { return nil }
        return UIImage(contentsOfFile: path)
    }
}

struct AyahWidgetEntryView: View {
    var entry: AyahEntry
    @Environment(\.colorScheme) var systemColorScheme
    @Environment(\.widgetFamily) var widgetFamily

    private var isDark: Bool {
        let userDefaults = UserDefaults(suiteName: "group.app.rattil")
        let appTheme = userDefaults?.string(forKey: "app_theme") ?? "system"
        switch appTheme {
        case "light": return false
        case "dark": return true
        default: return systemColorScheme == .dark
        }
    }

    private var image: UIImage? {
        switch widgetFamily {
        case .systemSmall:
            return isDark ? entry.smallDarkImage : entry.smallLightImage
        case .systemLarge:
            return isDark ? entry.largeDarkImage : entry.largeLightImage
        default:
            return isDark ? entry.mediumDarkImage : entry.mediumLightImage
        }
    }

    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Text("آية الساعة")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
    }
}

@main
struct QuranAyahWidget: Widget {
    let kind: String = "QuranAyahWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AyahProvider()) { entry in
            AyahWidgetEntryView(entry: entry)
                .invalidatableContent()
                .containerBackground(for: .widget) {}
        }
        .configurationDisplayName("آية الساعة")
        .description("Displays a random Quran verse every hour")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}
