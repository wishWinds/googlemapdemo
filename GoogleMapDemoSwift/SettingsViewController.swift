//
//  SettingsViewController.swift
//  GoogleMapDemoSwift
//
//  Created by shupeng on 2020/11/18.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backButtonPressed(_:)))
//        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
}
