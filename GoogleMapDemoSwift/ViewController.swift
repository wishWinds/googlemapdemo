//
//  ViewController.swift
//  GoogleMapDemoSwift
//
//  Created by dev on 2020/11/11.
//

import UIKit
import GoogleMaps

enum CheckState {
    case `in`, out
}
enum SetLocationState {
    case idle, setting
}

class ViewController: UIViewController {

    @IBOutlet weak var controlPanel: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stateView: UIView!
    
    @IBOutlet weak var setLocationButton: UIBarButtonItem!
    
    var checkState: CheckState = .out {
        didSet {
            switch checkState {
            case .in:
                stateView.backgroundColor = .green
                
            case .out:
                stateView.backgroundColor = .red
            }
        }
    }
    
    var setLocationState: SetLocationState = .idle {
        didSet {
            switch setLocationState {
            case .idle:
                setLocationButton.title = "Set Location"
                pinImageView.isHidden = true
                
            case .setting:
                setLocationButton.title = "Done"
                pinImageView.isHidden = false
            }
        }
    }
    
    var mapView: GMSMapView!
    var observation: NSKeyValueObservation?
    var firstUpdateLocation = true
    
    @IBOutlet weak var pinImageView: UIImageView!
    
    var circleView: GMSCircle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        createMapView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterRegion), name: RegionManager.didEnterRegionNoti, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didExitRegion), name: RegionManager.didExitRegionNoti, object: nil)
    }

    @IBAction func checkinButtonPressed(_ sender: Any) {
        self.checkState = .in
    }
    
    @IBAction func checkoutButtonPressed(_ sender: Any) {
        self.checkState = .out
    }
    
    func createMapView() {
        guard mapView == nil else {
            return
        }
        let camera = GMSCameraPosition(latitude: -33.710995, longitude: 151.107264, zoom: 12)
        mapView = GMSMapView(frame: view.bounds, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
//        mapView.settings.myLocationButton = true;
        view.insertSubview(mapView, belowSubview: controlPanel)
        
        observation = mapView.observe(\.myLocation, options: [.new], changeHandler: {
            [unowned self] (mpaView, _) in
            
            NSLog("google map: %@", self.mapView.myLocation ?? "")
            if self.firstUpdateLocation {
                self.firstUpdateLocation = false
                
                self.mapView.camera = GMSCameraPosition(latitude: self.mapView.myLocation!.coordinate.latitude, longitude: self.mapView.myLocation!.coordinate.longitude, zoom: 15)
            }
            
            if let region = RegionManager.shared.allMonitoringRegions().first as? CLCircularRegion {
                let center = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
                let current = CLLocation(latitude: self.mapView.myLocation!.coordinate.latitude, longitude: self.mapView.myLocation!.coordinate.longitude)
                let distance = center.distance(from: current)
                self.distanceLabel.text = "\(Int(distance)) m"
                
                if distance <= 100 {
                    self.checkState = .in
                } else {
                    self.checkState = .out
                }
            }
        })
        
        if let region = RegionManager.shared.allMonitoringRegions().first as? CLCircularRegion {
            circleView = createCircle(at: region.center, radius: region.radius)
        }
    }
    
    func createCircle(at location: CLLocationCoordinate2D, radius: CLLocationDistance) -> GMSCircle {
        let circle = GMSCircle(position: location, radius: radius)
        circle.strokeWidth = 0
        circle.fillColor = UIColor(red: 0.5, green: 0.67, blue: 1, alpha: 0.66)
        
        circle.map = mapView
        
        return circle
    }
    
    func destroyMapView() {
        mapView.removeFromSuperview()
        mapView = nil
        firstUpdateLocation = true
        observation?.invalidate()
    }
    
    @objc func appDidEnterBackground() {
        destroyMapView()
    }
    
    @objc func appDidBecomeActive() {
        createMapView()
    }
    
    @objc func didEnterRegion() {
        checkState = .in
    }
    
    @objc func didExitRegion() {
        checkState = .out
    }
    
    @IBAction func setLocationButtonPressed(_ sender: Any) {
        switch setLocationState {
        case .idle:
            setLocationState = .setting
            
        case .setting:
            setLocationState = .idle
            setRegion()
        }
    }
    
    func setRegion() {
        let location = mapView.projection.coordinate(for: CGPoint(x: mapView.frame.width/2, y: mapView.frame.height/2))
        RegionManager.shared.stopMonitoringAllRegions()
        RegionManager.shared.monitoringRetion(at: location, radius: monitoringRegionRadius)
        
        if let circleView = circleView {
            circleView.map = nil
        }
        
        circleView = createCircle(at: location, radius: monitoringRegionRadius)
    }
}

extension ViewController: GMSMapViewDelegate {

}
