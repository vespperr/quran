import WidgetKit
import SwiftUI

@main
struct PrayerWidgetBundle: WidgetBundle {
    var body: some Widget {
        PrayerWidget()
    }
}

// MARK: - App Group Store & Data Contract

struct SharedPrayerItem: Codable {
    let name: String
    let timeStr: String
}

struct SharedPrayerStoreData: Codable {
    let city: String
    let displayTimes: String
    let fajr: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String
    let nextPrayer: String
    let lastUpdated: Double
}

struct SharedPrayerStore {
    static let appGroupId = "group.com.dya.azadalkrd"
    static let jsonKey = "widget_prayer_data_v1"
    
    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupId) ?? UserDefaults.standard
    }
    
    static func loadData() -> SharedPrayerStoreData? {
        let defs = defaults
        if let jsonString = defs.string(forKey: jsonKey),
           let jsonData = jsonString.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(SharedPrayerStoreData.self, from: jsonData) {
            return decoded
        }
        
        let city = defs.string(forKey: "widget_city") ?? ""
        let displayTimes = defs.string(forKey: "display_times") ?? ""
        let fajr = defs.string(forKey: "fajr") ?? ""
        let dhuhr = defs.string(forKey: "dhuhr") ?? ""
        let asr = defs.string(forKey: "asr") ?? ""
        let maghrib = defs.string(forKey: "maghrib") ?? ""
        let isha = defs.string(forKey: "isha") ?? ""
        let nextPrayer = defs.string(forKey: "next_prayer") ?? ""
        let lastUpdated = defs.double(forKey: "last_updated")
        
        if city.isEmpty && displayTimes.isEmpty && fajr.isEmpty {
            return nil
        }
        
        return SharedPrayerStoreData(
            city: city,
            displayTimes: displayTimes,
            fajr: fajr,
            dhuhr: dhuhr,
            asr: asr,
            maghrib: maghrib,
            isha: isha,
            nextPrayer: nextPrayer,
            lastUpdated: lastUpdated
        )
    }
}

struct PrayerEntry: TimelineEntry {
    let date: Date
    let city: String
    let times: [(name: String, timeStr: String)]
    let nextPrayerName: String
    let nextPrayerTime: String
    let timeUntil: String
    let lastUpdatedStr: String
}

struct PrayerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(
            date: Date(),
            city: "Slemani",
            times: [
                ("Fajr", "04:12"),
                ("Dhuhr", "12:15"),
                ("Asr", "15:45"),
                ("Maghrib", "18:30"),
                ("Isha", "19:50")
            ],
            nextPrayerName: "Dhuhr",
            nextPrayerTime: "12:15",
            timeUntil: "01:25",
            lastUpdatedStr: "12:00"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        completion(fetchEntry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let currentDate = Date()
        var entries: [PrayerEntry] = []
        
        for minuteOffset in stride(from: 0, to: 24 * 60, by: 15) {
            if let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate) {
                entries.append(fetchEntry(for: entryDate))
            }
        }
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate) ?? currentDate.addingTimeInterval(900)
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }

    private func parsePrayerMinutes(_ timeStr: String, name: String) -> Int? {
        let clean = timeStr.trimmingCharacters(in: .whitespaces).uppercased()
        let isPm = clean.contains("PM")
        let isAm = clean.contains("AM")
        let digitsOnly = clean.replacingOccurrences(of: "AM", with: "").replacingOccurrences(of: "PM", with: "").trimmingCharacters(in: .whitespaces)
        let parts = digitsOnly.components(separatedBy: ":")
        if parts.count >= 2, var h = Int(parts[0]), let m = Int(parts[1]) {
            if isPm && h < 12 { h += 12 }
            if isAm && h == 12 { h = 0 }
            
            if !isPm && !isAm {
                let lower = name.lowercased()
                if lower.contains("dhuhr") && (1...11).contains(h) {
                    h += 12
                } else if (lower.contains("asr") || lower.contains("maghrib") || lower.contains("isha")) && (1...11).contains(h) {
                    h += 12
                }
            }
            return h * 60 + m
        }
        return nil
    }

    private func fetchEntry(for date: Date) -> PrayerEntry {
        let data = SharedPrayerStore.loadData()
        let rawCity = data?.city ?? ""
        let city = rawCity.isEmpty ? "Azad Al-Kurdi" : rawCity
        let displayTimes = data?.displayTimes ?? ""
        let lastUpdated = data?.lastUpdated ?? 0

        let lastUpdatedStr: String
        if lastUpdated > 0 {
            let df = DateFormatter()
            df.dateFormat = "HH:mm"
            lastUpdatedStr = df.string(from: Date(timeIntervalSince1970: lastUpdated))
        } else {
            lastUpdatedStr = "Open App"
        }

        var parsedTimes: [(name: String, timeStr: String)] = []
        if !displayTimes.isEmpty {
            let parts = displayTimes.components(separatedBy: ";")
            for part in parts {
                let pair = part.components(separatedBy: "|")
                if pair.count == 2 {
                    parsedTimes.append((name: pair[0].trimmingCharacters(in: .whitespaces),
                                        timeStr: pair[1].trimmingCharacters(in: .whitespaces)))
                }
            }
        }
        
        if parsedTimes.isEmpty {
            let fajr = data?.fajr ?? ""
            let dhuhr = data?.dhuhr ?? ""
            let asr = data?.asr ?? ""
            let maghrib = data?.maghrib ?? ""
            let isha = data?.isha ?? ""
            
            if !fajr.isEmpty && fajr != "--:--" {
                parsedTimes = [
                    ("Fajr", fajr),
                    ("Dhuhr", dhuhr),
                    ("Asr", asr),
                    ("Maghrib", maghrib),
                    ("Isha", isha)
                ]
            } else {
                parsedTimes = [
                    ("Fajr", "--:--"),
                    ("Dhuhr", "--:--"),
                    ("Asr", "--:--"),
                    ("Maghrib", "--:--"),
                    ("Isha", "--:--")
                ]
            }
        }

        let calendar = Calendar.current
        let currentMinutes = calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
        
        var nextName = parsedTimes.first?.name ?? "Fajr"
        var nextTimeStr = parsedTimes.first?.timeStr ?? "--:--"
        var nextTotalMins = 0

        for item in parsedTimes {
            if let total = parsePrayerMinutes(item.timeStr, name: item.name) {
                if total > currentMinutes {
                    nextName = item.name
                    nextTimeStr = item.timeStr
                    nextTotalMins = total
                    break
                }
            }
        }

        if nextTotalMins == 0, let first = parsedTimes.first {
            if let total = parsePrayerMinutes(first.timeStr, name: first.name) {
                nextTotalMins = total + (24 * 60)
            }
        }

        let diff = max(0, nextTotalMins - currentMinutes)
        let diffH = diff / 60
        let diffM = diff % 60
        let untilStr = String(format: "%02d:%02d", diffH, diffM)

        return PrayerEntry(
            date: date,
            city: city,
            times: parsedTimes,
            nextPrayerName: nextName,
            nextPrayerTime: nextTimeStr,
            timeUntil: untilStr,
            lastUpdatedStr: lastUpdatedStr
        )
    }
}

// MARK: - Widget Views

struct SmallPrayerWidgetView: View {
    let entry: PrayerEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "location.fill")
                    .font(.system(size: 10))
                    .foregroundColor(Color(red: 212/255, green: 175/255, blue: 55/255))
                Text(entry.city)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text(entry.lastUpdatedStr)
                    .font(.system(size: 8, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            Text(entry.nextPrayerName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 212/255, green: 175/255, blue: 55/255))

            Text(entry.nextPrayerTime)
                .font(.system(size: 28, weight: .heavy))
                .foregroundColor(.white)

            HStack(spacing: 4) {
                Image(systemName: "hourglass")
                    .font(.system(size: 10))
                    .foregroundColor(Color(red: 212/255, green: 175/255, blue: 55/255))
                Text("-\(entry.timeUntil)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)
        }
        .padding(14)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 15/255, green: 56/255, blue: 44/255), Color(red: 6/255, green: 26/255, blue: 20/255)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct MediumPrayerWidgetView: View {
    let entry: PrayerEntry

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 212/255, green: 175/255, blue: 55/255))
                    Text(entry.city)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text(entry.lastUpdatedStr)
                        .font(.system(size: 8, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                Text("Next Prayer")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                Text(entry.nextPrayerName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 212/255, green: 175/255, blue: 55/255))

                Text(entry.nextPrayerTime)
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)

                Text("-\(entry.timeUntil)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 212/255, green: 175/255, blue: 55/255))
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.25))
            .cornerRadius(14)

            VStack(spacing: 4) {
                ForEach(entry.times, id: \.name) { item in
                    let isNext = item.name == entry.nextPrayerName
                    HStack {
                        Text(item.name)
                            .font(.system(size: 11, weight: isNext ? .bold : .medium))
                            .foregroundColor(isNext ? Color(red: 212/255, green: 175/255, blue: 55/255) : .white.opacity(0.85))
                        Spacer()
                        Text(item.timeStr)
                            .font(.system(size: 11, weight: isNext ? .bold : .regular))
                            .foregroundColor(isNext ? .white : .white.opacity(0.8))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isNext ? Color(red: 212/255, green: 175/255, blue: 55/255).opacity(0.2) : Color.clear)
                    .cornerRadius(6)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 15/255, green: 56/255, blue: 44/255), Color(red: 6/255, green: 26/255, blue: 20/255)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct LargePrayerWidgetView: View {
    let entry: PrayerEntry

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 212/255, green: 175/255, blue: 55/255))
                    Text("Prayer Times")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 212/255, green: 175/255, blue: 55/255))
                    Text("\(entry.city) (\(entry.lastUpdatedStr))")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.white.opacity(0.15))
                .cornerRadius(8)
            }

            VStack(spacing: 4) {
                Text(entry.nextPrayerName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 212/255, green: 175/255, blue: 55/255))
                Text(entry.nextPrayerTime)
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(.white)
                HStack(spacing: 4) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 212/255, green: 175/255, blue: 55/255))
                    Text("-\(entry.timeUntil)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.3))
                .cornerRadius(12)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.2))
            .cornerRadius(16)

            VStack(spacing: 6) {
                ForEach(entry.times, id: \.name) { item in
                    let isNext = item.name == entry.nextPrayerName
                    HStack {
                        Text(item.name)
                            .font(.system(size: 13, weight: isNext ? .bold : .medium))
                            .foregroundColor(isNext ? Color(red: 212/255, green: 175/255, blue: 55/255) : .white.opacity(0.9))
                        Spacer()
                        Text(item.timeStr)
                            .font(.system(size: 13, weight: isNext ? .bold : .regular))
                            .foregroundColor(isNext ? .white : .white.opacity(0.85))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isNext ? Color(red: 212/255, green: 175/255, blue: 55/255).opacity(0.22) : Color.white.opacity(0.05))
                    .cornerRadius(10)
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 15/255, green: 56/255, blue: 44/255), Color(red: 6/255, green: 26/255, blue: 20/255)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Main Widget Entry

struct PrayerWidget: Widget {
    let kind: String = "PrayerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerWidgetProvider()) { entry in
            PrayerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Azad Al-Kurdi Prayer Times")
        .description("Beautiful live prayer times and next prayer countdown.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct PrayerWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: PrayerEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallPrayerWidgetView(entry: entry)
        case .systemMedium:
            MediumPrayerWidgetView(entry: entry)
        case .systemLarge:
            LargePrayerWidgetView(entry: entry)
        @unknown default:
            SmallPrayerWidgetView(entry: entry)
        }
    }
}
