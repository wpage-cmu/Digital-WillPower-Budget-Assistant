//
//  addTarget.swift
//  Digital WillPower Budget Assistant
//
//  Created by Will Page on 11/16/24.
//
import SwiftUI

// MARK: Add/Edit Target Form
struct AddTargetForm: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var categoryManager: CategoryManager
    @EnvironmentObject var targetReminderManager: TargetReminderManager
    
    @State private var selectedCategory: PlaceCategory = .restaurant
    @State private var selectedTimeframe: TimeCategory = .week
    @State private var targetAmount: Int = 0
    @State private var amountString = ""
    
    let categoryToEdit: Category?
    
    init(categoryToEdit: Category? = nil) {
        self.categoryToEdit = categoryToEdit
        if let category = categoryToEdit {
            let catType = PlaceCategory(rawValue: category.catName) ?? .restaurant
            let timeType = TimeCategory(rawValue: category.timeframe) ?? .week
            _selectedCategory = State(initialValue: catType)
            _selectedTimeframe = State(initialValue: timeType)
            _targetAmount = State(initialValue: category.target)
            _amountString = State(initialValue: String(category.target))
        }
    }
    
    private func saveCategoriesToUserDefaults() {
        if let encodedCategories = try? JSONEncoder().encode(categoryManager.categories) {
            UserDefaults.standard.set(encodedCategories, forKey: "categoriesKey")
        }
    }
    
    var body: some View {
        NavigationView {
                VStack(spacing: 20) {
                    // Categories Section
                    VStack {
                        Text("Choose a Category")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            ForEach(PlaceCategory.allCases, id: \.self) { category in
                                let emoji = String(category.rawValue.prefix(2))  // Get emoji
                                let label = String(category.rawValue.dropFirst(2))  // Get text after emoji
                                
                                VStack {
                                    Button(action: {
                                        selectedCategory = category
                                    }) {
                                        Text(emoji)
                                            .font(.system(size: 40))
                                            .padding()
                                            .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.3))
                                            .foregroundColor(.white)
                                            .clipShape(Circle())
                                    }
                                    
                                    Text(label)
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(. primary)
                                }
                                .padding(10)
                            }
                        }
                    }
                    
                    // Timeframe Section
                    VStack {
                        Text("Choose a Timeframe")
                            .font(.title)
                            .fontWeight(.bold)
                        
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
                        .padding(10)
                    }
                    
                    // Budget Section
                    VStack {
                        Text("Set Your Budget")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Spacer()
                            HStack {
                                Text("$")
                                    .font(.title)
                                    .padding(.horizontal)
                                TextField("0", text: $amountString)
                                    .keyboardType(.numberPad)
                                    .font(.title)
                                    .frame(width: 100)
                                    .multilineTextAlignment(.leading)
                                    .onChange(of: amountString) { oldValue, newValue in
                                        if let number = Int(newValue) {
                                            targetAmount = number
                                        }
                                    }
                                Text("per \(selectedTimeframe.rawValue)")
                                    .font(.title)
                                    .padding(.horizontal)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(10)
                    
                    Spacer()
                    // Save Button
                      Button(action: {
                          if let categoryToEdit = categoryToEdit {
                              var updatedCategory = categoryToEdit
                              updatedCategory.catName = selectedCategory.rawValue
                              updatedCategory.target = targetAmount
                              updatedCategory.timeframe = selectedTimeframe.rawValue
                              updatedCategory.remainingBudget = targetAmount
                              categoryManager.updateCategory(updatedCategory)
                          } else {
                              let newCategory = Category(
                                  catName: selectedCategory.rawValue,
                                  target: targetAmount,
                                  timeframe: selectedTimeframe.rawValue,
                                  remainingBudget: targetAmount
                              )
                              categoryManager.addCategory(newCategory)
                          }
                          saveCategoriesToUserDefaults()
                          targetReminderManager.startTimerIfTargetsExist()
                          dismiss()
                      }) {
                          Text("Save Target")
                              .font(.title)
                              .foregroundColor(.white)
                              .padding(20)
                              .background(Color.blue)
                              .cornerRadius(10)
                      }
                      .disabled(targetAmount == 0)
                      
                      // Delete Button - only show when editing
                      if categoryToEdit != nil {
                          Button(action: {
                              if let category = categoryToEdit {
                                  categoryManager.deleteCategory(category)
                              }
                              dismiss()
                          }) {
                              Text("Delete Target")
                                  .font(.title)
                                  .foregroundColor(.white)
                                  .padding(20)
                                  .background(Color.red)
                                  .cornerRadius(10)
                          }
                      }
                  }
                  .padding(.vertical, 40)
              }
              .navigationBarTitle("Set a target", displayMode: .inline)
          }
      }

// MARK: - Preview
struct AddTargetForm_Previews: PreviewProvider {
    static var previews: some View {
        let previewCategoryManager = CategoryManager()
        let previewTargetReminderManager = TargetReminderManager()
        
        previewCategoryManager.saveToUserDefaults = false
        
        return AddTargetForm()
            .environmentObject(previewCategoryManager)
            .environmentObject(previewTargetReminderManager)
            .previewLayout(.sizeThatFits)
    }
}
