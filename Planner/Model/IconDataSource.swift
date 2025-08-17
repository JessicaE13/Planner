import SwiftUI

// MARK: - Shared Icon Data Models
struct IconCategory {
    let name: String
    let icons: [IconItem]
}

struct IconItem {
    let name: String
    let displayName: String
}

// MARK: - Shared Icon Data Source
class IconDataSource {
    static let shared = IconDataSource()
    
    private init() {} // Singleton
    
    let iconCategories: [IconCategory] = [
           IconCategory(name: "Time & Schedule", icons: [
               IconItem(name: "sunrise.fill", displayName: "Sunrise"),
               IconItem(name: "sunset.fill", displayName: "Sunset"),
               IconItem(name: "sun.max.fill", displayName: "Sun"),
               IconItem(name: "sun.min.fill", displayName: "Sun Min"),
               IconItem(name: "moon.fill", displayName: "Moon"),
               IconItem(name: "moon.stars.fill", displayName: "Moon Stars"),
               IconItem(name: "clock.fill", displayName: "Clock"),
               IconItem(name: "alarm.fill", displayName: "Alarm"),
               IconItem(name: "timer", displayName: "Timer"),
               IconItem(name: "stopwatch.fill", displayName: "Stopwatch"),
               IconItem(name: "hourglass", displayName: "Hourglass"),
               IconItem(name: "calendar", displayName: "Calendar"),
               IconItem(name: "calendar.badge.plus", displayName: "Add Event"),
               IconItem(name: "calendar.day.timeline.left", displayName: "Schedule"),
               IconItem(name: "deskclock.fill", displayName: "Desk Clock"),
               IconItem(name: "timeline.selection", displayName: "Timeline")
           ]),
           
           IconCategory(name: "Health & Wellness", icons: [
               IconItem(name: "heart.fill", displayName: "Heart"),
               IconItem(name: "heart.text.square.fill", displayName: "Health Records"),
               IconItem(name: "medical.thermometer.fill", displayName: "Temperature"),
               IconItem(name: "cross.fill", displayName: "Medical"),
               IconItem(name: "pills.fill", displayName: "Medication"),
               IconItem(name: "syringe.fill", displayName: "Injection"),
               IconItem(name: "bandage.fill", displayName: "Bandage"),
               IconItem(name: "stethoscope", displayName: "Stethoscope"),
               IconItem(name: "leaf.fill", displayName: "Natural"),
               IconItem(name: "drop.fill", displayName: "Water"),
               IconItem(name: "lungs.fill", displayName: "Breathing"),
               IconItem(name: "brain.head.profile", displayName: "Mental Health"),
               IconItem(name: "brain.fill", displayName: "Brain"),
               IconItem(name: "eye.fill", displayName: "Vision"),
               IconItem(name: "ear.fill", displayName: "Hearing"),
               IconItem(name: "mouth.fill", displayName: "Oral Health"),
               IconItem(name: "waveform.path.ecg", displayName: "Heart Rate"),
               IconItem(name: "figure.flexibility", displayName: "Flexibility"),
               IconItem(name: "figure.mind.and.body", displayName: "Mind & Body")
           ]),
           
           IconCategory(name: "Exercise & Fitness", icons: [
               IconItem(name: "figure.walk", displayName: "Walking"),
               IconItem(name: "figure.run", displayName: "Running"),
               IconItem(name: "figure.hiking", displayName: "Hiking"),
               IconItem(name: "figure.climbing", displayName: "Climbing"),
               IconItem(name: "figure.outdoor.cycle", displayName: "Cycling"),
               IconItem(name: "bicycle", displayName: "Bike"),
               IconItem(name: "dumbbell.fill", displayName: "Weights"),
               IconItem(name: "figure.strengthtraining.traditional", displayName: "Strength Training"),
               IconItem(name: "figure.yoga", displayName: "Yoga"),
               IconItem(name: "figure.pilates", displayName: "Pilates"),
               IconItem(name: "figure.dance", displayName: "Dance"),
               IconItem(name: "figure.pool.swim", displayName: "Swimming"),
               IconItem(name: "figure.tennis", displayName: "Tennis"),
               IconItem(name: "figure.basketball", displayName: "Basketball"),
               IconItem(name: "figure.soccer", displayName: "Soccer"),
               IconItem(name: "figure.golf", displayName: "Golf"),
               IconItem(name: "figure.baseball", displayName: "Baseball"),
               IconItem(name: "figure.archery", displayName: "Archery"),
               IconItem(name: "figure.badminton", displayName: "Badminton"),
               IconItem(name: "figure.boxing", displayName: "Boxing")
           ]),
           
           IconCategory(name: "Food & Nutrition", icons: [
               IconItem(name: "fork.knife", displayName: "Meal"),
               IconItem(name: "fork.knife.circle.fill", displayName: "Dining"),
               IconItem(name: "cup.and.saucer.fill", displayName: "Coffee"),
               IconItem(name: "mug.fill", displayName: "Hot Drink"),
               IconItem(name: "wineglass.fill", displayName: "Wine"),
               IconItem(name: "waterbottle.fill", displayName: "Water Bottle"),
               IconItem(name: "carrot.fill", displayName: "Vegetables"),
               IconItem(name: "apple.logo", displayName: "Apple"),
               IconItem(name: "birthday.cake.fill", displayName: "Cake"),
               IconItem(name: "takeoutbag.and.cup.and.straw.fill", displayName: "Takeout"),
               IconItem(name: "cart.fill", displayName: "Groceries"),
               IconItem(name: "bag.fill", displayName: "Shopping"),
               IconItem(name: "basket.fill", displayName: "Market"),
               IconItem(name: "refrigerator.fill", displayName: "Fridge"),
               IconItem(name: "cooktop.fill", displayName: "Cooking"),
               IconItem(name: "oven.fill", displayName: "Baking"),
               IconItem(name: "microwave.fill", displayName: "Microwave"),
               IconItem(name: "scale.3d", displayName: "Kitchen Scale"),
               IconItem(name: "cup.and.heat.waves.fill", displayName: "Hot Beverage"),
               IconItem(name: "drop.degreesign.fill", displayName: "Cold Drink")
           ]),
           
           IconCategory(name: "Work & Productivity", icons: [
               IconItem(name: "briefcase.fill", displayName: "Work"),
               IconItem(name: "case.fill", displayName: "Business"),
               IconItem(name: "laptopcomputer", displayName: "Laptop"),
               IconItem(name: "desktopcomputer", displayName: "Desktop"),
               IconItem(name: "ipad", displayName: "Tablet"),
               IconItem(name: "iphone", displayName: "Phone"),
               IconItem(name: "keyboard.fill", displayName: "Typing"),
               IconItem(name: "computermouse", displayName: "Mouse"),
               IconItem(name: "pencil", displayName: "Writing"),
               IconItem(name: "pencil.and.ruler.fill", displayName: "Design"),
               IconItem(name: "applepencil.and.scribble", displayName: "Pen"),
               IconItem(name: "highlighter", displayName: "Highlight"),
               IconItem(name: "book.fill", displayName: "Reading"),
               IconItem(name: "books.vertical.fill", displayName: "Study"),
               IconItem(name: "magazine.fill", displayName: "Magazine"),
               IconItem(name: "newspaper.fill", displayName: "News"),
               IconItem(name: "doc.fill", displayName: "Document"),
               IconItem(name: "folder.fill", displayName: "Files"),
               IconItem(name: "archivebox.fill", displayName: "Archive"),
               IconItem(name: "graduationcap.fill", displayName: "Education"),
               IconItem(name: "studentdesk", displayName: "Study Desk"),
               IconItem(name: "lightbulb.fill", displayName: "Ideas"),
               IconItem(name: "target", displayName: "Goals"),
               IconItem(name: "checkmark.circle.fill", displayName: "Task"),
               IconItem(name: "list.bullet.clipboard.fill", displayName: "Checklist"),
               IconItem(name: "calendar.badge.checkmark", displayName: "Deadline"),
               IconItem(name: "chart.bar.fill", displayName: "Analytics"),
               IconItem(name: "chart.pie.fill", displayName: "Statistics")
       
           ]),
           
           IconCategory(name: "Home & Personal Care", icons: [
               IconItem(name: "house.fill", displayName: "Home"),
               IconItem(name: "building.fill", displayName: "Building"),
               IconItem(name: "bed.double.fill", displayName: "Sleep"),
               IconItem(name: "shower.fill", displayName: "Shower"),
               IconItem(name: "bathtub.fill", displayName: "Bath"),
               IconItem(name: "toilet.fill", displayName: "Bathroom"),
               IconItem(name: "sink.fill", displayName: "Sink"),
               IconItem(name: "washer.fill", displayName: "Laundry"),
               IconItem(name: "dryer.fill", displayName: "Dryer"),
               IconItem(name: "trash.fill", displayName: "Cleaning"),
               IconItem(name: "bin.xmark.fill", displayName: "Dispose"),
               IconItem(name: "bubbles.and.sparkles.fill", displayName: "Wash"),
               IconItem(name: "tshirt.fill", displayName: "Clothes"),
               IconItem(name: "shoe.fill", displayName: "Shoes"),
               IconItem(name: "hat.widebrim.fill", displayName: "Hat"),
               IconItem(name: "comb.fill", displayName: "Grooming"),
               IconItem(name: "scissors", displayName: "Haircut"),
               IconItem(name: "face.smiling.inverse", displayName: "Skincare"),
               IconItem(name: "mouth.fill", displayName: "Dental Care"),
               IconItem(name: "pawprint.fill", displayName: "Pet Care"),
               IconItem(name: "key.fill", displayName: "Keys"),
               IconItem(name: "creditcard.fill", displayName: "Wallet")
           ]),
           
           IconCategory(name: "Entertainment & Hobbies", icons: [
               IconItem(name: "music.note", displayName: "Music"),
               IconItem(name: "headphones", displayName: "Listen"),
               IconItem(name: "speaker.wave.3.fill", displayName: "Audio"),
               IconItem(name: "radio.fill", displayName: "Radio"),
               IconItem(name: "tv.fill", displayName: "TV"),
               IconItem(name: "movieclapper.fill", displayName: "Movies"),
               IconItem(name: "video.fill", displayName: "Video"),
               IconItem(name: "gamecontroller.fill", displayName: "Gaming"),
               IconItem(name: "dice.fill", displayName: "Board Games"),
               IconItem(name: "puzzlepiece.fill", displayName: "Puzzle"),
               IconItem(name: "paintbrush.fill", displayName: "Art"),
               IconItem(name: "paintpalette.fill", displayName: "Painting"),
               IconItem(name: "scribble", displayName: "Drawing"),
               IconItem(name: "camera.fill", displayName: "Photography"),
               IconItem(name: "video.circle.fill", displayName: "Video Recording"),
               IconItem(name: "guitars.fill", displayName: "Guitar"),
               IconItem(name: "pianokeys", displayName: "Piano"),
               IconItem(name: "mic.fill", displayName: "Singing"),
               IconItem(name: "theatermasks.fill", displayName: "Theater"),
               IconItem(name: "party.popper.fill", displayName: "Party")
           ]),
           
           IconCategory(name: "Sports & Recreation", icons: [
               IconItem(name: "football.fill", displayName: "Football"),
               IconItem(name: "basketball.fill", displayName: "Basketball"),
               IconItem(name: "baseball.fill", displayName: "Baseball"),
               IconItem(name: "tennis.racket", displayName: "Tennis"),
               IconItem(name: "hockey.puck.fill", displayName: "Hockey"),
               IconItem(name: "volleyball.fill", displayName: "Volleyball"),
               IconItem(name: "cricket.ball.fill", displayName: "Cricket"),
               IconItem(name: "figure.golf", displayName: "Golf"),
               IconItem(name: "figure.bowling", displayName: "Bowling"),
               IconItem(name: "skateboard.fill", displayName: "Skateboarding"),
               IconItem(name: "skis.fill", displayName: "Skiing"),
               IconItem(name: "snowboard.fill", displayName: "Snowboarding"),
               IconItem(name: "surfboard.fill", displayName: "Surfing"),
               IconItem(name: "tent.fill", displayName: "Camping"),
               IconItem(name: "backpack.fill", displayName: "Hiking"),
               IconItem(name: "binoculars.fill", displayName: "Bird Watching"),
               IconItem(name: "fish.fill", displayName: "Fishing"),
               IconItem(name: "leaf.arrow.triangle.circlepath", displayName: "Outdoor Activity")
           ]),
           
           IconCategory(name: "Transportation", icons: [
               IconItem(name: "car.fill", displayName: "Car"),
               IconItem(name: "bus.fill", displayName: "Bus"),
               IconItem(name: "tram.fill", displayName: "Tram"),
               IconItem(name: "train.side.front.car", displayName: "Train"),
               IconItem(name: "airplane", displayName: "Flight"),
               IconItem(name: "ferry.fill", displayName: "Ferry"),
               IconItem(name: "bicycle", displayName: "Bicycle"),
               IconItem(name: "scooter", displayName: "Scooter"),
               IconItem(name: "motorcycle.fill", displayName: "Motorcycle"),
               IconItem(name: "truck.box.fill", displayName: "Truck"),
               IconItem(name: "fuelpump.fill", displayName: "Gas Station"),
               IconItem(name: "door.garage.double.bay.closed", displayName: "Garage"),
               IconItem(name: "parkingsign", displayName: "Parking"),
               IconItem(name: "road.lanes", displayName: "Highway"),
               IconItem(name: "map.fill", displayName: "Navigation"),
               IconItem(name: "location.fill", displayName: "Location")
           ]),
           
           IconCategory(name: "Nature & Weather", icons: [
               IconItem(name: "tree.fill", displayName: "Tree"),
               IconItem(name: "camera.macro", displayName: "Flower"),
               IconItem(name: "leaf.fill", displayName: "Leaf"),
               IconItem(name: "globe.americas.fill", displayName: "Earth"),
               IconItem(name: "mountain.2.fill", displayName: "Mountains"),
               IconItem(name: "beach.umbrella.fill", displayName: "Beach"),
               IconItem(name: "water.waves", displayName: "Ocean"),
               IconItem(name: "cloud.fill", displayName: "Cloud"),
               IconItem(name: "cloud.rain.fill", displayName: "Rain"),
               IconItem(name: "cloud.snow.fill", displayName: "Snow"),
               IconItem(name: "cloud.bolt.rain.fill", displayName: "Storm"),
               IconItem(name: "sun.max.fill", displayName: "Sunny"),
               IconItem(name: "moon.stars.fill", displayName: "Night"),
               IconItem(name: "snowflake", displayName: "Snowflake"),
               IconItem(name: "thermometer.sun.fill", displayName: "Hot"),
               IconItem(name: "thermometer.snowflake", displayName: "Cold"),
               IconItem(name: "wind", displayName: "Wind"),
               IconItem(name: "rainbow", displayName: "Rainbow"),
               IconItem(name: "sparkles", displayName: "Sparkles"),
               IconItem(name: "tornado", displayName: "Tornado"),
               IconItem(name: "hurricane", displayName: "Hurricane")
           ]),
           
           IconCategory(name: "Communication", icons: [
               IconItem(name: "phone.fill", displayName: "Phone"),
               IconItem(name: "message.fill", displayName: "Message"),
               IconItem(name: "mail.fill", displayName: "Email"),
               IconItem(name: "envelope.fill", displayName: "Letter"),
               IconItem(name: "paperplane.fill", displayName: "Send"),
               IconItem(name: "megaphone.fill", displayName: "Announce"),
               IconItem(name: "speaker.wave.3.fill", displayName: "Speak"),
               IconItem(name: "mic.fill", displayName: "Record"),
               IconItem(name: "bubble.left.and.bubble.right.fill", displayName: "Chat"),
               IconItem(name: "phone.connection", displayName: "Video Call"),
               IconItem(name: "wifi", displayName: "WiFi"),
               IconItem(name: "antenna.radiowaves.left.and.right", displayName: "Signal"),
               IconItem(name: "network", displayName: "Network"),
               IconItem(name: "globe", displayName: "Internet")
           ]),
           
           IconCategory(name: "Finance & Shopping", icons: [
               IconItem(name: "creditcard.fill", displayName: "Credit Card"),
               IconItem(name: "banknote.fill", displayName: "Cash"),
               IconItem(name: "dollarsign.circle.fill", displayName: "Dollar"),
               IconItem(name: "eurosign.circle.fill", displayName: "Euro"),
               IconItem(name: "yensign.circle.fill", displayName: "Yen"),
               IconItem(name: "bitcoinsign.circle.fill", displayName: "Bitcoin"),
               IconItem(name: "wallet.pass.fill", displayName: "Wallet"),
               IconItem(name: "building.columns.fill", displayName: "Bank"),
               IconItem(name: "chart.line.uptrend.xyaxis", displayName: "Investment"),
               IconItem(name: "cart.fill", displayName: "Shopping"),
               IconItem(name: "bag.fill", displayName: "Shopping Bag"),
               IconItem(name: "gift.fill", displayName: "Gift"),
               IconItem(name: "tag.fill", displayName: "Price Tag"),
               IconItem(name: "percent", displayName: "Discount"),
               IconItem(name: "receipt.fill", displayName: "Receipt")
           ]),
           
           IconCategory(name: "Symbols & Status", icons: [
               IconItem(name: "star.fill", displayName: "Star"),
               IconItem(name: "flame.fill", displayName: "Fire"),
               IconItem(name: "bolt.fill", displayName: "Energy"),
               IconItem(name: "diamond.fill", displayName: "Diamond"),
               IconItem(name: "crown.fill", displayName: "Crown"),
               IconItem(name: "medal.fill", displayName: "Medal"),
               IconItem(name: "trophy.fill", displayName: "Trophy"),
               IconItem(name: "rosette", displayName: "Award"),
               IconItem(name: "checkmark.circle.fill", displayName: "Complete"),
               IconItem(name: "xmark.circle.fill", displayName: "Cancel"),
               IconItem(name: "exclamationmark.triangle.fill", displayName: "Warning"),
               IconItem(name: "info.circle.fill", displayName: "Info"),
               IconItem(name: "questionmark.circle.fill", displayName: "Question"),
               IconItem(name: "plus.circle.fill", displayName: "Add"),
               IconItem(name: "minus.circle.fill", displayName: "Remove"),
               IconItem(name: "multiply.circle.fill", displayName: "Delete"),
               IconItem(name: "heart.fill", displayName: "Love"),
               IconItem(name: "hand.thumbsup.fill", displayName: "Like"),
               IconItem(name: "hand.thumbsdown.fill", displayName: "Dislike"),
               IconItem(name: "face.smiling.inverse", displayName: "Happy"),
               IconItem(name: "face.dashed.fill", displayName: "Neutral")
           ]),
           
           IconCategory(name: "Tools & Objects", icons: [
               IconItem(name: "hammer.fill", displayName: "Hammer"),
               IconItem(name: "screwdriver.fill", displayName: "Screwdriver"),
               IconItem(name: "wrench.fill", displayName: "Wrench"),
               IconItem(name: "scissors", displayName: "Scissors"),
               IconItem(name: "ruler.fill", displayName: "Ruler"),
               IconItem(name: "level.fill", displayName: "Level"),
               IconItem(name: "paintbrush.fill", displayName: "Brush"),
               IconItem(name: "eyedropper.full", displayName: "Dropper"),
               IconItem(name: "magnifyingglass", displayName: "Search"),
               IconItem(name: "flashlight.on.fill", displayName: "Flashlight"),
               IconItem(name: "key.fill", displayName: "Key"),
               IconItem(name: "lock.fill", displayName: "Lock"),
               IconItem(name: "bell.fill", displayName: "Bell"),
               IconItem(name: "hourglass.bottomhalf.filled", displayName: "Timer"),
               IconItem(name: "thermometer", displayName: "Temperature"),
               IconItem(name: "scale.3d", displayName: "Scale"),
               IconItem(name: "binoculars.fill", displayName: "Binoculars"),
               IconItem(name: "compass.drawing", displayName: "Compass"),
               IconItem(name: "globe.desk.fill", displayName: "Globe")
           ])
       ]
    
    // MARK: - Original Filtering Methods
    func getFilteredCategories(searchText: String) -> [IconCategory] {
        if searchText.isEmpty {
            return iconCategories
        } else {
            return iconCategories.compactMap { category in
                let filteredIcons = category.icons.filter { icon in
                    icon.displayName.lowercased().contains(searchText.lowercased()) ||
                    icon.name.lowercased().contains(searchText.lowercased())
                }
                return filteredIcons.isEmpty ? nil : IconCategory(name: category.name, icons: filteredIcons)
            }
        }
    }
    
    func getFilteredIcons(searchText: String) -> [IconItem] {
        return getFilteredCategories(searchText: searchText).flatMap { $0.icons }
    }
    
    func getFirstFilteredIcon(searchText: String, defaultIcon: String = "sunrise.fill") -> String {
        let filteredIcons = getFilteredIcons(searchText: searchText)
        return filteredIcons.first?.name ?? defaultIcon
    }
    
    // MARK: - NEW: Enhanced Word-by-Word Matching Methods
    
    /// Get the first matching icon by searching each word individually
    /// Returns the icon for the first word that has matches, or defaultIcon if no words match
    func getFirstMatchingIconByWords(searchText: String, defaultIcon: String = "calendar") -> String {
        // Clean and split the search text into words
        let words = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .compactMap { word in
                let cleaned = word.trimmingCharacters(in: .punctuationCharacters)
                return cleaned.isEmpty ? nil : cleaned
            }
        
        // If no words, return default
        guard !words.isEmpty else { return defaultIcon }
        
        // Search each word individually, return icon for first match
        for word in words {
            let iconsForWord = getFilteredIcons(searchText: word)
            if !iconsForWord.isEmpty {
                return iconsForWord.first?.name ?? defaultIcon
            }
        }
        
        // No matches found for any word
        return defaultIcon
    }
    
    /// Get all matching icons by searching each word individually
    /// Returns icons for the first word that has matches, or empty array if no words match
    func getMatchingIconsByWords(searchText: String) -> [IconItem] {
        // Clean and split the search text into words
        let words = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .compactMap { word in
                let cleaned = word.trimmingCharacters(in: .punctuationCharacters)
                return cleaned.isEmpty ? nil : cleaned
            }
        
        // If no words, return empty
        guard !words.isEmpty else { return [] }
        
        // Search each word individually, return icons for first match
        for word in words {
            let iconsForWord = getFilteredIcons(searchText: word)
            if !iconsForWord.isEmpty {
                return iconsForWord
            }
        }
        
        // No matches found for any word
        return []
    }
    
    /// Get information about which word matched and how many icons were found
    func getWordMatchInfo(searchText: String) -> (matchedWord: String?, iconCount: Int) {
        // Clean and split the search text into words
        let words = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .compactMap { word in
                let cleaned = word.trimmingCharacters(in: .punctuationCharacters)
                return cleaned.isEmpty ? nil : cleaned
            }
        
        // If no words, return no match
        guard !words.isEmpty else { return (nil, 0) }
        
        // Search each word individually
        for word in words {
            let iconsForWord = getFilteredIcons(searchText: word)
            if !iconsForWord.isEmpty {
                return (word, iconsForWord.count)
            }
        }
        
        // No matches found for any word
        return (nil, 0)
    }
    
    // MARK: - Convenience Methods
    func getAllIcons() -> [IconItem] {
        return iconCategories.flatMap { $0.icons }
    }
    
    func findIcon(byName name: String) -> IconItem? {
        return getAllIcons().first { $0.name == name }
    }
    
    func getRandomIcon() -> IconItem {
        let allIcons = getAllIcons()
        return allIcons.randomElement() ?? IconItem(name: "sunrise.fill", displayName: "Sunrise")
    }
}

// MARK: - Updated IconPickerView using shared data source
struct SharedIconPickerView: View {
    @Binding var selectedIcon: String
    @State private var searchText: String
    @Environment(\.dismiss) private var dismiss
    
    private let iconDataSource = IconDataSource.shared
    
    init(selectedIcon: Binding<String>, initialSearchText: String = "") {
        self._selectedIcon = selectedIcon
        self._searchText = State(initialValue: initialSearchText)
    }
    
    private var filteredCategories: [IconCategory] {
        iconDataSource.getFilteredCategories(searchText: searchText)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $searchText)
                    .padding()
                
                // Icons grid
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20, pinnedViews: [.sectionHeaders]) {
                        ForEach(filteredCategories, id: \.name) { category in
                            Section {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                                    ForEach(category.icons, id: \.name) { iconItem in
                                        IconButton(
                                            iconItem: iconItem,
                                            isSelected: selectedIcon == iconItem.name,
                                            onTap: {
                                                selectedIcon = iconItem.name
                                                dismiss()
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            } header: {
                                HStack {
                                    Text(category.name)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color("Background1"))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Updated EditRoutineView using shared data source
struct SharedEditRoutineView: View {
    @Binding var routine: Routine
    @State private var isNewRoutine: Bool
    @State private var tempRoutine: Routine
    @State private var showingItemEdit = false
    @State private var showingIconPicker = false
    @State private var editingItemIndex: Int?
    @State private var selectedIconName: String = ""
    @State private var selectedColor: Color = .blue
    @State private var userHasManuallySelectedIcon = false
    @Environment(\.dismiss) private var dismiss
    
    private let iconDataSource = IconDataSource.shared
    
    init(routine: Binding<Routine>, isNew: Bool = false) {
        self._routine = routine
        self._isNewRoutine = State(initialValue: isNew)
        self._tempRoutine = State(initialValue: routine.wrappedValue)
        self._selectedIconName = State(initialValue: routine.wrappedValue.iconName)
        self._selectedColor = State(initialValue: routine.wrappedValue.color)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Info Section
                Section("Routine Details") {
                    // Routine Name with Smart Filtered Icon
                    HStack {
                        Button(action: {
                            showingIconPicker = true
                        }) {
                            Image(systemName: selectedIconName)
                                .foregroundColor(selectedColor)
                                .font(.title2)
                                .frame(width: 32, height: 32)
                        }
                        
                        TextField("Routine Name", text: $tempRoutine.name)
                            .onChange(of: tempRoutine.name) { oldValue, newValue in
                                // Only auto-suggest if user hasn't manually selected an icon
                                if !userHasManuallySelectedIcon {
                                    let suggestedIcon = iconDataSource.getFirstFilteredIcon(searchText: newValue)
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedIconName = suggestedIcon
                                    }
                                }
                            }
                    }
                    
                    // Show filtering hint and results
                    if !tempRoutine.name.isEmpty && !userHasManuallySelectedIcon {
                        let filteredIcons = iconDataSource.getFilteredIcons(searchText: tempRoutine.name)
                        
                        if !filteredIcons.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                    Text("Icon auto-selected from \(filteredIcons.count) match\(filteredIcons.count == 1 ? "" : "es")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                // Show a preview of other matching icons
                                if filteredIcons.count > 1 {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(Array(filteredIcons.prefix(5)), id: \.name) { iconItem in
                                                Button(action: {
                                                    selectedIconName = iconItem.name
                                                    userHasManuallySelectedIcon = true
                                                }) {
                                                    VStack(spacing: 2) {
                                                        Image(systemName: iconItem.name)
                                                            .font(.title3)
                                                            .foregroundColor(selectedColor)
                                                            .frame(width: 24, height: 24)
                                                        
                                                        Text(iconItem.displayName)
                                                            .font(.caption2)
                                                            .foregroundColor(.secondary)
                                                            .lineLimit(1)
                                                    }
                                                    .padding(4)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 6)
                                                            .fill(iconItem.name == selectedIconName ? selectedColor.opacity(0.1) : Color.clear)
                                                    )
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                            
                                            if filteredIcons.count > 5 {
                                                Button(action: {
                                                    showingIconPicker = true
                                                }) {
                                                    VStack(spacing: 2) {
                                                        Image(systemName: "ellipsis")
                                                            .font(.title3)
                                                            .foregroundColor(.secondary)
                                                            .frame(width: 24, height: 24)
                                                        
                                                        Text("+\(filteredIcons.count - 5)")
                                                            .font(.caption2)
                                                            .foregroundColor(.secondary)
                                                    }
                                                    .padding(4)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                    }
                                }
                            }
                            .padding(.horizontal, 44) // Align with the text field
                        } else {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                Text("No matching icons found - using default")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 44)
                        }
                    }
                    
                    // Color Selection
                    HStack {
                        Text("Color")
                        Spacer()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(Color.routineColors.enumerated()), id: \.offset) { index, color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: selectedColor.isApproximatelyEqual(to: color) ? 2 : 0)
                                        )
                                        .onTapGesture {
                                            selectedColor = color
                                        }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
                
                // Items Section
                Section(header: HStack {
                    Text("Items")
                    Spacer()
                    Button(action: addNewItem) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(selectedColor)
                    }
                }) {
                    ForEach(tempRoutine.items.indices, id: \.self) { index in
                        ItemRow(
                            item: tempRoutine.items[index],
                            color: selectedColor,
                            onEdit: {
                                editingItemIndex = index
                                showingItemEdit = true
                            },
                            onDelete: {
                                tempRoutine.items.remove(at: index)
                            }
                        )
                    }
                    .onMove(perform: moveItems)
                }
                
                // Reset to Auto-Filter Button
                if userHasManuallySelectedIcon && !tempRoutine.name.isEmpty {
                    Section {
                        Button(action: {
                            userHasManuallySelectedIcon = false
                            let suggestedIcon = iconDataSource.getFirstFilteredIcon(searchText: tempRoutine.name)
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedIconName = suggestedIcon
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Reset to Auto-Filtered Icon")
                            }
                            .foregroundColor(.accentColor)
                        }
                    } footer: {
                        Text("The icon will automatically update based on your routine name")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(isNewRoutine ? "New Routine" : "Edit Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        tempRoutine.iconName = selectedIconName
                        tempRoutine.color = selectedColor
                        routine = tempRoutine
                        dismiss()
                    }
                    .disabled(tempRoutine.name.isEmpty || tempRoutine.items.isEmpty)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                // Pre-populate the icon picker with the current routine name as search text
                SharedIconPickerView(selectedIcon: $selectedIconName, initialSearchText: tempRoutine.name)
                    .onDisappear {
                        userHasManuallySelectedIcon = true
                    }
            }
            .sheet(isPresented: $showingItemEdit) {
                if let index = editingItemIndex {
                    EditItemView(
                        item: Binding(
                            get: { tempRoutine.items[index] },
                            set: { tempRoutine.items[index] = $0 }
                        )
                    )
                }
            }
        }
    }
    
    private func addNewItem() {
        let newItem = RoutineItem(name: "New Item")
        tempRoutine.items.append(newItem)
        editingItemIndex = tempRoutine.items.count - 1
        showingItemEdit = true
    }
    
    private func moveItems(from: IndexSet, to: Int) {
        tempRoutine.items.move(fromOffsets: from, toOffset: to)
    }
}

// MARK: - Supporting Views (reused from existing code)
struct IconButton: View {
    let iconItem: IconItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.accentColor : .clear)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: iconItem.name)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : .primary)
                }
                
                Text(iconItem.displayName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search icons...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color("Background1"))
        .cornerRadius(10)
    }
}
