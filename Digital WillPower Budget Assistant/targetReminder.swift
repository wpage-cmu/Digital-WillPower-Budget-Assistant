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
    private var stableLocation: CLLocation? // Location where the user has stayed
    private var stableStartTime: Date? // Time when stability started
    private let stabilityThreshold: TimeInterval = 5 // seconds
    private let stillnessThreshold: CLLocationDistance = 4.0 // Ignore small movements
    private var recentNotifications: [String: Date] = [:]
    private let notificationCooldown: TimeInterval = 300 // 5 minutes
    private var cachedResults: [String: [MKMapItem]] = [:] // Cache for PoIs
    private let searchRadius: CLLocationDistance = 50 // meters
    private let cacheExpiry: TimeInterval = 300 // 5 minutes cache expiration
    private var stabilityTimer: Timer? // Timer for periodic stability checks
    
    
    @Published private var categories: [Category] = []
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
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
        
        // Also load initial categories
        if let data = UserDefaults.standard.data(forKey: "categoriesKey"),
           let decodedCategories = try? JSONDecoder().decode([Category].self, from: data) {
            self.categories = decodedCategories
            startTimerIfTargetsExist()
        }
    }
    
    deinit {
        stabilityTimer?.invalidate() // Ensure the timer is stopped when the instance is deallocated
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        // Ignore updates with poor accuracy
        guard newLocation.horizontalAccuracy < 20 else {
            print("Ignoring location update due to poor accuracy: \(newLocation.horizontalAccuracy)")
            return
        }
        
        // Reset stable location and timer for significant movement
        if let stableLocation = stableLocation,
           newLocation.distance(from: stableLocation) > stillnessThreshold {
            print("User moved significantly. Resetting stability.")
            resetStabilityTracking(newLocation)
        } else if stableLocation == nil {
            // First time setting stable location
            resetStabilityTracking(newLocation)
        }
    }
    
    // MARK: - Stability Tracking
    private func resetStabilityTracking(_ location: CLLocation) {
        stableLocation = location
        stableStartTime = Date()
        print("Stable location set: \(location.coordinate)")
        print("Timer started: \(stableStartTime!)")
    }
    
    // MARK: - Stability Evaluation
    private func evaluateStability() {
        guard let stableStartTime = stableStartTime,
              let stableLocation = stableLocation else {
            return // No stable location or timer yet
        }
        
        // Check if the user is within the stillness threshold
        if let lastLocation = locationManager.location {
            if lastLocation.distance(from: stableLocation) < stillnessThreshold {
                let elapsedTime = Date().timeIntervalSince(stableStartTime)
                
                if elapsedTime > stabilityThreshold {
                    print("Stability threshold reached. Searching for PoIs.")
                    searchNearbyPlaces(at: stableLocation)
                    self.stableStartTime = nil // Reset timer after action
                } else {
                    print("User stable for \(elapsedTime) seconds. Waiting to reach threshold.")
                }
            } else {
                // User moved outside stillness threshold
                print("User moved outside stillness threshold. Resetting stability.")
                resetStabilityTracking(lastLocation) // Use `lastLocation` to reset stability
            }
        }
    }
    
    // MARK: - PoI Search
    private func searchNearbyPlaces(at location: CLLocation) {
        let cacheKey = "\(location.coordinate.latitude.rounded(to: 3)),\(location.coordinate.longitude.rounded(to: 3))"
        
        // Use cached results if available
        if let cachedPlaces = cachedResults[cacheKey],
           let cacheTimestamp = cachedPlaces.first?.timeStamp,
           Date().timeIntervalSince(cacheTimestamp) < cacheExpiry {
            print("Using cached results for location: \(cacheKey)")
            processPlaces(cachedPlaces)
            return
        }
        
        // Perform a new search
        print("Performing new search for location: \(location.coordinate)")
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "restaurant OR store OR market"
        searchRequest.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: searchRadius,
            longitudinalMeters: searchRadius
        )
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, error == nil else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let places = response.mapItems.map { mapItem -> MKMapItem in
                var item = mapItem
                item.timeStamp = Date() // Attach timestamp for caching
                return item
            }
            
            self.cachedResults[cacheKey] = places
            self.processPlaces(places)
        }
    }
    
    // MARK: - Process Places
    private func processPlaces(_ places: [MKMapItem]) {
        print("Found \(places.count) total places")
            places.forEach { place in
                print("Place: \(place.name ?? "unnamed"), Category: \(place.pointOfInterestCategory?.rawValue ?? "none")")
            }
        
        // Get the user's target categories from our local categories array
        let userTargetCategories = categories.map { $0.catName }
        
        // Filter places that match the user's target categories
        let matchingPlaces = places.filter { place in
            guard let mapKitCategory = place.pointOfInterestCategory else { return false }
            if let placeCategory = CategoryMapper.mapToPlaceCategory(mapKitCategory) {
                return userTargetCategories.contains(placeCategory.rawValue)
            }
            return false
        }
        
        if matchingPlaces.isEmpty {
            print("No relevant places found.")
            return
        }
        
        // For matching places, find the corresponding category and send notification
        if let closestPlace = matchingPlaces.first,
           let mapKitCategory = closestPlace.pointOfInterestCategory,
           let placeCategory = CategoryMapper.mapToPlaceCategory(mapKitCategory),
           let category = categories.first(where: { $0.catName == placeCategory.rawValue }) {
            
            sendNotification(for: closestPlace.name ?? "a location", category: category)
        }
    }
    
    // MARK: - Notifications
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
    
    // MARK: - Public Method to Start Timer After First Target
    func startTimerIfTargetsExist() {
        // Stop existing timer if any
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


// MARK: - Extensions
extension Double {
    func rounded(to decimals: Int) -> Double {
        let multiplier = pow(10.0, Double(decimals))
        return (self * multiplier).rounded() / multiplier
    }
}

extension MKMapItem {
    private struct AssociatedKeys {
        static var timeStamp = "timeStamp"
    }

    var timeStamp: Date? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.timeStamp) as? Date }
        set { objc_setAssociatedObject(self, &AssociatedKeys.timeStamp, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
