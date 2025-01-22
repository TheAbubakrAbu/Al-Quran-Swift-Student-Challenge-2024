import SwiftUI
import UIKit
import Combine
import AVFoundation

struct SurahSectionHeader: View {
    @EnvironmentObject var settings: Settings
    
    var surah: Surah
    
    var body: some View {
        HStack {
            Text("\(surah.numberOfAyahs) Ayahs - \(surah.type) \(surah.type == "meccan" ? "🕋" : "🕌")")
                .textCase(.uppercase)
                .font(.subheadline)
            
            Spacer()
            
            Image(systemName: settings.isSurahFavorite(surah: surah) ? "star.fill" : "star")
                .foregroundColor(settings.accentColor.color)
                .font(.subheadline)
                .onTapGesture {
                    settings.hapticFeedback()
                    
                    settings.toggleSurahFavorite(surah: surah)
                }
        }
    }
}

struct HeaderRow: View {
    @EnvironmentObject var settings: Settings
    
    let arabicText: String
    let englishTransliteration: String
    let englishTranslation: String
    
    @State private var ayahBeginnerMode: Bool = false
    
    func arabicTextWithSpacesIfNeeded(_ text: String) -> String {
        if settings.beginnerMode || ayahBeginnerMode {
            return text.map { "\($0) " }.joined()
        }
        return text
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Text(arabicTextWithSpacesIfNeeded(settings.cleanArabicText ? arabicText.removingArabicDiacriticsAndSigns : arabicText))
                .foregroundColor(settings.accentColor.color)
                .font(.custom(settings.arabicFont, size: CGFloat(settings.arabicFontSize)))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
            
            if settings.showTransliteration {
                Text(englishTransliteration)
                    .foregroundColor(settings.accentColor.color)
                    .font(.system(size: settings.englishFontSize))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.55))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
            }
            
            if settings.showEnglishTranslation {
                Text(englishTranslation)
                    .foregroundColor(settings.accentColor.color)
                    .font(.system(size: settings.englishFontSize))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.55))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
            }
        }
        .contextMenu {
            if !settings.beginnerMode {
                Button(action: {
                    settings.hapticFeedback()
                    
                    ayahBeginnerMode.toggle()
                }) {
                    Label("Beginner Mode", systemImage: ayahBeginnerMode ? "textformat.size.larger.ar" : "textformat.size.ar")
                }
            }
        }
    }
}

struct AyahRow: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var quranData: QuranData
    
    @State private var ayahBeginnerMode = false
    
    var surah: Surah
    var ayah: Ayah
    
    @Binding var scrollDown: Int?
    
    func arabicTextWithSpacesIfNeeded(_ text: String) -> String {
        if settings.beginnerMode || ayahBeginnerMode {
            return text.map { "\($0) " }.joined()
        }
        return text
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("\(arabicNumberString(from: ayah.id))")
                    .foregroundColor(settings.accentColor.color)
                    .font(.custom("KFGQPCUthmanicScriptHAFS", size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize))
                
                Spacer()
                
                if(settings.isBookmarked(surah: surah.id, ayah: ayah.id)) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(settings.accentColor.color)
                        .font(.system(size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                }
                
                Menu {
                    Button(action: {
                        settings.hapticFeedback()
                        
                        settings.toggleBookmark(surah: surah.id, ayah: ayah.id)
                    }) {
                        Label(settings.isBookmarked(surah: surah.id, ayah: ayah.id) ? "Unbookmark" : "Bookmark", systemImage: settings.isBookmarked(surah: surah.id, ayah: ayah.id) ? "bookmark.fill" : "bookmark")
                    }
                    
                    if settings.showArabicText && !settings.beginnerMode {
                        Button(action: {
                            settings.hapticFeedback()
                            
                            ayahBeginnerMode.toggle()
                        }) {
                            Label( "Beginner Mode", systemImage: ayahBeginnerMode ? "textformat.size.larger.ar" : "textformat.size.ar")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: UIFont.preferredFont(forTextStyle: .title2).pointSize))
                        .foregroundColor(settings.accentColor.color)
                }
            }
            .padding(.vertical, -10)
            
            VStack {
                if settings.showArabicText {
                    Text(arabicTextWithSpacesIfNeeded(settings.cleanArabicText ? ayah.textClearArabic : ayah.textArabic))
                        .font(.custom(settings.arabicFont, size: CGFloat(settings.arabicFontSize)))
                        .lineLimit(nil)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.vertical, 4)
                }
                
                if settings.showTransliteration {
                    Text("\(ayah.id). \(ayah.textTransliteration ?? "")")
                        .font(.system(size: settings.englishFontSize))
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                }
                
                if settings.showEnglishTranslation {
                    let englishText = settings.showTransliteration ? ayah.textEnglish : "\(ayah.id). \(ayah.textEnglish ?? "")"
                    Text(englishText ?? "")
                        .font(.system(size: settings.englishFontSize))
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .onTapGesture {
                scrollDown = ayah.id
            }
        }
        .lineLimit(nil)
        .contextMenu {
            Button(action: {
                settings.hapticFeedback()
                
                settings.toggleBookmark(surah: surah.id, ayah: ayah.id)
            }) {
                Label(settings.isBookmarked(surah: surah.id, ayah: ayah.id) ? "Unbookmark" : "Bookmark", systemImage: settings.isBookmarked(surah: surah.id, ayah: ayah.id) ? "bookmark.fill" : "bookmark")
            }
            
            if settings.showArabicText && !settings.beginnerMode {
                Button(action: {
                    settings.hapticFeedback()
                    
                    ayahBeginnerMode.toggle()
                }) {
                    Label( "Beginner Mode", systemImage: ayahBeginnerMode ? "textformat.size.larger.ar" : "textformat.size.ar")
                }
            }
        }
    }
}

struct AyahsView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var quranData: QuranData
    
    @State private var searchText = ""
    @State private var lastAyahViewed: Int? = 1
    @State private var scrollDown: Int? = nil
    @State private var filteredAyahs: [Ayah] = []
    
    let surah: Surah
    var ayah: Int? = 0
    
    func cleanSearch(_ text: String) -> String {
        let unwantedChars: [Character] = ["[", "]", "(", ")", "-", "'", "\""]
        let cleaned = text.filter { !unwantedChars.contains($0) }
        return cleaned.lowercased()
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                List {
                    Section(header: SurahSectionHeader(surah: surah)) {
                        if searchText.isEmpty {
                            VStack {
                                VStack {
                                    if surah.id == 1 || surah.id == 9 {
                                        HeaderRow(arabicText: "أَعُوذُ بِٱللَّهِ مِنَ ٱلشَّيْطَانِ ٱلرَّجِيمِ", englishTransliteration: "Audhu billahi minashaitanir rajeem", englishTranslation: "I seek refuge in Allah from the accursed Satan.")
                                            .padding(.vertical)
                                    } else {
                                        HeaderRow(arabicText: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ", englishTransliteration: "Bismi Allahi alrrahmani alrraheemi", englishTranslation: "In the name of Allah, the Compassionate, the Merciful.")
                                            .padding(.vertical)
                                    }
                                }
                                .listRowSeparator(.hidden, edges: .bottom)
                                
                                Divider()
                                    .background(settings.accentColor.color)
                                    .padding(.trailing, -100)
                                    .padding(.bottom, -100)
                            }
                        }
                        
                        let filteredAyahs = surah.ayahs.filter { ayah in
                            let cleanSearchText = cleanSearch(searchText)
                            return searchText.isEmpty || cleanSearch(ayah.textClearArabic).contains(cleanSearchText) || cleanSearch(ayah.textTransliteration ?? "").contains(cleanSearchText) || cleanSearch(ayah.textEnglish ?? "").contains(cleanSearchText) || cleanSearch(String(ayah.id)).contains(cleanSearchText) || cleanSearch(arabicNumberString(from: ayah.id)).contains(cleanSearchText) || Int(cleanSearchText) == ayah.id
                        }
                        
                        ForEach(filteredAyahs, id: \.id) { ayah in
                            VStack {
                                AyahRow(surah: surah, ayah: ayah, scrollDown: $scrollDown)
                                    .id(ayah.id)
                                    .onChange(of: scrollDown) { value in
                                        if let ayahID = value {
                                            if !searchText.isEmpty {
                                                settings.hapticFeedback()
                                                
                                                UIApplication.shared.endEditing()
                                                searchText = ""
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                    withAnimation {
                                                        proxy.scrollTo(ayahID, anchor: .top)
                                                    }
                                                }
                                            }
                                            scrollDown = nil
                                        }
                                    }
                                    .onDisappear {
                                        self.lastAyahViewed = ayah.id
                                    }
                            }
                            .listRowSeparator(ayah.id == filteredAyahs.first?.id && searchText.isEmpty ? .hidden : .visible, edges: .top)
                            .listRowSeparator(ayah.id == filteredAyahs.last?.id ? .hidden : .visible, edges: .bottom)
                        }
                    }
                }
                .gesture(DragGesture().onChanged({ _ in
                    UIApplication.shared.endEditing()
                }))
                .onAppear {
                    if let selectedAyah = ayah {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            withAnimation {
                                proxy.scrollTo(selectedAyah, anchor: .top)
                            }
                        }
                    }
                }
                
                HStack {
                    SearchBar(text: $searchText)
                        .padding(.horizontal, 8)
                }
            }
        }
        .onDisappear {
            settings.lastReadSurah = surah.id
            if let lastAyah = lastAyahViewed {
                settings.lastReadAyah = lastAyah
            }
        }
        .navigationTitle(surah.nameEnglish)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
                                VStack(alignment: .trailing) {
            Text("\(surah.nameArabic) - \(arabicNumberString(from: surah.id))")
                .font(.footnote)
                .foregroundColor(settings.accentColor.color)
            
            Text("\(surah.nameTransliteration) - \(surah.id)")
                .font(.footnote)
                .foregroundColor(settings.accentColor.color)
        }
        )
    }
}
