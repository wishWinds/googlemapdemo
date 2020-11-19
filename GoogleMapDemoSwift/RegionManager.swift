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
import GoogleMaps

class RegionManager: NSObject {
    static let didEnterRegionNoti = NSNotification.Name("didEnterRegionNoti")
    static let didExitRegionNoti = NSNotification.Name("didExitRegionNoti")

    
    static let shared = RegionManager()
    
    var locationManager = CLLocationManager()
    
    var currentLocation: CLLocation?
        
    override init() {
        super.init()
        
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5.0
        
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = false
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateRadius), name: SettingsViewController.didChangeRadiusNotification, object: nil)
        
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
        
        let region = CLCircularRegion(center: location, radius: radius, identifier: "\(location.latitude),\(location.longitude),\(radius)")
        monitoring(region: region)
    }
    
    func monitoring(region: CLCircularRegion) {
        locationManager.startMonitoring(for: region)
    }
    
    @objc func didUpdateRadius() {
        if let region = locationManager.monitoredRegions.first as? CLCircularRegion {

            stopMonitoringAllRegions()
            monitoringRetion(at: region.center, radius: Preset.regionRadius)
            monitoringRetion(at: region.center, radius: max(Preset.regionX, Preset.regionY))
        }
    }
    
    func isOutOfCheckOutRegion() -> Bool {
        if let currentLocation = currentLocation,
            let location = Preset.monitoringLocation {
            let isInPath = GMSGeometryContainsLocation(currentLocation.coordinate, gmsPath(from: location, x: Preset.regionX, y: Preset.regionY), true)
            print("isInPath: \(isInPath)")
            return !isInPath
        } else {
            return true
        }
    }
    
    func gmsPath(from location: CLLocationCoordinate2D, x: CLLocationDistance, y: CLLocationDistance) -> GMSPath {
        let path = GMSMutablePath();
        var leftTop = GMSGeometryOffset(location, x, CLLocationDirection(270))
        leftTop = GMSGeometryOffset(leftTop, y, CLLocationDirection(0))
        
        let rightTop = GMSGeometryOffset(leftTop, 2*x, CLLocationDirection(90))
        let rightBottom = GMSGeometryOffset(rightTop, 2*y, CLLocationDirection(180))
        let leftBottom = GMSGeometryOffset(rightBottom, 2*x, CLLocationDirection(270))
    
        path.add(leftTop)
        path.add(rightTop)
        path.add(rightBottom)
        path.add(leftBottom)
        
        return path
    }
    
    func identifier(location: CLLocationCoordinate2D, radius: CLLocationDistance) -> String {
        return "\(location.latitude),\(location.longitude),\(radius)"
    }
}

extension RegionManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        UNUserNotificationCenter.current().pushNotitfication(with: "Noti", body: "Check In")
        NotificationCenter.default.post(name: RegionManager.didEnterRegionNoti, object: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if UIApplication.shared.applicationState == .active {
            return
        }
        if let location = Preset.monitoringLocation {
            if identifier(location: location, radius: max(Preset.regionX, Preset.regionY)) == region.identifier {
                UNUserNotificationCenter.current().pushNotitfication(with: "Noti", body: "Check Out")
                NotificationCenter.default.post(name: RegionManager.didExitRegionNoti, object: region)
            }
        }
    }
    
    // 如果在中国，google地图拿wgs的坐标点会当作gcj02的坐标点进行显示。
    // 如果要正确显示，需要传入gcj02的坐标点给google地图。
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach { (location) in
            print(location)
            let wgsLocation = JZLocationConverter.wgs84(toGcj02: location.coordinate)
            print("wgs: \(wgsLocation)")
        }
        
        currentLocation = locations.last
        
//        if isOutOfCheckOutRegion() {
//            if let nav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
//               let mapVC = nav.viewControllers.first as? MapViewController {
//                if mapVC.checkState == .in {
//                    mapVC.checkOut()
//                }
//            }
//        }
    }
}
