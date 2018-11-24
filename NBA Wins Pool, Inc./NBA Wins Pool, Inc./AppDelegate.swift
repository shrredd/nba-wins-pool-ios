//
//  AppDelegate.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/3/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    UIApplication.shared.isStatusBarHidden = false
    UIApplication.shared.statusBarStyle = .default
    UIApplication.shared.setMinimumBackgroundFetchInterval(3600.0/2.0)

    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
      if !accepted {
        print("Notification access denied.")
      }
      
      if let e = error {
        print(e)
      }
    }
    
    Pools.shared.getPools()
    Teams.shared.getStandings()
    return true
  }
  
  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    Teams.shared.getStandings(result: completionHandler)
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if let scheme = url.scheme {
      if scheme == "WinsPool" || scheme == "winspool" {
        if let string = url.query?.removingPercentEncoding {
          let queries = string.components(separatedBy: "&")
          for query in queries {
            let parameters = query.components(separatedBy: "=")
            let parameter = parameters[0]
            let value = parameters[1]
            
            switch parameter {
            case "id":
              if let id = Int(value) {
                Pools.shared.idForInvitedPool = id
                Pools.shared.joinPool()
                return true
              } else {
                break;
              }
            default:
              break
            }
          }
        }
      }
    }
    
    return false
  }
}

