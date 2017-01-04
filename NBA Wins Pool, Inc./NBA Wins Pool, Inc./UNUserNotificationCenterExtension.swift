//
//  UNUserNotificationCenterExtension.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 10/29/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UserNotifications

extension UNUserNotificationCenter {
  func addNotification(title: String, body: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default()
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: title, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request) { (error : Error?) in
      if let e = error {
        print(e)
      }
    }
  }
}
