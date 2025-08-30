//
//  IconDataSource.swift
//  Planner
//
//  Cleaned version without problematic references
//

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
        ])
    ]
    
    // MARK: - Filtering Methods
    
    func getFilteredCategories(searchText: String) -> [IconCategory] {
        guard !searchText.isEmpty else {
            return iconCategories
        }
        
        let filtered = iconCategories.compactMap { category in
            let filteredIcons = category.icons.filter { icon in
                icon.displayName.localizedCaseInsensitiveContains(searchText) ||
                icon.name.localizedCaseInsensitiveContains(searchText)
            }
            
            return filteredIcons.isEmpty ? nil : IconCategory(name: category.name, icons: filteredIcons)
        }
        
        return filtered
    }
    
    func getAllIcons() -> [IconItem] {
        return getFilteredCategories(searchText: "").flatMap { $0.icons }
    }
}
