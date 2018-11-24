//
//  UNUserNotificationCenterExtension.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 10/29/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UserNotifications

extension UNUserNotificationCenter {
  static func addNotification(id: String, title: String, body: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default
    
    let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
    current().add(request) { (error) in
      print(error?.localizedDescription ?? "nil")
    }
  }
  
  static func addNotificationForTeam(_ team: Team, winning: Bool) {
    addNotification(id: team.id.rawValue,
                    title: "The \(team.name) \(winning ? "Won!" : "Lost :(")",
      body: "Their record is now \(team.record?.asString ?? "a mystery").")
  }
  
  static func addNotificationForPool(_ pool: Pool, rank: Int, rising: Bool) {
    addNotification(id: "\(pool.id)",
      title: "\(rising ? "You're moving up" : "Uh oh, you got passed") in \(pool.name)",
      body: "Your rank in \(pool.name) is now \(rank)")
  }
  
}
