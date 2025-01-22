import Foundation
import SwiftUI

struct Juz: Codable, Identifiable {
    let id: Int
    let nameArabic: String
    let nameTransliteration: String
    let startSurah: Int
    let endSurah: Int
    var surahs: [Surah]?
}

struct Surah: Codable, Identifiable {
    let id: Int
    let nameArabic: String
    let nameTransliteration: String
    let nameEnglish: String
    let type: String
    let numberOfAyahs: Int
    var ayahs: [Ayah]
    
    enum CodingKeys: String, CodingKey {
        case id
        case nameArabic = "name"
        case nameTransliteration = "transliteration"
        case nameEnglish = "translation"
        case type = "type"
        case numberOfAyahs = "total_verses"
        case ayahs = "verses"
    }
}

struct Ayah: Codable, Identifiable {
    let id: Int
    let textArabic: String
    var textClearArabic: String { textArabic.removingArabicDiacriticsAndSigns }
    let textTransliteration: String?
    var textEnglish: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case textArabic = "text"
        case textTransliteration = "transliteration"
        case textEnglish = "translation"
    }
}

struct BookmarkedAyah: Codable, Identifiable, Equatable {
    var id: String { "\(surah)-\(ayah)" }
    var surah: Int
    var ayah: Int
}

class QuranData: ObservableObject {
    @Published var quran: [Surah] = []
    
    var juzList: [Juz] = [
        Juz(id: 1, nameArabic: "آلم", nameTransliteration: "Alif Lam Meem", startSurah: 1, endSurah: 2),
        Juz(id: 2, nameArabic: "سَيَقُولُ", nameTransliteration: "Sayaqoolu", startSurah: 2, endSurah: 2),
        Juz(id: 3, nameArabic: "تِلْكَ ٱلْرُّسُلُ", nameTransliteration: "Tilka Rusulu", startSurah: 2, endSurah: 3),
        Juz(id: 4, nameArabic: "ْلَنْ تَنالُوا", nameTransliteration: "Lan Tanaaloo", startSurah: 3, endSurah: 4),
        Juz(id: 5, nameArabic: "وَٱلْمُحْصَنَاتُ", nameTransliteration: "Walmohsanaatu", startSurah: 4, endSurah: 4),
        Juz(id: 6, nameArabic: "لَا يُحِبُّ ٱللهُ", nameTransliteration: "Laa Yuhibbu Allahu", startSurah: 4, endSurah: 5),
        Juz(id: 7, nameArabic: "ْوَإِذَا سَمِعُوا", nameTransliteration: "Waidhaa Samioo", startSurah: 5, endSurah: 6),
        Juz(id: 8, nameArabic: "وَلَوْ أَنَّنَا", nameTransliteration: "Walau Annanaa", startSurah: 6, endSurah: 7),
        Juz(id: 9, nameArabic: "قَالَ ٱلْمَلَأُ", nameTransliteration: "Qaalal-Mala'u", startSurah: 7, endSurah: 8),
        Juz(id: 10, nameArabic: "وَٱعْلَمُواْ", nameTransliteration: "Wa'alamu", startSurah: 8, endSurah: 9),
        Juz(id: 11, nameArabic: "يَعْتَذِرُونَ", nameTransliteration: "Ya'atadheroon", startSurah: 9, endSurah: 11),
        Juz(id: 12, nameArabic: "وَمَا مِنْ دَآبَّةٍ", nameTransliteration: "Wamaa Min Da'abatin", startSurah: 11, endSurah: 12),
        Juz(id: 13, nameArabic: "وَمَا أُبَرِّئُ", nameTransliteration: "Wamaa Ubari'oo", startSurah: 12, endSurah: 14),
        Juz(id: 14, nameArabic: "رُبَمَا", nameTransliteration: "Rubamaa", startSurah: 15, endSurah: 16),
        Juz(id: 15, nameArabic: "سُبْحَانَ ٱلَّذِى", nameTransliteration: "Subhana Allathee", startSurah: 17, endSurah: 18),
        Juz(id: 16, nameArabic: "قَالَ أَلَمْ", nameTransliteration: "Qaala Alam", startSurah: 18, endSurah: 20),
        Juz(id: 17, nameArabic: "ٱقْتَرَبَ لِلْنَّاسِ", nameTransliteration: "Iqtaraba Linnaasi", startSurah: 21, endSurah: 22),
        Juz(id: 18, nameArabic: "قَدْ أَفْلَحَ", nameTransliteration: "Qad Aflaha", startSurah: 23, endSurah: 25),
        Juz(id: 19, nameArabic: "وَقَالَ ٱلَّذِينَ", nameTransliteration: "Waqaal Alladheena", startSurah: 25, endSurah: 27),
        Juz(id: 20, nameArabic: "أَمَّنْ خَلَقَ", nameTransliteration: "A'man Khalaqa", startSurah: 27, endSurah: 29),
        Juz(id: 21, nameArabic: "أُتْلُ مَاأُوْحِیَ", nameTransliteration: "Utlu Maa Oohia", startSurah: 29, endSurah: 33),
        Juz(id: 22, nameArabic: "وَمَنْ يَّقْنُتْ", nameTransliteration: "Waman Yaqnut", startSurah: 33, endSurah: 36),
        Juz(id: 23, nameArabic: "وَمَآ لِي", nameTransliteration: "Wamaa Lee", startSurah: 36, endSurah: 39),
        Juz(id: 24, nameArabic: "فَمَنْ أَظْلَمُ", nameTransliteration: "Faman Adhlamu", startSurah: 39, endSurah: 41),
        Juz(id: 25, nameArabic: "إِلَيْهِ يُرَدُّ", nameTransliteration: "Ilayhi Yuraddu", startSurah: 41, endSurah: 45),
        Juz(id: 26, nameArabic: "حم", nameTransliteration: "Haaa Meem", startSurah: 46, endSurah: 51),
        Juz(id: 27, nameArabic: "قَالَ فَمَا خَطْبُكُم", nameTransliteration: "Qaala Famaa Khatbukum", startSurah: 51, endSurah: 57),
        Juz(id: 28, nameArabic: "قَدْ سَمِعَ ٱللهُ", nameTransliteration: "Qadd Samia Allahu", startSurah: 58, endSurah: 66),
        Juz(id: 29, nameArabic: "تَبَارَكَ ٱلَّذِى", nameTransliteration: "Tabaraka Alladhee", startSurah: 67, endSurah: 77),
        Juz(id: 30, nameArabic: "عَمَّ", nameTransliteration: "'Amma", startSurah: 78, endSurah: 114)
    ]
    
    init() {
        loadQuranData()
    }
    
    private func loadQuranData() {
        guard let quranUrl = Bundle.main.url(forResource: "quran", withExtension: "json"),
              let quranEnUrl = Bundle.main.url(forResource: "quran_en", withExtension: "json") else {
            return
        }
        
        do {
            let quranData = try Data(contentsOf: quranUrl)
            let quranEnData = try Data(contentsOf: quranEnUrl)
            
            var quran = try JSONDecoder().decode([Surah].self, from: quranData)
            let quranEn = try JSONDecoder().decode([Surah].self, from: quranEnData)
            
            for (index, surah) in quran.enumerated() {
                if let matchingSurah = quranEn.first(where: { $0.id == surah.id }) {
                    for (ayahIndex, ayah) in surah.ayahs.enumerated() {
                        if let matchingAyah = matchingSurah.ayahs.first(where: { $0.id == ayah.id }) {
                            quran[index].ayahs[ayahIndex].textEnglish = matchingAyah.textEnglish
                        }
                    }
                }
            }
            
            for (index, _) in juzList.enumerated() {
                juzList[index].surahs = quran.filter { $0.id >= juzList[index].startSurah && $0.id <= juzList[index].endSurah }
            }
            
            DispatchQueue.main.async {
                self.quran = quran
            }
        } catch {
            print("Error: \(error)")
        }
    }
}

extension String {
    var removingArabicDiacriticsAndSigns: String {
        let diacriticRange = UnicodeScalar("ً")...UnicodeScalar("ٓ")
        let quranicSignsRange = UnicodeScalar("ۖ")...UnicodeScalar("۩")
        let shortAlif = UnicodeScalar("ٰ")
        let daggerAlif = UnicodeScalar("ٗ")
        let hamzatulWasl = UnicodeScalar("ٱ")
        let regularAlif = UnicodeScalar("ا")
        let maddaSign = UnicodeScalar("ٞ")
        let openTaMarbutaSign = UnicodeScalar("ٖ")
        return self.unicodeScalars.map { scalar in
            if scalar == hamzatulWasl {
                return regularAlif
            } else if diacriticRange.contains(scalar) || quranicSignsRange.contains(scalar) || scalar == shortAlif || scalar == daggerAlif || scalar == maddaSign || scalar == openTaMarbutaSign {
                return nil
            } else {
                return scalar
            }
        }.compactMap { $0 }.map { Character($0) }.reduce("") { $0 + String($1) }
    }
    
    subscript(_ range: Range<Int>) -> Substring {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = index(self.startIndex, offsetBy: range.upperBound)
        return self[startIndex..<endIndex]
    }
}
