import SwiftUI
import Combine
import Foundation
import AVKit

struct HijriDate: Identifiable, Codable, Equatable {
    var id = UUID()
    let day: Date
    let arabic: String
    let english: String
}

extension Date {
    func isSameDay(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: date)
    }
}

enum AccentColor: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case red, orange, yellow, green, blue, indigo, cyan, teal, mint, purple, pink, brown
    
    var color: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        case .indigo: return .indigo
        case .cyan: return .cyan
        case .teal: return .teal
        case .mint: return .mint
        case .purple: return .purple
        case .pink: return .pink
        case .brown: return .brown
        }
    }
}

let accentColors: [AccentColor] = AccentColor.allCases

class Settings: ObservableObject {
    static let shared = Settings()
    private var appGroupUserDefaults: UserDefaults?
    
    init() {
        self.appGroupUserDefaults = UserDefaults(suiteName: "group.com.IslamicPillars.AppGroup")
        
        self.accentColor = AccentColor(rawValue: appGroupUserDefaults?.string(forKey: "accentColor") ?? "green") ?? .green
        if appGroupUserDefaults?.object(forKey: "accentColor") == nil {
            appGroupUserDefaults?.set("green", forKey: "accentColor")
        }
        
        self.beginnerMode = appGroupUserDefaults?.bool(forKey: "beginnerMode") ?? false
        if appGroupUserDefaults?.object(forKey: "beginnerMode") == nil {
            appGroupUserDefaults?.set(false, forKey: "beginnerMode")
        }
        
        self.lastReadSurah = appGroupUserDefaults?.integer(forKey: "lastReadSurah") ?? 0
        if appGroupUserDefaults?.object(forKey: "lastReadSurah") == nil {
            appGroupUserDefaults?.set(0, forKey: "lastReadSurah")
        }
        self.lastReadAyah = appGroupUserDefaults?.integer(forKey: "lastReadAyah") ?? 0
        if appGroupUserDefaults?.object(forKey: "lastReadAyah") == nil {
            appGroupUserDefaults?.set(0, forKey: "lastReadAyah")
        }
        
        self.favoriteSurahsData = appGroupUserDefaults?.data(forKey: "favoriteSurahsData") ?? Data()
        self.bookmarkedAyahsData = appGroupUserDefaults?.data(forKey: "bookmarkedAyahsData") ?? Data()
        
        if let hijriDate = try? JSONDecoder().decode(HijriDate.self, from: currentHijriDateData) {
            currentHijriDate = hijriDate
        }
        updateDates()
    }
    
    func arabicNumberString(from numberString: String) -> String {
        let arabicNumbers = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
        
        var arabicNumberString = ""
        for character in numberString {
            if let digit = Int(String(character)) {
                arabicNumberString += arabicNumbers[digit]
            } else {
                arabicNumberString += String(character)
            }
        }
        return arabicNumberString
    }
    
    func formatArabicDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "ar")
        let dateInEnglish = formatter.string(from: date)
        return arabicNumberString(from: dateInEnglish)
    }
    
    private let hijriDateFormatterArabic: DateFormatter = {
        let formatter = DateFormatter()
        var hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
        hijriCalendar.locale = Locale(identifier: "ar")
        formatter.calendar = hijriCalendar
        formatter.dateFormat = "d MMMM، yyyy"
        formatter.locale = Locale(identifier: "ar")
        return formatter
    }()
    
    private let hijriDateFormatterEnglish: DateFormatter = {
        let formatter = DateFormatter()
        var hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
        hijriCalendar.locale = Locale(identifier: "ar")
        formatter.calendar = hijriCalendar
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "en")
        return formatter
    }()
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    func updateDates() {
        let currentDate = Date()
        
        if currentHijriDate == nil || !currentDate.isSameDay(as: currentHijriDate?.day ?? Date()) {
            var hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
            hijriCalendar.locale = Locale(identifier: "ar")
            
            let hijriComponents = hijriCalendar.dateComponents([.year, .month, .day], from: currentDate)
            let newHijriDate = hijriCalendar.date(from: hijriComponents) ?? currentDate
            
            currentHijriDate = HijriDate(day: currentDate, arabic: hijriDateFormatterArabic.string(from: newHijriDate) + " هـ", english: hijriDateFormatterEnglish.string(from: newHijriDate))
        }
    }
    
    func hapticFeedback() {
        if hapticOn { UIImpactFeedbackGenerator(style: hapticType == "light" ? .light : hapticType == "medium" ? .medium : .heavy).impactOccurred() }
    }
    
    @Published var accentColor: AccentColor {
        didSet { appGroupUserDefaults?.setValue(accentColor.rawValue, forKey: "accentColor") }
    }
    
    @Published var beginnerMode: Bool {
        didSet { appGroupUserDefaults?.setValue(beginnerMode, forKey: "beginnerMode") }
    }
    
    @Published var lastReadSurah: Int {
        didSet { appGroupUserDefaults?.setValue(lastReadSurah, forKey: "lastReadSurah") }
    }
    
    @Published var lastReadAyah: Int {
        didSet { appGroupUserDefaults?.setValue(lastReadAyah, forKey: "lastReadAyah") }
    }
    
    @Published var favoriteSurahsData: Data {
        didSet {
            appGroupUserDefaults?.setValue(favoriteSurahsData, forKey: "favoriteSurahsData")
        }
    }
    var favoriteSurahs: [Int] {
        get {
            let decoder = JSONDecoder()
            return (try? decoder.decode([Int].self, from: favoriteSurahsData)) ?? []
        }
        set {
            let encoder = JSONEncoder()
            favoriteSurahsData = (try? encoder.encode(newValue)) ?? Data()
        }
    }
    
    @Published var bookmarkedAyahsData: Data {
        didSet {
            appGroupUserDefaults?.setValue(bookmarkedAyahsData, forKey: "bookmarkedAyahsData")
        }
    }
    var bookmarkedAyahs: [BookmarkedAyah] {
        get {
            let decoder = JSONDecoder()
            return (try? decoder.decode([BookmarkedAyah].self, from: bookmarkedAyahsData)) ?? []
        }
        set {
            let encoder = JSONEncoder()
            bookmarkedAyahsData = (try? encoder.encode(newValue)) ?? Data()
        }
    }
    
    func dictionaryRepresentation() -> [String: Any] {
        let encoder = JSONEncoder()
        var dict: [String: Any] = [
            "accentColor": self.accentColor.rawValue,
            
            "beginnerMode": self.beginnerMode,
            "lastReadSurah": self.lastReadSurah,
            "lastReadAyah": self.lastReadAyah,
        ]
        
        do {
            dict["favoriteSurahsData"] = try encoder.encode(self.favoriteSurahs)
        } catch {
            print("Error encoding favoriteSurahs: \(error)")
        }
        
        do {
            dict["bookmarkedAyahsData"] = try encoder.encode(self.bookmarkedAyahs)
        } catch {
            print("Error encoding bookmarkedAyahs: \(error)")
        }
        
        return dict
    }
    
    func update(from dict: [String: Any]) {
        let decoder = JSONDecoder()
        if let accentColor = dict["accentColor"] as? String,
           let accentColorValue = AccentColor(rawValue: accentColor) {
            self.accentColor = accentColorValue
        }
        if let beginnerMode = dict["beginnerMode"] as? Bool {
            self.beginnerMode = beginnerMode
        }
        if let lastReadSurah = dict["lastReadSurah"] as? Int {
            self.lastReadSurah = lastReadSurah
        }
        if let lastReadAyah = dict["lastReadAyah"] as? Int {
            self.lastReadAyah = lastReadAyah
        }
        if let favoriteSurahsData = dict["favoriteSurahsData"] as? Data {
            self.favoriteSurahs = (try? decoder.decode([Int].self, from: favoriteSurahsData)) ?? []
        }
        if let bookmarkedAyahsData = dict["bookmarkedAyahsData"] as? Data {
            self.bookmarkedAyahs = (try? decoder.decode([BookmarkedAyah].self, from: bookmarkedAyahsData)) ?? []
        }
    }
    
    @AppStorage("hapticOn") var hapticOn: Bool = true
    @AppStorage("hapticType") var hapticType: String = "light"
    
    @AppStorage("defaultView") var defaultView: Bool = true
    
    @AppStorage("firstLaunch") var firstLaunch = true
    
    @AppStorage("useSystemFontSize") var useSystemFontSize: Bool = true
    
    @AppStorage("groupBySurah") var groupBySurah: Bool = true
    @AppStorage("searchForSurahs") var searchForSurahs: Bool = true
        
    @AppStorage("showArabicText") var showArabicText: Bool = true
    @AppStorage("cleanArabicText") var cleanArabicText: Bool = false
    @AppStorage("arabicFont") var arabicFont: String = "KFGQPCUthmanicScriptHAFS"
    @AppStorage("arabicFontSize") var arabicFontSize: Double = Double(UIFont.preferredFont(forTextStyle: .body).pointSize) + 10
    
    @AppStorage("showTransliteration") var showTransliteration: Bool = true
    @AppStorage("showEnglishTranslation") var showEnglishTranslation: Bool = true
    
    @AppStorage("englishFontSize") var englishFontSize: Double = Double(UIFont.preferredFont(forTextStyle: .body).pointSize) {
        didSet {
            if useSystemFontSize && englishFontSize != Double(UIFont.preferredFont(forTextStyle: .body).pointSize) {
                useSystemFontSize = false
            }
        }
    }
    
    @AppStorage("currentHijriDate") var currentHijriDateData: Data = Data() {
        didSet {
            if let newHijriDate = try? JSONDecoder().decode(HijriDate.self, from: currentHijriDateData) {
                currentHijriDate = newHijriDate
            } else {
                currentHijriDate = nil
            }
        }
    }
    
    var currentHijriDate: HijriDate? {
        didSet {
            if let currentHijriDate = currentHijriDate,
               let data = try? JSONEncoder().encode(currentHijriDate),
               currentHijriDateData != data {
                currentHijriDateData = data
            } else if currentHijriDate == nil {
                currentHijriDateData = Data()
            }
        }
    }
    
    func toggleSurahFavorite(surah: Surah) {
        if isSurahFavorite(surah: surah) {
            favoriteSurahs.removeAll(where: { $0 == surah.id })
        } else {
            favoriteSurahs.append(surah.id)
        }
    }
    
    func isSurahFavorite(surah: Surah) -> Bool {
        return favoriteSurahs.contains(surah.id)
    }
    
    func toggleBookmark(surah: Int, ayah: Int) {
        let bookmark = BookmarkedAyah(surah: surah, ayah: ayah)
        if let index = bookmarkedAyahs.firstIndex(where: {$0.id == bookmark.id}) {
            bookmarkedAyahs.remove(at: index)
        } else {
            bookmarkedAyahs.append(bookmark)
        }
    }
    
    func isBookmarked(surah: Int, ayah: Int) -> Bool {
        let bookmark = BookmarkedAyah(surah: surah, ayah: ayah)
        return bookmarkedAyahs.contains(where: {$0.id == bookmark.id})
    }
}

func arabicNumberString(from number: Int) -> String {
    let arabicNumbers = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
    let numberString = String(number)
    
    var arabicNumberString = ""
    for character in numberString {
        if let digit = Int(String(character)) {
            arabicNumberString += arabicNumbers[digit]
        }
    }
    return arabicNumberString
}
