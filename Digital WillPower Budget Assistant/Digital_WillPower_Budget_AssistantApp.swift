//
//  Digital_WillPower_Budget_AssistantApp.swift
//  Digital WillPower Budget Assistant
//
//  Created by Will Page on 11/6/24.
//
import SwiftUI

@main
struct Digital_WillPower_Budget_AssistantApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var categoryManager = CategoryManager()
    @StateObject private var targetReminderManager = TargetReminderManager()

    var body: some Scene {
        WindowGroup {
            if categoryManager.categories.isEmpty { // Show the Add Target form if no categories exist
                AddTargetForm()
                    .environmentObject(categoryManager)
                    .environmentObject(targetReminderManager)
            } else {
                TargetDetailsView()
                    .onAppear {
                        requestNotificationPermissions()
                        locationManager.requestLocationPermission()
                    }
                    .environmentObject(categoryManager)
                    .environmentObject(targetReminderManager)
            }
        }
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            print("Notifications permission granted: \(granted)")
        }
    }

    private func startStabilityTimer() {
        // Start the stability timer here
        print("Stability timer started after first target submission")
    }
}
