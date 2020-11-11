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

class ViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var controlPanel: UIView!
    @IBOutlet weak var stateView: UIView!
    
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
    
    var mapView: GMSMapView!
    var observation: NSKeyValueObservation?
    var firstUpdateLocation = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        createMapView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
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
        let camera = GMSCameraPosition(latitude: monitoringLocation.latitude, longitude: monitoringLocation.longitude, zoom: 12)
        mapView = GMSMapView(frame: view.bounds, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        
        view.insertSubview(mapView, belowSubview: controlPanel)
        
        observation = mapView.observe(\.myLocation, options: [.new], changeHandler: {
            [unowned self] (mpaView, _) in
            
            if self.firstUpdateLocation {
                self.firstUpdateLocation = false
                
                self.mapView.camera = GMSCameraPosition(latitude: self.mapView.myLocation!.coordinate.latitude, longitude: self.mapView.myLocation!.coordinate.longitude, zoom: 15)
            }
        })
        
        createCircle()
    }
    
    func createCircle() {
        let circle = GMSCircle(position: monitoringLocation, radius: regionRadius)
        circle.strokeWidth = 0
        circle.fillColor = UIColor(red: 0.5, green: 0.67, blue: 1, alpha: 0.66)
        
        circle.map = mapView
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
}

