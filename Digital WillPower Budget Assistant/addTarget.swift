//
//  addTarget.swift
//  Digital WillPower Budget Assistant
//
//  Created by Will Page in Q4 2024.
//
import SwiftUI

struct AddTargetForm: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var categoryManager: CategoryManager
    @EnvironmentObject var targetReminderManager: TargetReminderManager
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
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
    
    // MARK: - Commits targets to local storage
    private func saveCategoriesToUserDefaults() {
        if let encodedCategories = try? JSONEncoder().encode(categoryManager.categories) {
            UserDefaults.standard.set(encodedCategories, forKey: "categoriesKey")
        }
    }
   
    // MARK: - Add target form
    var body: some View {
        NavigationView {
            Group {
                if verticalSizeClass == .compact {
                    // Landscape layout
                    VStack {
                        HStack {
                            // Left side - Categories
                            VStack {
                                Text("Choose a Category")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 15) {
                                    ForEach(PlaceCategory.allCases, id: \.self) { category in
                                        let emoji = String(category.rawValue.prefix(2))
                                        let label = String(category.rawValue.dropFirst(2))
                                        
                                        VStack {
                                            Button(action: { selectedCategory = category }) {
                                                Text(emoji)
                                                    .font(.system(size: 30))
                                                    .padding()
                                                    .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.3))
                                                    .foregroundColor(.white)
                                                    .clipShape(Circle())
                                            }
                                            
                                            Text(label)
                                                .font(.callout)
                                                .multilineTextAlignment(.center)
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: .infinity, alignment: .top)
                            .padding()
                            .padding(.top, 40)
                            .frame(maxWidth: .infinity)
                            
                            // Right side - Budget and Timeframe
                            VStack(spacing: 30) {
                                // Budget Section
                                VStack {
                                    Text("Set Your Budget")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    
                                    HStack {
                                        Text("$")
                                            .font(.title)
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
                                    }
                                }
                                
                                // Timeframe Section
                                VStack {
                                    Text("Choose a Timeframe")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    
                                    HStack {
                                        ForEach(TimeCategory.allCases, id: \.self) { timeframe in
                                            Button(action: { selectedTimeframe = timeframe }) {
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
                            }
                            .padding()
                            .padding(.top, 40)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Action Buttons
                        HStack(spacing: 15) {
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
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 15)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .disabled(targetAmount == 0)
                            
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
                                        .padding(.horizontal, 40)
                                        .padding(.vertical, 15)
                                        .background(Color.red)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                } else {
                    // Portrait layout
                    VStack(spacing: 20) {
                        // Categories Section
                        VStack {
                            Text("Choose a Category")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            HStack {
                                ForEach(PlaceCategory.allCases, id: \.self) { category in
                                    let emoji = String(category.rawValue.prefix(2))
                                    let label = String(category.rawValue.dropFirst(2))
                                    
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
                                            .foregroundColor(.primary)
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
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(10)
                        
                        Spacer()
                        
                        // Action Buttons
                        VStack(spacing: 15) {
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
                    }
                    .padding(.vertical, 40)
                }
            }

        }
    }
}

// MARK: - Preview
struct AddTargetForm_Previews: PreviewProvider {
    static var previews: some View {
        let previewCategoryManager = CategoryManager()
        let previewTargetReminderManager = TargetReminderManager()
        @EnvironmentObject var targetReminderManager: TargetReminderManager
        
        Group {
            AddTargetForm(categoryToEdit: nil)
                .environmentObject({
                    let manager = CategoryManager()
                    manager.saveToUserDefaults = false
                    return manager
                }())
                .environmentObject(targetReminderManager)
                .previewLayout(.sizeThatFits)
            
            AddTargetForm(categoryToEdit: nil)
                .environmentObject({
                    let manager = CategoryManager()
                    manager.saveToUserDefaults = false
                    return manager
                }())
                .environmentObject(targetReminderManager)
                .previewLayout(.sizeThatFits)
                .environment(\.verticalSizeClass, .compact)
        }
    }
}
