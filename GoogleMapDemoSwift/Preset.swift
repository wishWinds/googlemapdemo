//
//  Preset.swift
//  GoogleMapDemoSwift
//
//  Created by shupeng on 2020/11/18.
//

import Foundation
import UIKit
import CoreLocation

class Preset {
    static var monitoringRegion: CLCircularRegion? {
        get {
            if let latitude = UserDefaults.standard.object(forKey: "com.shupeng.googlemapdemo.monitoringLatitude") as? Double,
               let longitude = UserDefaults.standard.object(forKey: "com.shupeng.googlemapdemo.monitoringLongitude") as? Double {
                return CLCircularRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), radius: Preset.regionRadius, identifier: "\(latitude),\(longitude)")
            } else {
                return nil
            }
        }

        set {
            UserDefaults.standard.setValue(newValue?.center.latitude, forKey: "com.shupeng.googlemapdemo.monitoringLatitude")
            UserDefaults.standard.setValue(newValue?.center.longitude, forKey: "com.shupeng.googlemapdemo.monitoringLongitude")
        }
    }
    
    static var regionRadius: Double {
        get {
            if let regionRadius = UserDefaults.standard.object(forKey: "com.shupeng.googlemapdemo.regionRadius") as? Double {
                return regionRadius
            } else {
                self.regionRadius = 100
                return 100
            }
        }

        set {
            UserDefaults.standard.setValue(newValue, forKey: "com.shupeng.googlemapdemo.regionRadius")
        }
    }
    
    static var regionX: Double {
        get {
            if let regionX = UserDefaults.standard.object(forKey: "com.shupeng.googlemapdemo.regionX") as? Double {
                return regionX
            } else {
                self.regionX = 100
                return 100
            }
        }

        set {
            UserDefaults.standard.setValue(newValue, forKey: "com.shupeng.googlemapdemo.regionX")
        }
    }
    
    static var regionY: CGFloat {
        get {
            if let regionY = UserDefaults.standard.object(forKey: "com.shupeng.googlemapdemo.regionY") as? CGFloat {
                return regionY
            } else {
                self.regionY = 100
                return 100
            }
        }

        set {
            UserDefaults.standard.setValue(newValue, forKey: "com.shupeng.googlemapdemo.regionY")
        }
    }
}
