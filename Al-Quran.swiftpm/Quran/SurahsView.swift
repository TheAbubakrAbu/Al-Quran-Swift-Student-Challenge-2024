import SwiftUI

struct SurahRow: View {
    @EnvironmentObject var settings: Settings
    
    var surah: Surah
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("\(surah.numberOfAyahs) Ayahs")
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.secondary)
                    Text(surah.type == "meccan" ? "🕋" : "🕌")
                        .font(.caption2)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(settings.accentColor.color)
                }
                
                Text(surah.nameEnglish)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(surah.nameArabic) - \(arabicNumberString(from: surah.id))")
                    .font(.headline)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(settings.accentColor.color)
                Text("\(surah.nameTransliteration) - \(surah.id)")
                    .font(.subheadline)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.vertical, 8)
        }
    }
}

struct SurahsView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var quranData: QuranData
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showingSettingsSheet = false
    @State private var searchText = ""
    @State private var scrollToSurahID: Int? = nil
    
    var lastReadSurah: Surah? {
        quranData.quran.first(where: { $0.id == settings.lastReadSurah })
    }
    
    var lastReadAyah: Ayah? {
        lastReadSurah?.ayahs.first(where: { $0.id == settings.lastReadAyah })
    }
    
    func cleanSearch(_ text: String) -> String {
        let unwantedChars: [Character] = ["[", "]", "(", ")", "-", "'", "\""]
        let cleaned = text.filter { !unwantedChars.contains($0) }
        return (cleaned.applyingTransform(.stripDiacritics, reverse: false) ?? cleaned).lowercased()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { scrollProxy in
                    List {
                        if let currentDate = settings.currentHijriDate {
                            HStack {
                                Text(currentDate.english)
                                    .multilineTextAlignment(.center)
                                
                                Spacer()
                                
                                Text(currentDate.arabic)
                            }
                            .font(.footnote)
                            .foregroundColor(settings.accentColor.color)
                            .contextMenu {
                                Button(action: {
                                    settings.hapticFeedback()
                                    
                                    UIPasteboard.general.string = currentDate.english
                                }) {
                                    Text("Copy English Date")
                                    Image(systemName: "doc.on.doc")
                                }
                                
                                Button(action: {
                                    settings.hapticFeedback()
                                    
                                    UIPasteboard.general.string = currentDate.arabic
                                }) {
                                    Text("Copy Arabic Date")
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                        }
                        
                        if searchText.isEmpty, let lastReadSurah = lastReadSurah, let lastReadAyah = lastReadAyah {
                            Section(header: Text("LAST READ AYAH")) {
                                NavigationLink(destination: AyahsView(surah: lastReadSurah, ayah: lastReadAyah.id)) {
                                    HStack {
                                        Text("\(lastReadSurah.id):\(lastReadAyah.id)")
                                            .font(.headline)
                                            .foregroundColor(settings.accentColor.color)
                                            .padding(.trailing, 8)
                                        
                                        VStack {
                                            if(settings.showArabicText) {
                                                Text(lastReadAyah.textArabic)
                                                    .font(.subheadline)
                                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                                    .lineLimit(1)
                                            }
                                            
                                            if(settings.showTransliteration) {
                                                Text(lastReadAyah.textTransliteration ?? "")
                                                    .font(.subheadline)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .lineLimit(1)
                                            }
                                            
                                            if(settings.showEnglishTranslation) {
                                                Text(lastReadAyah.textEnglish ?? "")
                                                    .font(.subheadline)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 2)
                                    .contextMenu {
                                        Button(action: {
                                            settings.hapticFeedback()
                                            
                                            settings.lastReadSurah = 0
                                            settings.lastReadAyah = 0
                                        }) {
                                            Label("Remove", systemImage: "trash")
                                        }
                                        
                                        Button(action: {
                                            settings.hapticFeedback()
                                            
                                            settings.toggleBookmark(surah: lastReadSurah.id, ayah: lastReadAyah.id)
                                        }) {
                                            Label(settings.isBookmarked(surah: lastReadSurah.id, ayah: lastReadAyah.id) ? "Unbookmark" : "Bookmark", systemImage: settings.isBookmarked(surah: lastReadSurah.id, ayah: lastReadAyah.id) ? "bookmark.fill" : "bookmark")
                                        }
                                    }
                                }
                            }
                        }
                        
                        if !settings.bookmarkedAyahs.isEmpty && searchText.isEmpty {
                            Section(header: Text("BOOKMARKED AYAHS")) {
                                ForEach(settings.bookmarkedAyahs.sorted {
                                    if $0.surah == $1.surah {
                                        return $0.ayah < $1.ayah
                                    } else {
                                        return $0.surah < $1.surah
                                    }
                                }, id: \.id) { bookmarkedAyah in
                                    let surah = quranData.quran.first(where: { $0.id == bookmarkedAyah.surah })
                                    let ayah = surah?.ayahs.first(where: { $0.id == bookmarkedAyah.ayah })
                                    
                                    if let surah = surah, let ayah = ayah {
                                        NavigationLink(destination: AyahsView(surah: surah, ayah: ayah.id)) {
                                            HStack {
                                                Text("\(bookmarkedAyah.surah):\(bookmarkedAyah.ayah)")
                                                    .font(.headline)
                                                    .foregroundColor(settings.accentColor.color)
                                                    .padding(.trailing, 8)
                                                
                                                VStack {
                                                    if(settings.showArabicText) {
                                                        Text(ayah.textArabic)
                                                            .font(.subheadline)
                                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                                            .lineLimit(1)
                                                    }
                                                    
                                                    if(settings.showTransliteration) {
                                                        Text(ayah.textTransliteration ?? "")
                                                            .font(.subheadline)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .lineLimit(1)
                                                    }
                                                    
                                                    if(settings.showEnglishTranslation) {
                                                        Text(ayah.textEnglish ?? "")
                                                            .font(.subheadline)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .lineLimit(1)
                                                    }
                                                }
                                            }
                                            .padding(.vertical, 2)
                                        }
                                        .contextMenu {
                                            Button(action: {
                                                settings.hapticFeedback()
                                                
                                                settings.toggleBookmark(surah: surah.id, ayah: ayah.id)
                                            }) {
                                                Label(settings.isBookmarked(surah: surah.id, ayah: ayah.id) ? "Unbookmark" : "Bookmark", systemImage: settings.isBookmarked(surah: surah.id, ayah: ayah.id) ? "bookmark.fill" : "bookmark")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if !settings.favoriteSurahs.isEmpty && searchText.isEmpty {
                            Section(header: Text("FAVORITE SURAHS")) {
                                ForEach(settings.favoriteSurahs.sorted(), id: \.self) { surahId in
                                    if let surah = quranData.quran.first(where: { $0.id == surahId }) {
                                        NavigationLink(destination: AyahsView(surah: surah)) {
                                            SurahRow(surah: surah)
                                        }
                                        .contextMenu {
                                            Button(action: {
                                                settings.hapticFeedback()
                                                
                                                settings.toggleSurahFavorite(surah: surah)
                                            }) {
                                                Label(settings.isSurahFavorite(surah: surah) ? "Unfavorite" : "Favorite", systemImage: settings.isSurahFavorite(surah: surah) ? "star.fill" : "star")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if settings.groupBySurah || (!searchText.isEmpty && settings.searchForSurahs) {
                            Section(header: searchText.isEmpty ? Text("SURAHS") : Text("SURAH SEARCH RESULTS")) {
                                ForEach(quranData.quran.filter { surah in
                                    let cleanSearchText = cleanSearch(searchText)
                                    return searchText.isEmpty || searchText.uppercased().contains(surah.nameEnglish.uppercased()) || searchText.uppercased().contains(surah.nameTransliteration.uppercased()) || cleanSearch(surah.nameArabic).contains(cleanSearchText) || cleanSearch(surah.nameTransliteration).contains(cleanSearchText) || cleanSearch(surah.nameEnglish).contains(cleanSearchText) || cleanSearch(String(surah.id)).contains(cleanSearchText) || cleanSearch(arabicNumberString(from: surah.id)).contains(cleanSearchText) || Int(cleanSearchText) == surah.id
                                }) { surah in
                                    NavigationLink(destination: AyahsView(surah: surah)) {
                                        SurahRow(surah: surah)
                                    }
                                    .id(surah.id)
                                    .onAppear {
                                        if surah.id == scrollToSurahID {
                                            scrollToSurahID = nil
                                        }
                                    }
                                    .contextMenu {
                                        Button(action: {
                                            settings.hapticFeedback()
                                            
                                            settings.toggleSurahFavorite(surah: surah)
                                        }) {
                                            Label(settings.isSurahFavorite(surah: surah) ? "Unfavorite" : "Favorite", systemImage: settings.isSurahFavorite(surah: surah) ? "star.fill" : "star")
                                        }
                                        
                                        Button(action: {
                                            settings.hapticFeedback()
                                            
                                            searchText = ""
                                            
                                            scrollToSurahID = surah.id
                                        }) {
                                            Text("Scroll To")
                                            Image(systemName: "arrow.down.circle.fill")
                                        }
                                    }
                                }
                            }
                        } else {
                               ForEach(quranData.juzList, id: \.id) { juz in
                                   let surahsInJuz = juz.surahs ?? []
                                   
                                   Section(header: Text("JUZ \(juz.id) - \(juz.nameTransliteration.uppercased())")) {
                                       ForEach(surahsInJuz) { surah in
                                           NavigationLink(destination: AyahsView(surah: surah)) {
                                               SurahRow(surah: surah)
                                           }
                                           .contextMenu {
                                               Button(action: {
                                                   settings.hapticFeedback()
                                                   
                                                   settings.toggleSurahFavorite(surah: surah)
                                               }) {
                                                   Label(settings.isSurahFavorite(surah: surah) ? "Unfavorite" : "Favorite", systemImage: settings.isSurahFavorite(surah: surah) ? "star.fill" : "star")
                                               }
                                           }
                                       }
                                   }
                               }
                           }
                    }
                    .gesture(DragGesture().onChanged({ _ in
                        UIApplication.shared.endEditing()
                    }))
                    .onAppear {
                        settings.updateDates()
                    }
                    .onChange(of: scenePhase) { newScenePhase in
                        if newScenePhase == .active {
                            settings.updateDates()
                        }
                    }
                    .onChange(of: scrollToSurahID) { newValue in
                        if let id = newValue {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    scrollProxy.scrollTo(id, anchor: .top)
                                }
                            }
                        }
                    }
                }
                
                VStack {
                    if searchText.isEmpty {
                        Picker("Sort Type", selection: $settings.groupBySurah) {
                            Text("Sort by Surah").tag(true)
                            Text("Sort by Juz").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                    }
                    
                    SearchBar(text: $searchText)
                        .padding(.horizontal, 8)
                }
            }
            .navigationTitle("Al-Quran")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettingsSheet = true
                    } label: {
                        Image(systemName: "gear")
                    }
                    .padding(.trailing, settings.defaultView ? 6 : 0)
                }
            }
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsView()
                    .accentColor(settings.accentColor.color)
            }
            
            if let lastReadSurah = lastReadSurah, let lastReadAyah = lastReadAyah {
                AyahsView(surah: lastReadSurah, ayah: lastReadAyah.id)
            } else if !settings.bookmarkedAyahs.isEmpty {
                let sortedBookmarks = settings.bookmarkedAyahs.sorted {
                    if $0.surah == $1.surah {
                        return $0.ayah < $1.ayah
                    } else {
                        return $0.surah < $1.surah
                    }
                }
                
                let firstBookmark = sortedBookmarks.first
                let surah = quranData.quran.first(where: { $0.id == firstBookmark?.surah })
                let ayah = surah?.ayahs.first(where: { $0.id == firstBookmark?.ayah })
                
                if let surah = surah, let ayah = ayah {
                    AyahsView(surah: surah, ayah: ayah.id)
                }
            } else if !settings.favoriteSurahs.isEmpty {
                let sortedFavorites = settings.favoriteSurahs.sorted()
                let firstFavorite = quranData.quran.first(where: { $0.id == sortedFavorites.first })
                
                if let surah = firstFavorite {
                    AyahsView(surah: surah)
                }
            } else {
                if !quranData.quran.isEmpty {
                    AyahsView(surah: quranData.quran[0])
                }
            }
        }
    }
}
