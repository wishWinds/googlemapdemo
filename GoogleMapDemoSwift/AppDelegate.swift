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
        RegionManager.shared
        
        if let _ = launchOptions?[UIApplication.LaunchOptionsKey.location] {
            UNUserNotificationCenter.current().pushNotitfication(with: "Launch", body: "App has launch in background from location service")
        }
        
        return true
    }
    
    func setupLocalNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            
        }
    }
    
    func setupGMS() {
        GMSServices.provideAPIKey(gmsKey)
    }
}
