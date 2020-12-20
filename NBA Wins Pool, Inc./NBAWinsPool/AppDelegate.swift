//
//  AppDelegate.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/3/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit
import UserNotifications
import BackgroundTasks
import Firebase
import FirebaseUI

fileprivate let backgroundTaskIdentifier = "com.johnbj.winspool.standings.refresh"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var standingsTimer: Timer?
  var authUI: FUIAuth? {
    return FUIAuth.defaultAuthUI()
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    authUI?.delegate = self
    authUI?.providers = [
      FUIEmailAuth(),
      FUIGoogleAuth()
    ]

    UIApplication.shared.isStatusBarHidden = false
    UIApplication.shared.statusBarStyle = .default
    
    BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
      self.handleAppRefresh(task: task as! BGAppRefreshTask)
    }
    
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
      if !accepted {
        print("Notification access denied.")
      }
      
      if let e = error {
        print(e)
      }
    }
    UNUserNotificationCenter.current().delegate = self
    
    Teams.shared.getStandings()
    return true
  }
  
  func handleAppRefresh(task: BGAppRefreshTask) {
    scheduleAppRefresh()
    Teams.shared.getStandings { (success) in
      task.setTaskCompleted(success: success)
    }
  }
  
  func scheduleAppRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
    request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 2)
  
    
    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
      print("Couldn't schedule app refresh: \(error)")
    }
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    
    let sourceApplication = options[.sourceApplication] as! String?
    if authUI?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
      return true
    }
    
    if url.scheme == "WinsPool" || url.scheme == "winspool" {
      if let string = url.query?.removingPercentEncoding {
        let queries = string.components(separatedBy: "&")
        for query in queries {
          let parameters = query.components(separatedBy: "=")
          let parameter = parameters[0]
          let value = parameters[1]
          
          switch parameter {
          case "id":
            guard let member = Member.currentMember else {
              UIAlertController.alertOK(title: "Join Pool Failed", message: "Looks like you aren't logged in.")
              return true
            }
            FirebaseInterface.joinPool(id: value, member: member) { (error) in
              guard let e = error else { return }
              UIAlertController.alertOK(title: "Join Pool Failed", message: e.localizedDescription)
            }
            return true
          default:
            break
          }
        }
      }
    }
    
    return false
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    standingsTimer?.invalidate()
    standingsTimer = Timer.scheduledTimer(withTimeInterval: 120.0, repeats: true, block: { (timer) in
      Teams.shared.getStandings()
    })
    Teams.shared.getStandings()
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    standingsTimer?.invalidate()
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    scheduleAppRefresh()
  }
}

extension AppDelegate: FUIAuthDelegate {
  func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
    let viewController = AuthPickerViewController(nibName: "AuthPickerViewController", bundle: nil, authUI: authUI)
    return viewController
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .badge, .sound])
  }
}
