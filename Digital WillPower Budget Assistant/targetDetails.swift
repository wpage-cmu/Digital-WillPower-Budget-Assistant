//
//  target_details.swift
//  Digital WillPower Budget Assistant
//
//  Created by Will Page on 11/16/24.
//

import SwiftUI

struct TargetDetailsView: View {
    @Binding var categories: [Category] // Binding to categories from ContentView
    @State private var remainingBudgets: [UUID: Int] = [:] // Store remaining budgets for each category
    
    // Simulated function to fetch remaining budget (you’ll replace this with Plaid API calls)
    private func fetchRemainingBudget(for categoryId: UUID) -> Int {
        // This simulates a budget remaining value, replace with Plaid API call
        return 150 // Random number as a placeholder
    }
    
    var body: some View {
        VStack {
            Text("Target Details")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            // List of categories with remaining budgets
            VStack {
                // List of categories and targets
                ForEach(categories) { category in
                    VStack(spacing: 0) {
                        Divider() // Line at the top of the target
                            .background(Color(UIColor.opaqueSeparator)) // Optional: Customize color
                            .frame(height: 5)
                            .frame(maxWidth: .infinity)
                        
                        HStack(alignment: .top) { // Align the elements vertically at the top
                            VStack(alignment: .leading) {
                                Text("\(category.catName)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading)
                                    .padding(.top)
                                    .foregroundColor(Color(.label))
                                
                                Text("Target: $\(category.target) /\(category.timeframe)")
                                    .frame(maxWidth: .infinity, alignment: .leading)  // Align target to the left
                                    .padding(.leading)
                                    .foregroundColor(Color(.label))
                                    .font(.subheadline)
                            }
                            
                            Spacer() // Push the right content to the far right
                            
                            Text("$\(remainingBudgets[category.id] ?? fetchRemainingBudget(for: category.id)) left")
                                .foregroundColor(Color(.label))
                                .padding(.top)
                                .padding(.trailing)
                        }
                        .foregroundColor(Color(red: 1.0, green: 0.98, blue: 0.94))
                        .font(.custom("target", fixedSize: 24))
                    }
                    
                    Divider() // Line at the bottom of the target
                        .background(Color(UIColor.opaqueSeparator)) // Optional: Customize color
                        .frame(maxWidth: .infinity)
                        .onAppear {
                            // Fetch remaining budget when category appears
                            if remainingBudgets[category.id] == nil {
                                let budget = fetchRemainingBudget(for: category.id)
                                remainingBudgets[category.id] = budget
                            }
                        }
                }
                
                Spacer()
            }
            .navigationTitle("All Targets")
        }
    }
}

#Preview {
    TargetDetailsView(categories: .constant([Category(catName: "🍔 Eating out", target: 400, timeframe: "month")]))
}
