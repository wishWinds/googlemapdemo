//
//  RootNavigationController.swift
//  GoogleMapDemoSwift
//
//  Created by shupeng on 2020/11/18.
//

import Foundation
import UIKit

class RootNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.tintColor = .white
        
        var image: UIImage!
        UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { (context) in
            UIColor.clear.set()
            UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1, height: 1)).fill()
            image = context.currentImage
        }
        navigationBar.barStyle = .default;
        navigationBar.isTranslucent = true;
        navigationBar.backIndicatorImage = image
        navigationBar.setBackgroundImage(image, for: .any, barMetrics: .default)
        navigationBar.shadowImage = UIImage()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
