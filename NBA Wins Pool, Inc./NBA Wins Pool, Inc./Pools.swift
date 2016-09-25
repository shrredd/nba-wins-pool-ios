//
//  Pools.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/10/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class Pools {
  
  static let shared = Pools()
  static let pools = "pools"
  static let poolsUpdated = "Pools.poolsUpdated"
  
  init() {
    if let array = UserDefaults.standard.object(forKey: Pools.pools) as? [[String : AnyObject]] {
      for dictionary in array {
        if let pool = Pool(dictionary: dictionary) {
          pools.append(pool)
        }
      }
    }
  }
  
  var pools = [Pool]()
  
  func add(pool: Pool) {
    if !pools.contains(pool) {
      pools.append(pool)
      savePools()
      NotificationCenter.default.post(name: Notification.Name(rawValue: Pools.poolsUpdated), object: nil)
    }
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
  
  func savePoolUsers() {
    var dictionary = [String : [String]]()
    for pool in pools {
      var array = [String]()
      for user in pool.users {
        array.append(user.username)
      }
      dictionary[pool.id] = array
    }
    
    UserDefaults.standard.synchronize()
  }
}
