//
//  AppDelegate.swift
//  GoogleMapDemoSwift
//
//  Created by dev on 2020/11/11.
//

import UIKit
import UserNotifications
import CoreLocation
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupLocalNotification()
        setupGMS()
        setupLocationManager()
        setupRegions()
        
        return true
    }
    
    func setupLocalNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            
        }
    }
    
    func setupGMS() {
        GMSServices.provideAPIKey(gmsKey)
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5.0
        
        // disallow background mode for power efficiency
        if powerEfficiencyEnabled {
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.allowsBackgroundLocationUpdates = false
        } else {
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.allowsBackgroundLocationUpdates = true
            
            locationManager.startUpdatingLocation()
        }

    }
    
    func setupRegions() {
        clearPreviousRegions()
        
        monitoringRetion(at: monitoringLocation)
    }
    
    func clearPreviousRegions() {
        locationManager.monitoredRegions.forEach { (region) in
            locationManager.stopMonitoring(for: region)
        }
    }
    
    func monitoringRetion(at location: CLLocationCoordinate2D) {
        var radius = CLLocationDistance(regionRadius * regionRadiusRadioForCoreLocation)
        radius = min(locationManager.maximumRegionMonitoringDistance, radius)
        
        let region = CLCircularRegion(center: location, radius: radius, identifier: "\(location.latitude),\(location.longitude)")
        locationManager.startMonitoring(for: region)
        
    }

    func notify(_ msg: String) {
        guard UIApplication.shared.applicationState != .active else {
            return
        }
        
        let notiContent = UNMutableNotificationContent()
        notiContent.title = "GoogleMapDemoSwift"
        notiContent.body = msg
        notiContent.sound = .default
        
        let request = UNNotificationRequest(identifier: "noti", content: notiContent, trigger: nil)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        notify("Check In")
        if let vc = window?.rootViewController as? ViewController {
            vc.checkState = .in
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        notify("Check Out")
        if let vc = window?.rootViewController as? ViewController {
            vc.checkState = .out
        }
    }
}
