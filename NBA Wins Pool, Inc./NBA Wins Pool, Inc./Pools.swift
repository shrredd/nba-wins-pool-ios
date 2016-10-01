//
//  Pools.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/10/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class Pools {
  
  static let shared = Pools()
  static let pools = "pools"
  static let poolsUpdated = "Pools.poolsUpdated"
  
  static var idForInvitedPool: Int?
  
  init() {
    if let array = UserDefaults.standard.object(forKey: Pools.pools) as? [[String : AnyObject]] {
      loadPools(array: array)
    }
  }
  
  var pools = [Pool]()
  
  func loadPools(array: [[String : AnyObject]]) {
    for dictionary in array {
      let pool = Pool(dictionary: dictionary)
      if let index = pools.index(of: pool) {
        let oldPool = pools[index]
        oldPool.dictionary = pool.dictionary
      } else {
        pools.append(pool)
      }
    }
    
    savePools()
    NotificationCenter.default.post(name: Notification.Name(rawValue: Pools.poolsUpdated), object: nil)
  }
  
  func add(pool: Pool) {
    if let index = pools.index(of: pool) {
      let oldPool = pools[index]
      oldPool.dictionary = pool.dictionary
    } else {
      pools.append(pool)
    }
    
    savePools()
    NotificationCenter.default.post(name: Notification.Name(rawValue: Pools.poolsUpdated), object: nil)
  }
  
  func remove(pool: Pool) {
    if let index = pools.index(of: pool) {
      pools.remove(at: index)
    }
    savePools()
  }
  
  func removeAllPools() {
    pools = [Pool]()
    savePools()
  }
  
  func savePools() {
    var dictionaries = [[String : AnyObject]]()
    for pool in pools {
      dictionaries.append(pool.dictionary)
    }
    
    UserDefaults.standard.set(dictionaries, forKey: Pools.pools)
    UserDefaults.standard.synchronize()
  }
  
  static func getPools() {
    if let user = User.shared {
      if let token = user.token {
        Backend.getPools(username: user.username, token: token, completion: { (poolsArray, success) in
          if success, let array = poolsArray as? [[String : AnyObject]] {
            Pools.shared.loadPools(array: array)
          } else if let vc = visibleViewController() {
            UIAlertController.alertFailed(title: "GET Pools Failed", message: String(describing: poolsArray), viewController: vc)
          }
        })
      }
    }
  }
  
  static func joinPool() {
    if let user = User.shared {
      if let token = user.token {
        if let id = idForInvitedPool {
          Backend.joinPool(id: id, username: user.username, token: token, completion: { (poolDictionary, success) in
            if success, let dictionary = poolDictionary as? [String : AnyObject] {
              Pools.shared.add(pool: Pool(dictionary: dictionary))
              idForInvitedPool = nil
            } else if let vc = visibleViewController() {
              UIAlertController.alertFailed(title: "Failed to Join Pool", message: String(describing: poolDictionary), viewController: vc)
            }
          })
        }
      }
    }
  }
  
  static func visibleViewController() -> UIViewController? {
    return (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)?.topViewController
  }
}
