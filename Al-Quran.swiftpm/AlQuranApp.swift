import SwiftUI

@main
struct AlQuranApp: App {
    @StateObject private var settings = Settings.shared
    @StateObject private var quranData = QuranData()
    
    func registerCustomFonts() {
        if let indopakFontURL = Bundle.main.url(forResource: "Indopak", withExtension: "ttf"),
           let uthmaniFontURL = Bundle.main.url(forResource: "Uthmani", withExtension: "otf") {
            CTFontManagerRegisterFontsForURL(indopakFontURL as CFURL, CTFontManagerScope.process, nil)
            CTFontManagerRegisterFontsForURL(uthmaniFontURL as CFURL, CTFontManagerScope.process, nil)
        }
    }
    
    init() {
        registerCustomFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            SurahsView()
                .environmentObject(quranData)
                .environmentObject(settings)
        }
    }
}

extension View {
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    
    var onSearchButtonClicked: (() -> Void)?
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = true
        }
        
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
            
            text = ""
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Search"
        searchBar.autocorrectionType = .no
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        DispatchQueue.main.async {
            self.text = searchBar.text ?? ""
        }
    }
}
