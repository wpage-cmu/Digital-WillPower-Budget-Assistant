//
//  targetReminder.swift
//  Digital WillPower Budget Assistant
//
//  Created by Will Page in Q4 2024.
//

import Foundation
import SwiftUI
import MapKit
import Combine
import UserNotifications

class TargetReminderManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var stableLocation: CLLocation?
    private var stableStartTime: Date?
    private let stabilityThreshold: TimeInterval = 5 // seconds
    private let stillnessThreshold: CLLocationDistance = 4.0 // meters
    private let searchRadius: CLLocationDistance = 25 // meters
    private var recentNotifications: [String: Date] = [:]
    private let notificationCooldown: TimeInterval = 300 // 5 minutes
    private var stabilityTimer: Timer?
    
    @Published private var categories: [Category] = []
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // Load categories from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "categoriesKey"),
           let decodedCategories = try? JSONDecoder().decode([Category].self, from: data) {
            self.categories = decodedCategories
            startTimerIfTargetsExist()
        }
        
        // Watch for category changes
        NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                if let data = UserDefaults.standard.data(forKey: "categoriesKey"),
                   let decodedCategories = try? JSONDecoder().decode([Category].self, from: data) {
                    self?.categories = decodedCategories
                    self?.startTimerIfTargetsExist()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Grab location to start stability logic
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        guard newLocation.horizontalAccuracy < 20 else {
            print("Ignoring location update due to poor accuracy: \(newLocation.horizontalAccuracy)")
            return
        }
        
        if let stableLocation = stableLocation,
           newLocation.distance(from: stableLocation) > stillnessThreshold {
            print("User moved significantly. Resetting stability.")
            resetStabilityTracking(newLocation)
        } else if stableLocation == nil {
            resetStabilityTracking(newLocation)
        }
    }
    
    // MARK: - Stability logic
    private func resetStabilityTracking(_ location: CLLocation) {
        stableLocation = location
        stableStartTime = Date()
        print("Stable location set: \(location.coordinate)")
        print("Timer started: \(stableStartTime!)")
    }
    
    private func evaluateStability() {
        guard let stableStartTime = stableStartTime,
              let stableLocation = stableLocation,
              let currentLocation = locationManager.location else { return }
        
        if currentLocation.distance(from: stableLocation) < stillnessThreshold {
            let elapsedTime = Date().timeIntervalSince(stableStartTime)
            
            if elapsedTime > stabilityThreshold {
                print("Stability threshold reached. Searching for PoIs.")
                checkLocation(stableLocation)
                self.stableStartTime = nil
            } else {
                print("User stable for \(elapsedTime) seconds. Waiting to reach threshold.")
            }
        } else {
            print("User moved outside stillness threshold. Resetting stability.")
            resetStabilityTracking(currentLocation)
        }
    }
   
    // MARK: - Location search once stability has been established
    private func checkLocation(_ location: CLLocation) {
        print("📍 Starting location search at: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        print("🎯 Search radius: \(Int(searchRadius))m")
        
        // Create a points of interest request
        let pointRequest = MKLocalPointsOfInterestRequest(center: location.coordinate, radius: searchRadius)
        
        // Get relevant categories from user targets
        let relevantCategories = Array(Set(categories.compactMap { category -> MKPointOfInterestCategory? in
            guard let placeCategory = PlaceCategory(rawValue: category.catName) else { return nil }
            return CategoryMapper.getMKCategory(for: placeCategory)
        }))
        
        // Set filter to only get relevant categories
        pointRequest.pointOfInterestFilter = MKPointOfInterestFilter(including: relevantCategories)
        
        print("🔍 Search configuration:")
        print("   Categories: \(relevantCategories.map { $0.rawValue })")
        
        // Create search with the point request
        let search = MKLocalSearch(request: pointRequest)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Search error: \(error.localizedDescription)")
                return
            }
            
            guard let response = response else {
                print("⚠️ No response received")
                return
            }
            
            print("📍 Places found: \(response.mapItems.count)")
            
            // Log all found places
            response.mapItems.forEach { place in
                guard let placeLoc = place.placemark.location else { return }
                let distance = location.distance(from: placeLoc)
                print("✅ \(place.name ?? "unnamed")")
                print("   Distance: \(String(format: "%.1f", distance))m")
                print("   Category: \(place.pointOfInterestCategory?.rawValue ?? "none")")
                print("   Location: \(placeLoc.coordinate.latitude), \(placeLoc.coordinate.longitude)\n")
            }
            
            // Process matching places
            let matchingPlaces = response.mapItems
                .compactMap { place -> (MKMapItem, Double)? in
                    guard let placeLoc = place.placemark.location else { return nil }
                    return (place, location.distance(from: placeLoc))
                }
                .filter { place, _ in
                    guard let mapKitCategory = place.pointOfInterestCategory,
                          let placeCategory = CategoryMapper.mapToPlaceCategory(mapKitCategory) else {
                        return false
                    }
                    return self.categories.contains { $0.catName == placeCategory.rawValue }
                }
                .sorted { $0.1 < $1.1 }
            
            print("\n🎯 Matching places: \(matchingPlaces.count)")
            
            // Send notification for exact or closest match
            if let exactMatch = matchingPlaces.first(where: { abs($0.1) < 0.1 }), // 0.1m threshold
               let mapKitCategory = exactMatch.0.pointOfInterestCategory,
               let placeCategory = CategoryMapper.mapToPlaceCategory(mapKitCategory),
               let category = self.categories.first(where: { $0.catName == placeCategory.rawValue }) {
                
                print("🎯 Found exact location match: \(exactMatch.0.name ?? "unnamed")")
                self.sendNotification(for: exactMatch.0.name ?? "a location", category: category)
            }
            else if let closestPlace = matchingPlaces.first,
                    let mapKitCategory = closestPlace.0.pointOfInterestCategory,
                    let placeCategory = CategoryMapper.mapToPlaceCategory(mapKitCategory),
                    let category = self.categories.first(where: { $0.catName == placeCategory.rawValue }) {
                
                print("🎯 Using closest match: \(closestPlace.0.name ?? "unnamed") at \(String(format: "%.1f", closestPlace.1))m")
                self.sendNotification(for: closestPlace.0.name ?? "a location", category: category)
            }
        }
    }
  
    // MARK: - Send notification
    private func sendNotification(for placeName: String, category: Category) {
        let now = Date()
        if let lastNotification = recentNotifications[placeName],
           now.timeIntervalSince(lastNotification) < notificationCooldown {
            print("Skipping notification for \(placeName) due to cooldown.")
            return
        }
        
        recentNotifications[placeName] = now
        print("Sending notification for \(placeName)")
        
        let content = UNMutableNotificationContent()
        content.title = "Budget Reminder"
        content.body = "You're at \(placeName). Your target budget for \(category.catName) is $\(category.target) per \(category.timeframe). You have $\(category.remainingBudget) left."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error.localizedDescription)")
            } else {
                print("Notification sent for \(placeName)")
            }
        }
    }
 
    // MARK: - Start initial stability timer
    func startTimerIfTargetsExist() {
        stabilityTimer?.invalidate()
        if !categories.isEmpty {
            print("Starting stability timer - categories exist")
            stabilityTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.evaluateStability()
            }
        } else {
            print("No categories exist - timer not started")
        }
    }
}
