//
//  targetDetails.swift
//  Digital WillPower Budget Assistant
//
//  Created by Will Page on 11/16/24.
//

import SwiftUI
import CoreLocation
import MapKit

// Location request
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestLocationPermission() {
        manager.requestAlwaysAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
}

struct TargetDetailsView: View {
    @EnvironmentObject var categoryManager: CategoryManager
    @EnvironmentObject var targetReminderManager: TargetReminderManager // Add this line
    @State private var showingAddCategoryForm = false
    @StateObject private var locationManager = LocationManager() // Request permission at initialization

    var body: some View {
        VStack {
            let _ = print("Rendering with categories: \(categoryManager.categories)") //debug
            Text("My Targets")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            VStack {
                Divider()
                    .background(Color(UIColor.opaqueSeparator))
                    .frame(height: 5)
                    .frame(maxWidth: .infinity)

                // Iterate through categories and display remaining budget
                ForEach(Array(categoryManager.categories.enumerated()), id: \.element.id) { index, category in
                    VStack(spacing: 0) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text("\(category.catName)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading)

                                Text("Target: $\(category.target) /\(category.timeframe)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading)
                                    .font(.subheadline)
                            }

                            Spacer()

                            // Display remaining budget (already managed by CategoryManager)
                            Text("$\(category.remainingBudget) left")
                                .padding(.top)
                                .padding(.trailing)
                        }
                    }
                }

                Spacer()
            }

            VStack {
                Divider()
                    .background(Color(UIColor.opaqueSeparator))
                    .frame(height: 5)
                    .frame(maxWidth: .infinity)

                HStack {
                    Button(action: { showingAddCategoryForm = true }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Target")
                        }
                        .font(.title)
                        .padding()
                    }
                    
                    Button(action: { categoryManager.clearAllCategories() }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear All")
                        }
                        .font(.title)
                        .padding()
                        .foregroundColor(.red)
                    }
                }
                
                .sheet(isPresented: $showingAddCategoryForm) {
                    AddTargetForm()
                        .environmentObject(categoryManager)
                        .environmentObject(targetReminderManager)
                }
            }
        }
    }
}



// Preview for testing
struct TargetDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let categoryManager = CategoryManager()
        let targetReminderManager = TargetReminderManager()
        
        // Add some sample data for preview
        categoryManager.addCategory(Category(
            catName: "🍔 Eating out",
            target: 100,
            timeframe: "wk",
            remainingBudget: 75
        ))
        
        return TargetDetailsView()
            .environmentObject(categoryManager)
            .environmentObject(targetReminderManager)
    }
}
