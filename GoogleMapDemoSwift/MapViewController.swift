//
//  ViewController.swift
//  GoogleMapDemoSwift
//
//  Created by dev on 2020/11/11.
//

import UIKit
import GoogleMaps
import SPUIKit
import SPUtilities
import SnapKit

enum CheckState {
    case `in`, out
}
enum SetLocationState {
    case idle, setting
}

class MapViewController: UIViewController {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var setLocationButton: UIBarButtonItem!
    @IBOutlet weak var mapViewWrapper: UIView!
    @IBOutlet weak var distanceHintView: UIView!
    @IBOutlet var settingsButton: UIBarButtonItem!
    
    var checkState: CheckState = .out {
        didSet {
            switch checkState {
            case .in:
                checkButton.setImage(UIImage(named: "checkout"), for: .normal)
                
            case .out:
                checkButton.setImage(UIImage(named: "checkin"), for: .normal)

            }
        }
    }
    
    var setLocationState: SetLocationState = .idle {
        didSet {
            switch setLocationState {
            case .idle:
                setLocationButton.title = nil
                setLocationButton.image = UIImage(named: "mark")
                pinImageView.isHidden = true
                checkButton.isHidden = false
                navigationItem.rightBarButtonItem = settingsButton
                
            case .setting:
                setLocationButton.title = "Done"
                setLocationButton.image = nil
                pinImageView.isHidden = false
                checkButton.isHidden = true
                navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    var mapView: GMSMapView!
    var observation: NSKeyValueObservation?
    var firstUpdateLocation = true
    
    @IBOutlet weak var pinImageView: UIImageView!
    
    var circleView: GMSCircle?
    var polygonView: GMSPolygon?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createMapView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterRegion), name: RegionManager.didEnterRegionNoti, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didExitRegion), name: RegionManager.didExitRegionNoti, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateRegionRadius), name: SettingsViewController.didChangeRadiusNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateRegionX), name: SettingsViewController.didChangeXNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateRegionY), name: SettingsViewController.didChangeYNotification, object: nil)

    }

    @IBAction func checkButtonPressed(_ sender: Any) {
        
        if checkState == .in {
            checkOut()
        } else {
            if isInCheckInRegion() {
                checkIn()
            } else {
                self.alert(withTitle: "Warning!", message: "You are not in Check-In Area") {
                    
                }
            }
        }
    }
    
    func createMapView() {
        guard mapView == nil else {
            return
        }
        let camera = GMSCameraPosition(latitude: -33.710995, longitude: 151.107264, zoom: 12)
        mapView = GMSMapView(frame: mapViewWrapper.bounds, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
//        mapView.settings.myLocationButton = true;
        if let url = Bundle.main.url(forResource: "mapstyle-night", withExtension: "json"),
           let style = try? GMSMapStyle(contentsOfFileURL: url){
            mapView.mapStyle = style
        }
        mapViewWrapper.addSubview(mapView)
        mapView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        observation = mapView.observe(\.myLocation, options: [.new], changeHandler: {
            [unowned self] (mpaView, _) in
            
            // update camera for first get user location
            if self.firstUpdateLocation {
                self.firstUpdateLocation = false
                
                self.mapView.camera = GMSCameraPosition(latitude: self.mapView.myLocation!.coordinate.latitude, longitude: self.mapView.myLocation!.coordinate.longitude, zoom: 15)
            }
            
            if let distance = distance() {
                self.distanceLabel.text = "\(Int(distance)) m"
            } else {
                self.distanceLabel.text = "-"
            }

            if self.isOutOfCheckOutRegion()
                && checkState == .in {
                
                    checkOut()
            }
        })
        
        createOverlayView()

    }
    
    func removeOverlayView() {
        if let circleView = circleView {
            circleView.map = nil
        }
        
        if let polygonView = polygonView {
            polygonView.map = nil
        }
    }
    
    func createOverlayView() {
        if let location = Preset.monitoringLocation {
            polygonView = createPolygon(at: location, x: Double(Preset.regionX), y: Double(Preset.regionY))
            polygonView?.map = mapView
            
            circleView = createCircle(at: location, radius: Preset.regionRadius)
            circleView?.map = mapView
        }
    }
    
    func createCircle(at location: CLLocationCoordinate2D, radius: CLLocationDistance) -> GMSCircle {
        let circle = GMSCircle(position: location, radius: radius)
        circle.fillColor = UIColor(hexString: "72C4A9B3")
        circle.strokeColor = UIColor(hexString: "72C4A9")
        circle.strokeWidth = 1
        circle.zIndex = 1

        return circle
    }
    
    func createPolygon(at location: CLLocationCoordinate2D, x: CLLocationDistance, y: CLLocationDistance) -> GMSPolygon {
        let path = gmsPath(from: location, x: x, y: y)
        
        let polygon = GMSPolygon(path: path)
        polygon.fillColor = UIColor(hexString: "D4656B99")
        polygon.strokeColor = UIColor(hexString: "D4656B")
        polygon.strokeWidth = 1
        polygon.zIndex = 0

        return polygon
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
    
    func createRectangle(at location: CLLocationCoordinate2D, radius: CLLocationDistance) -> GMSCircle {
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
        
    }
    
    @objc func didExitRegion() {
        checkOut()
    }
    
    
    @objc func didUpdateRegionRadius() {
        if let circleView = circleView,
           let location = Preset.monitoringLocation {
            circleView.map = nil
            
            self.circleView = createCircle(at: location, radius: Preset.regionRadius)
            self.circleView?.map = self.mapView
        }
    }
    
    @objc func didUpdateRegionX() {
        if let polygonView = polygonView,
           let location = Preset.monitoringLocation {
            polygonView.map = nil
            
            self.polygonView = createPolygon(at: location, x: Preset.regionX, y: Preset.regionY)
            self.polygonView?.map = self.mapView
        }
    }
    
    @objc func didUpdateRegionY() {
        if let polygonView = polygonView,
           let location = Preset.monitoringLocation {
            polygonView.map = nil
            
            self.polygonView = createPolygon(at: location, x: Preset.regionX, y: Preset.regionY)
            self.polygonView?.map = self.mapView
        }
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func setLocationButtonPressed(_ sender: Any) {
        switch setLocationState {
        case .idle:
            setLocationState = .setting
            
        case .setting:
            setLocationState = .idle
            resetRegionFromMapCenter()
        }
    }
    
    func resetRegionFromMapCenter() {
        let location = mapView.projection.coordinate(for: CGPoint(x: mapView.frame.width/2, y: mapView.frame.height/2))
        RegionManager.shared.stopMonitoringAllRegions()
        
        Preset.monitoringLocation = location
        RegionManager.shared.monitoringRetion(at: location, radius: Preset.regionRadius)
        RegionManager.shared.monitoringRetion(at: location, radius: max(Preset.regionX, Preset.regionY))
        
        removeOverlayView()
        createOverlayView()
    }
    
    func checkIn() {
        checkState = .in
        if let location = Preset.monitoringLocation {
            RegionManager.shared.monitoringRetion(at: location, radius: Preset.regionRadius)
            RegionManager.shared.monitoringRetion(at: location, radius: max(Preset.regionX, Preset.regionY))
        }
        SPHUD.show(with: SPHUDTypeSuccess, title: "You have Check-In", on: view, animated: true, hideAutomatically: true)
    }
    
    func checkOut() {
        checkState = .out
        RegionManager.shared.stopMonitoringAllRegions()
        SPHUD.show(with: SPHUDTypeSuccess, title: "You have Check-Out", on: view, animated: true, hideAutomatically: true)
    }
}

extension MapViewController: GMSMapViewDelegate {

}

extension MapViewController {
    func distance() -> CLLocationDistance? {
        if let location = Preset.monitoringLocation {
            let center = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let current = CLLocation(latitude: self.mapView.myLocation!.coordinate.latitude, longitude: self.mapView.myLocation!.coordinate.longitude)
            let distance = center.distance(from: current)
            
            return distance
        } else {
            return nil
        }
    }
    
    func isInCheckInRegion() -> Bool {
        if let distance = self.distance() {
            return distance <= Double(Preset.regionRadius)
        } else {
            return true
        }
    }
    
    func isOutOfCheckOutRegion() -> Bool {
        if let currentLocation = mapView.myLocation?.coordinate,
            let location = Preset.monitoringLocation {
            let isInPath = GMSGeometryContainsLocation(currentLocation, gmsPath(from: location, x: Preset.regionX, y: Preset.regionY), true)
            print("isInPath: \(isInPath)")
            return !isInPath
        } else {
            return true
        }
    }
}
