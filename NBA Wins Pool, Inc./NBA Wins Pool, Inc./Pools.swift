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
  static let users = "users"
  static let pools = "pools"
  static let poolPlayers = "pool_users"
  static let poolsUpdated = "Pools.poolsUpdated"
  
  var loggedInUser: User? {
    if users.count > 0 {
      return users[0]
    }
    
    return nil
  }
  
  init() {
    if let array = UserDefaults.standard.object(forKey: Pools.pools) as? [[String : String]] {
      for dictionary in array {
        if let pool = Pool(dictionary: dictionary) {
          pools.append(pool)
        }
      }
    }
    
    if let array = UserDefaults.standard.object(forKey: Pools.users) as? [[String : String]] {
      for dictionary in array {
        if let user = User(dictionary: dictionary) {
          users.append(user)
        }
      }
    }
    
    if let dictionary = UserDefaults.standard.object(forKey: Pools.poolPlayers) as? [String : [String]] {
      for (poolID, array) in dictionary {
        if let pool = pool(id: poolID) {
          for username in array {
            if let user = user(username: username) {
              pool.users.append(user)
            }
          }
        }
      }
    }
  }
  
  var pools = [Pool]()
  var users = [User]()
  
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
  
  func savePools() {
    var dictionaries = [[String : String]]()
    for pool in pools {
      dictionaries.append(pool.dictionary)
    }
    
    UserDefaults.standard.set(dictionaries, forKey: Pools.pools)
    UserDefaults.standard.synchronize()
  }
  
  func add(user: User) {
    if !users.contains(user) {
      users.append(user)
      
      var dictionaries = [[String : String]]()
      for user in users {
        if let dictionary = user.dictionary {
          dictionaries.append(dictionary)
        }
      }
      
      UserDefaults.standard.set(dictionaries, forKey: Pools.users)
      UserDefaults.standard.synchronize()
    }
  }
  
  func pool(id: String) -> Pool? {
    for pool in pools {
      if pool.id == id {
        return pool
      }
    }
    
    return nil
  }
  
  func user(username: String) -> User? {
    for user in users {
      if let name = user.username {
        if username == name {
          return user
        }
      }
    }
    
    return nil
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
    
    UserDefaults.standard.set(dictionary, forKey: Pools.poolPlayers)
    UserDefaults.standard.synchronize()
  }
}
