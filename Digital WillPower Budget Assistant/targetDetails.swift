//
//  targetDetails.swift
//  Digital WillPower Budget Assistant
//
//  Created by Will Page on 11/16/24.
//

import SwiftUI
import CoreLocation
import MapKit

// MARK: - Location Request
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

// MARK: - Main Targets UI
struct TargetDetailsView: View {
    @EnvironmentObject var categoryManager: CategoryManager
    @EnvironmentObject var targetReminderManager: TargetReminderManager
    @State private var showingAddCategoryForm = false
    @State private var selectedCategory: Category?
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        VStack {
            Text("My Targets")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            VStack {
                Divider()
                    .background(Color(UIColor.opaqueSeparator))
                    .frame(height: 5)
                    .frame(maxWidth: .infinity)

                ScrollView {
                    ForEach(Array(categoryManager.categories.enumerated()), id: \.element.id) { index, category in
                        VStack(spacing: 0) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text("\(category.catName)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .font(.title)
                                    
                                    Text("Target: $\(category.target) /\(category.timeframe)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .font(.subheadline)
                                }
                                
                                
                                Spacer()
                                
                                Text("$\(category.remainingBudget) left")
                                    .padding(.top)
                                    .padding(.trailing)
                            }
                            .contentShape(Rectangle())
                            .onLongPressGesture {
                                selectedCategory = category
                            }
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
                }
                
                .sheet(isPresented: $showingAddCategoryForm) {
                    AddTargetForm(categoryToEdit: nil)
                        .environmentObject(categoryManager)
                        .environmentObject(targetReminderManager)
                }
                .sheet(isPresented: .init(
                    get: { selectedCategory != nil },
                    set: { if !$0 { selectedCategory = nil } }
                )) {
                    if let category = selectedCategory {
                        AddTargetForm(categoryToEdit: category)
                            .environmentObject(categoryManager)
                            .environmentObject(targetReminderManager)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct TargetDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let categoryManager = CategoryManager()
        let targetReminderManager = TargetReminderManager()
        
        return TargetDetailsView()
            .environmentObject(categoryManager)
            .environmentObject(targetReminderManager)
    }
}
