//
//  SettingsViewController.swift
//  GoogleMapDemoSwift
//
//  Created by shupeng on 2020/11/18.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    
    static var didChangeRadiusNotification = NSNotification.Name(rawValue: "didChangeRadiusNotification")
    static var didChangeXNotification = NSNotification.Name(rawValue: "didChangeXNotification")
    static var didChangeYNotification = NSNotification.Name(rawValue: "didChangeYNotification")

    
    @IBOutlet weak var radiusField: UITextField!
    @IBOutlet weak var xField: UITextField!
    @IBOutlet weak var yField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        radiusField.text = "\(Int(Preset.regionRadius))"
        xField.text = "\(Int(Preset.regionX))"
        yField.text = "\(Int(Preset.regionY))"
        
//        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backButtonPressed(_:)))
//        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    @IBAction func radiusDidEnd(_ sender: Any) {
        if let text = radiusField.text {
            Preset.regionRadius = Double(text) ?? 100
            NotificationCenter.default.post(name: SettingsViewController.didChangeRadiusNotification, object: nil)
        }
    }
    
    @IBAction func xDidEnd(_ sender: Any) {
        if let text = xField.text,
           let value = Double(text) {
            
            if value >= Preset.regionRadius {
                Preset.regionX = value
                NotificationCenter.default.post(name: SettingsViewController.didChangeXNotification, object: nil)
            } else {
                xField.text = "\(Int(Preset.regionX))"
                alert(withTitle: "Warning!", message: "must greater than Radius: \(Preset.regionRadius)") {
                    
                }
            }

        } else {
            alert(withTitle: "Warning!", message: "Please input valid number") {
                
            }
        }
    }
    
    @IBAction func yDidEnd(_ sender: Any) {
        if let text = yField.text,
           let value = Double(text) {
            
            if value >= Preset.regionRadius {
                Preset.regionY = value
                
                NotificationCenter.default.post(name: SettingsViewController.didChangeYNotification, object: nil)
            }
            else {
                yField.text = "\(Int(Preset.regionY))"
                alert(withTitle: "Warning!", message: "must greater than Radius: \(Preset.regionRadius)") {
                    
                }
            }
        }else {
            alert(withTitle: "Warning!", message: "Please input valid number") {
                
            }
        }
    }
}
