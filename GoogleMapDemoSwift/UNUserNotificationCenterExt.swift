//
//  UNUserNotificationCenterExt.swift
//  GoogleMapDemoSwift
//
//  Created by shupeng on 2020/11/12.
//

import Foundation
import UserNotifications

extension UNUserNotificationCenter {
    func pushNotitfication(with title: String, body: String) {
        let notiContent = UNMutableNotificationContent()
        notiContent.title = title
        notiContent.body = body
        notiContent.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notiContent, trigger: nil)
        
        add(request, withCompletionHandler: nil)
    }
}
