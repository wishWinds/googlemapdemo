//
//  RegionManager.swift
//  GoogleMapDemoSwift
//
//  Created by shupeng on 2020/11/12.
//

import Foundation
import UIKit
import CoreLocation
import JZLocationConverter

class RegionManager: NSObject {
    static let didEnterRegionNoti = NSNotification.Name("didEnterRegionNoti")
    static let didExitRegionNoti = NSNotification.Name("didExitRegionNoti")

    
    static let shared = RegionManager()
    
    var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5.0
        
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = false
        
//        locationManager.startUpdatingLocation()
    }
    
    func allMonitoringRegions() -> Set<CLRegion> {
        return locationManager.monitoredRegions
    }
    
    func stopMonitoringAllRegions() {
        locationManager.monitoredRegions.forEach { (region) in
            locationManager.stopMonitoring(for: region)
        }
    }
    
    func monitoringRetion(at location: CLLocationCoordinate2D, radius: CLLocationDistance) {
        let radius = min(locationManager.maximumRegionMonitoringDistance, radius)
        
        let region = CLCircularRegion(center: location, radius: radius, identifier: "\(location.latitude),\(location.longitude)")
        locationManager.startMonitoring(for: region)
    }
    
    func monitoring(region: CLCircularRegion) {
        locationManager.startMonitoring(for: region)
    }
}

extension RegionManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        UNUserNotificationCenter.current().pushNotitfication(with: "Noti", body: "Check In")
        NotificationCenter.default.post(name: RegionManager.didEnterRegionNoti, object: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        UNUserNotificationCenter.current().pushNotitfication(with: "Noti", body: "Check Out")
        NotificationCenter.default.post(name: RegionManager.didExitRegionNoti, object: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach { (location) in
            print(location)
            let wgsLocation = JZLocationConverter.wgs84(toGcj02: location.coordinate)
            print("wgs: \(wgsLocation)")
        }

    }
}
