//
//  AppDelegate.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/3/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool { 
    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    if let scheme = url.scheme {
      if scheme == "NBAWinsPool" || scheme == "nbawinspool" {
        var name: String?
        var id: String?
        var size: Int?
        
        if let string = url.query?.removingPercentEncoding {
          let queries = string.components(separatedBy: "&")
          for query in queries {
            let parameters = query.components(separatedBy: "=")
            let parameter = parameters[0]
            let value = parameters[1]
            
            switch parameter {
            case Pool.name:
              name = value
              break
            case Pool.id:
              id = value
              break
            case Pool.size:
              if let sizeInt = Int(value) {
                size = sizeInt
              }
              break
            default:
              break
            }
          }
        }
        
        if name != nil && id != nil && size != nil {
          let pool = Pool(name: name!, id: id!, size: size!)
          Pools.shared.add(pool: pool)
        }
      }
    }
    
    return false
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
}

