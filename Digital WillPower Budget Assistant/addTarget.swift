//
//  addTarget.swift
//  Digital WillPower Budget Assistant
//
//  Created by Will Page on 11/16/24.
//
import SwiftUI

struct AddTargetForm: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var categoryManager: CategoryManager
    @EnvironmentObject var targetReminderManager: TargetReminderManager
    
    @State private var selectedCategory: PlaceCategory = .restaurant
    @State private var selectedTimeframe: TimeCategory = .week
    @State private var targetAmount: Int = 0
    
    private func saveCategoriesToUserDefaults() {
        if let encodedCategories = try? JSONEncoder().encode(categoryManager.categories) {
            UserDefaults.standard.set(encodedCategories, forKey: "categoriesKey")
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Categories Section
                    VStack {
                        Text("Choose a Category")
                            .font(.headline)
                        
                        HStack {
                            ForEach(PlaceCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category.rawValue)
                                        .font(.title)
                                        .padding()
                                        .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.3))
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    
                    // Timeframe Section
                    VStack {
                        Text("Choose a Timeframe")
                            .font(.headline)
                        
                        HStack {
                            ForEach(TimeCategory.allCases, id: \.self) { timeframe in
                                Button(action: {
                                    selectedTimeframe = timeframe
                                }) {
                                    Text(timeframe.rawValue.capitalized)
                                        .font(.title)
                                        .padding()
                                        .background(selectedTimeframe == timeframe ? Color.blue : Color.gray.opacity(0.3))
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    
                    // Budget Section
                    VStack {
                        Text("Set Your Budget")
                            .font(.headline)
                        
                        Slider(value: Binding(get: {
                            Double(targetAmount)
                        }, set: { newValue in
                            targetAmount = Int(newValue)
                        }), in: 0...500, step: 1)
                        .accentColor(.blue)
                        
                        Text("$\(targetAmount) per \(selectedTimeframe.rawValue)")
                            .font(.title2)
                            .padding()
                    }
                    
                    // Save Button
                    Button(action: {
                        // Create the new category
                        let newCategory = Category(
                            catName: selectedCategory.rawValue,
                            target: targetAmount,
                            timeframe: selectedTimeframe.rawValue,
                            remainingBudget: targetAmount
                        )
                        print("Adding new category: \(newCategory)")
                        
                        // Add the category to the CategoryManager
                        categoryManager.addCategory(newCategory)
                        print("Current targets: \(categoryManager.categories)")
                        
                        // Save to UserDefaults
                        saveCategoriesToUserDefaults()
                        
                        // Start the stability timer only if targets > 0
                        targetReminderManager.startTimerIfTargetsExist()
                        
                        // Dismiss the form
                        dismiss()
                    }) {
                        Text("Save Target")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(targetAmount == 0) // Disable if no budget set                }
                    .padding()
                }
                .navigationBarTitle("Set Your First Target", displayMode: .inline)
            }
        }
    }
}
