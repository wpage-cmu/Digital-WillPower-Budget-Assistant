//
//  categoryMapper.swift
//  Digital WillPower Budget Assistant
//
//  Created by Will Page on 12/1/24.
//
import MapKit
import SwiftUI
import Foundation

// Category initialization
struct Category: Identifiable, Codable {
    var id = UUID()
    var catName: String
    var target: Int
    var timeframe: String
    var remainingBudget: Int
}

// Timeframe options
enum TimeCategory: String, CaseIterable {
    case day = "day"
    case week = "wk"
    case month = "mo"
    case year = "yr"
}

// Category List available for selection
enum PlaceCategory: String, CaseIterable {
    case restaurant = "🍔 Eating out"
    case foodMarket = "🛒 Groceries"
    case beauty = "💄 Beauty"
    // Add more categories here
}

// This structure maps MapKit categories to WillPower categories
struct CategoryMapper {
    static func mapToPlaceCategory(_ mapKitCategory: MKPointOfInterestCategory) -> PlaceCategory? {
        switch mapKitCategory {
        case .restaurant:
            return .restaurant
        case .foodMarket:
            return .foodMarket
        case .beauty:
            return .beauty
        // Add more categories as needed

        default:
            return nil
        }
    }
}

class CategoryManager: ObservableObject {
    @Published var categories: [Category]

    init() {
        // Load categories from UserDefaults if available
        if let data = UserDefaults.standard.data(forKey: "categoriesKey"),
           let decodedCategories = try? JSONDecoder().decode([Category].self, from: data) {
            self.categories = decodedCategories
        } else {
            self.categories = [] // Default to an empty array if no saved data
        }
    }
    
    func addCategory(_ category: Category) {
        categories = categories + [category]
        saveCategoriesToUserDefaults()
        print("Categories after adding: \(categories)")
        objectWillChange.send()
    }
    
    func updateRemainingBudget(for categoryId: UUID, amount: Int) {
            if let index = categories.firstIndex(where: { $0.id == categoryId }) {
                categories[index].remainingBudget = amount
            }
        }

    func clearAllCategories() {
        categories.removeAll()
        saveCategoriesToUserDefaults()
    }
    
    private func saveCategoriesToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "categoriesKey")
        }
    }
}



