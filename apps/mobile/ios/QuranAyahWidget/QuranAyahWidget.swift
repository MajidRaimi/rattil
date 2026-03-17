import WidgetKit
import SwiftUI

struct AyahEntry: TimelineEntry {
    let date: Date
    let lightImage: UIImage?
    let darkImage: UIImage?
}

struct AyahProvider: TimelineProvider {
    let userDefaults = UserDefaults(suiteName: "group.app.rattil")

    func placeholder(in context: Context) -> AyahEntry {
        AyahEntry(date: Date(), lightImage: nil, darkImage: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (AyahEntry) -> Void) {
        let entry = AyahEntry(
            date: Date(),
            lightImage: loadImage(key: "ayah_widget_light"),
            darkImage: loadImage(key: "ayah_widget_dark")
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AyahEntry>) -> Void) {
        let entry = AyahEntry(
            date: Date(),
            lightImage: loadImage(key: "ayah_widget_light"),
            darkImage: loadImage(key: "ayah_widget_dark")
        )
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadImage(key: String) -> UIImage? {
        guard let path = userDefaults?.string(forKey: key) else { return nil }
        return UIImage(contentsOfFile: path)
    }
}

struct AyahWidgetEntryView: View {
    var entry: AyahEntry
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if let image = colorScheme == .dark ? entry.darkImage : entry.lightImage {
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
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("آية الساعة")
        .description("Displays a random Quran verse every hour")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
