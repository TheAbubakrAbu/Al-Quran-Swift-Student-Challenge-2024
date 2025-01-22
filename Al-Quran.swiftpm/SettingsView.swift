import SwiftUI
import Combine
import AVKit

struct SettingsView: View {
    @EnvironmentObject var settings: Settings
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingCredits = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("QURAN")) {
                        SettingsQuranView()
                    }
                }
                
                Button(action: {
                    settings.hapticFeedback()
                    
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                }
                .padding()
                .frame(width: .infinity, alignment: .center)
                .background(settings.accentColor.color)
                .foregroundColor(.primary)
                .cornerRadius(10)
                .padding()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsQuranView: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        Toggle("Show Arabic Quran Text", isOn: $settings.showArabicText)
            .font(.subheadline)
            .tint(settings.accentColor.color)
            .disabled(!settings.showTransliteration && !settings.showEnglishTranslation)
        
        if settings.showArabicText {
            VStack(alignment: .leading) {
                Toggle("Remove Arabic Tashkeel (Vowel Diacritics) and Signs", isOn: $settings.cleanArabicText)
                    .font(.subheadline)
                    .tint(settings.accentColor.color)
                    .disabled(!settings.showArabicText)
                
                Text("This option removes Tashkeel, which are vowel diacretic marks such as Fatha, Damma, Kasra, and others, while retaining essential vowels like Alif, Yaa, and Waw. It also adjusts \"Mad\" letters and the \"Hamzatul Wasl,\" and removes baby vowel letters, various textual annotations including stopping signs, chapter markers, and prayer indicators. This option is not recommended.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 2)
            }
            
            Picker("Arabic Font", selection: $settings.arabicFont) {
                Text("Uthmani").tag("KFGQPCUthmanicScriptHAFS")
                Text("Indopak").tag("Al_Mushaf")
            }
            .pickerStyle(SegmentedPickerStyle())
            .disabled(!settings.showArabicText)
            
            Stepper(value: $settings.arabicFontSize, in: 15...50, step: 2) {
                Text("Arabic Font Size: \(Int(settings.arabicFontSize))")
                    .font(.subheadline)
            }
            .disabled(!settings.showArabicText || settings.useSystemFontSize)
            
            VStack(alignment: .leading) {
                Toggle("Enable Arabic Beginner Mode", isOn: $settings.beginnerMode)
                    .font(.subheadline)
                    .tint(settings.accentColor.color)
                    .disabled(!settings.showArabicText)
                
                Text("Puts a space between each Arabic letter to make it easier for beginners to read the Quran.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 2)
            }
        }
        
        Toggle("Show Transliteration", isOn: $settings.showTransliteration)
            .font(.subheadline)
            .tint(settings.accentColor.color)
            .disabled(!settings.showArabicText && !settings.showEnglishTranslation)
        
        Toggle("Show English Translation", isOn: $settings.showEnglishTranslation)
            .font(.subheadline)
            .tint(settings.accentColor.color)
            .disabled(!settings.showArabicText && !settings.showTransliteration)
        
        if settings.showTransliteration || settings.showEnglishTranslation {
            Stepper(value: $settings.englishFontSize, in: 13...20, step: 1) {
                Text("English Font Size: \(Int(settings.englishFontSize))")
                    .font(.subheadline)
            }
            .disabled((!settings.showTransliteration && !settings.showEnglishTranslation) || settings.useSystemFontSize)
        }
        
        Toggle("Use System Font Size", isOn: $settings.useSystemFontSize)
            .font(.subheadline)
            .tint(settings.accentColor.color)
            .onChange(of: settings.useSystemFontSize) { useSystemFontSize in
                if useSystemFontSize {
                    settings.englishFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
                    settings.arabicFontSize = settings.englishFontSize + 10
                }
            }
    }
}
