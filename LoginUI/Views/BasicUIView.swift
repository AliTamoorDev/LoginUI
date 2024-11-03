import SwiftUI
import UIKit

// Flashcard View
struct Flashcard: View {
    let topic: String
    let answer: String?
    let image: Image?
    @State private var isFlipped = false
    @State private var rotationAngle = 0.0
    var onDelete: (() -> Void)?
    
    @AppStorage("fontSize") private var fontSize: Double = 18.0
    @AppStorage("cardColorString") private var cardColorString: String = "Purple"
    
    var cardColor: Color {
        colorFromString(cardColorString)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(cardColor)
                .frame(width: 200, height: 200)
                .shadow(radius: 5)
            
            VStack {
                if isFlipped {
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .cornerRadius(10)
                    } else if let answer = answer {
                        Text(answer)
                            .font(.system(size: CGFloat(fontSize)))
                            .foregroundColor(.white)
                            .padding()
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .frame(width: 180, height: 180)
                    }
                } else {
                    Text(topic)
                        .font(.system(size: CGFloat(fontSize)))
                        .foregroundColor(.white)
                        .padding()
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .frame(width: 180, height: 180)
                }
            }
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        }
        .rotation3DEffect(.degrees(rotationAngle), axis: (x: 0, y: 1, z: 0))
        .onTapGesture {
            flipCard()
        }
        .animation(.easeInOut, value: isFlipped)
        .contextMenu {
            Button(role: .destructive) {
                onDelete?()
            } label: {
                Label("Löschen", systemImage: "trash")
            }
        }
    }
    
    private func flipCard() {
        withAnimation {
            rotationAngle += 180
            isFlipped.toggle()
        }
    }
}

// Hauptansicht mit Kategorien und ausklappbaren Themen
struct ContentView: View {
    @State private var showingAddCard = false
    @State private var showingCategoryView = false
    @State private var showingSettings = false
    @State private var flashcards: [String: [(String, String?, Image?)]] = [
        "2. Weltkrieg": [("Dauer", "1939-1945", nil), ("Schlacht von Stalingrad", "1942-1943", nil)],
        "Mathematik": [("Was ist Pi?", "Eine mathematische Konstante ~ 3.14159", nil)],
    ]
    
    @State private var expandedCategories: Set<String> = []
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("cardColorString") private var cardColorString: String = "Purple"
    
    @State private var searchText = "" // Suchbegriff für die Suchleiste
    
    var body: some View {
        ZStack {
            backgroundPattern()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Suchleiste oben
                
                Text("AnnonCard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading)
                    
                    TextField("Suche nach Karteikarten", text: $searchText)
                        
                }
                .padding(10)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(16)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray, lineWidth: 1)
                }
                .padding(.top, 20)
                .padding(.horizontal)

                
                if flashcards.isEmpty {
                    Text("Keine Karteikarten vorhanden.")
                        .font(.headline)
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        LazyVStack {
                            ForEach(flashcards.keys.sorted(), id: \.self) { category in
                                // Suchfilter anwenden
                                if searchText.isEmpty || category.lowercased().contains(searchText.lowercased()) || flashcards[category]!.contains(where: { $0.0.lowercased().contains(searchText.lowercased()) }) {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(category)
                                                .font(.headline)
                                                .padding()
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                toggleCategoryExpansion(category)
                                            }) {
                                                Image(systemName: expandedCategories.contains(category) ? "chevron.down" : "chevron.right")
                                                    .padding(.trailing, 20)
                                                    .foregroundColor(.black)
                                            }
                                        }
                                        .background {
                                            Color(.tertiaryApp).opacity(0.6)
                                        }
                                        .cornerRadius(8)
                                        .padding(.horizontal)

                                        
                                        if expandedCategories.contains(category) {
                                            LazyHGrid(rows: Array(repeating: GridItem(.fixed(100), spacing: 20), count: 1)) {
                                                ForEach(Array(flashcards[category]?.enumerated() ?? [].enumerated()), id: \.offset) { index, flashcard in
                                                    Flashcard(topic: flashcard.0, answer: flashcard.1, image: flashcard.2, onDelete: {
                                                        deleteFlashcard(in: category, at: index)
                                                    })
                                                }
                                            }
                                            .padding()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Button(action: {
                        showingCategoryView = true
                    }) {
                        VStack {
                            Image(systemName: "list.bullet")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(Color(.label))
                            
                            Text("Kategorien")
                                .font(.title3)
                                .foregroundColor(Color(.tertiaryApp))
                                .bold()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .sheet(isPresented: $showingCategoryView) {
                        CategoryView(flashcards: $flashcards)
                    }
                    
                    Button(action: {
                        showingAddCard = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(colorFromString(cardColorString)) // Dynamische Anpassung der Farbe
                                .frame(width: 60, height: 60)
                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -20)
                    
                    Button(action: {
                        showingSettings = true
                    }) {
                        VStack {
                            Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                .resizable()
                                .scaledToFill()
                                .foregroundColor(isDarkMode ? .gray : .yellow)
                                .frame(width: 25, height: 25)
                            
                            Text("Einstellungen")
                                .font(.title3)
                                .foregroundColor(.tertiaryApp)
                                .bold()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .sheet(isPresented: $showingSettings) {
                        SettingsView(isDarkMode: $isDarkMode)
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .sheet(isPresented: $showingAddCard) {
            AddCardView(flashcards: $flashcards)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    @ViewBuilder
    func backgroundPattern() -> some View {
        if isDarkMode {
            Color.black
                .overlay(
                    GeometryReader { geometry in
                        let size = geometry.size
                        Path { path in
                            for x in stride(from: 0, to: size.width, by: 30) {
                                for y in stride(from: 0, to: size.height, by: 30) {
                                    let rect = CGRect(x: x, y: y, width: 15, height: 15)
                                    path.addRect(rect)
                                }
                            }
                        }
                        .stroke(Color.white.opacity(0.1), lineWidth: 1.0)
                    }
                )
        } else {
            Color.white
                .overlay(
                    GeometryReader { geometry in
                        let size = geometry.size
                        Path { path in
                            for x in stride(from: 0, to: size.width, by: 30) {
                                for y in stride(from: 0, to: size.height, by: 30) {
                                    let rect = CGRect(x: x, y: y, width: 15, height: 15)
                                    path.addRect(rect)
                                }
                            }
                        }
                        .stroke(Color.black.opacity(0.1), lineWidth: 1.0)
                    }
                )
        }
    }
    
    private func toggleCategoryExpansion(_ category: String) {
        if expandedCategories.contains(category) {
            expandedCategories.remove(category)
        } else {
            expandedCategories.insert(category)
        }
    }
    
    private func deleteFlashcard(in category: String, at index: Int) {
        flashcards[category]?.remove(at: index)
        if flashcards[category]?.isEmpty == true {
            flashcards.removeValue(forKey: category)
        }
    }
}

// Kategorienansicht
struct CategoryView: View {
    @Binding var flashcards: [String: [(String, String?, Image?)]]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(flashcards.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category)) {
                        ForEach(flashcards[category] ?? [], id: \.0) { flashcard in
                            Text(flashcard.0)
                        }
                    }
                }
            }
            .navigationTitle("Kategorien")
        }
    }
}

// Farbe in SwiftUI Color umwandeln
func colorFromString(_ colorName: String) -> Color {
    switch colorName {
    case "Blue": return .blue
    case "Green": return .green
    case "Yellow": return .yellow
    case "Orange": return .orange
    case "Red": return .red
    case "Pink": return .pink
    case "Gray": return .gray
    default: return .purple
    }
}

// Einstellungen Ansicht
struct SettingsView: View {
    @Binding var isDarkMode: Bool
    @AppStorage("fontSize") private var fontSize: Double = 18.0
    @AppStorage("cardColorString") private var cardColorString: String = "Purple"
    @Environment(\.presentationMode) var presentationMode

    private let cardColors: [String] = ["Purple", "Blue", "Green", "Yellow", "Orange", "Red", "Pink", "Gray"]
    
    var body: some View {
        NavigationView {
            VStack {
                
                Form {
                    Section(header: Text("Darstellung")) {
                        Toggle(isOn: $isDarkMode) {
                            Text("Dunkelmodus")
                        }
                        
                        VStack {
                            Text("Schriftgröße: \(Int(fontSize))")
                            Slider(value: $fontSize, in: 10...30, step: 1)
                        }
                        
                        Picker("Kartenfarbe", selection: $cardColorString) {
                            ForEach(cardColors, id: \.self) { color in
                                HStack {
                                    Circle()
                                        .fill(colorFromString(color))
                                        .frame(width: 20, height: 20)
                                    Text(color.capitalized)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Einstellungen")
            .navigationBarItems(trailing: Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.red)
            })
        }
    }
}

// Pop-up View für das Hinzufügen neuer Karten
struct AddCardView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var flashcards: [String: [(String, String?, Image?)]]
    @State private var selectedCategory: String = "Neue Kategorie"
    @State private var newCategory: String = ""
    @State private var topic: String = ""
    @State private var answer: String = ""
    @State private var selectedUIImage: UIImage? = nil
    @State private var selectedImage: Image? = nil
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kategorie")) {
                    Picker("Kategorie", selection: $selectedCategory) {
                        ForEach(flashcards.keys.sorted(), id: \.self) { category in
                            Text(category)
                        }
                        Text("Neue Kategorie").tag("Neue Kategorie")
                    }
                    
                    if selectedCategory == "Neue Kategorie" {
                        TextField("Neue Kategorie", text: $newCategory)
                    }
                }
                
                Section(header: Text("Frage & Antwort")) {
                    TextField("Thema", text: $topic)
                    TextField("Antwort (Optional)", text: $answer)
                }
                
                Section {

                    Button {
                        showingImagePicker = true
                    } label: {
                        HStack {
                            Text("Bild auswählen")
                            Image(systemName: "paperclip")
                        }
                        .padding(10)
                        .foregroundStyle(.blue)
                    }
                    
                    
                    if let selectedImage = selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Karteikarte hinzufügen")
            .navigationBarItems(leading: Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack {
                    Text("Abbrechen")
                        .foregroundStyle(.red)

                    Image(systemName: "xmark")
                        .foregroundStyle(.red)
                }
            }, trailing: Button {
                addFlashcard()
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack {
                    Text("Speichern")
                        .foregroundStyle(.green)
                }
            })
            
            
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedUIImage)
                    .onDisappear {
                        if let uiImage = selectedUIImage {
                            selectedImage = Image(uiImage: uiImage)
                        }
                    }
            }
        }
    }
    
    private func addFlashcard() {
        let category = selectedCategory == "Neue Kategorie" && !newCategory.isEmpty ? newCategory : selectedCategory
        if !category.isEmpty && (!topic.isEmpty || selectedImage != nil) {
            if flashcards[category] == nil {
                flashcards[category] = []
            }
            flashcards[category]?.append((topic, answer.isEmpty ? nil : answer, selectedImage))
        }
    }
}

// UIImagePickerController-Integration
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}


// Anmeldeansicht
struct LoginView2: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            ContentView()
        } else {
            VStack {
                Text("Willkommen bei AnnonCard")
                    .font(.largeTitle)
                    .padding(.bottom, 20)
                
                TextField("Benutzername", text: $username)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 50)
                
                SecureField("Passwort", text: $password)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 50)
                
                Button(action: {
                    if !username.isEmpty && !password.isEmpty {
                        isLoggedIn = true
                    }
                }) {
                    Text("Anmelden")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.horizontal, 50)
                }
            }
            .padding()
        }
    }
}
