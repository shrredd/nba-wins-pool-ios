//
//  Users.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/24/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class Users {
  static let shared = Users()
  static let loggedInUser = "logged_in_user"
  static let users = "users"
  
  var loggedInUser: User?
  var users = [User]()
  
  init() {
    let defaults = UserDefaults.standard
    if let array = defaults.object(forKey: Users.users) as? [[String : String]] {
      for dictionary in array {
        if let user = User(dictionary: dictionary) {
          users.append(user)
        }
      }
    }
    
    if let username = defaults.object(forKey: Users.loggedInUser) as? String {
      if let user = get(username: username) {
        loggedInUser = user
      }
    }
  }
  
  func add(user: User) {
    if !users.contains(user) {
      users.append(user)
    }
    
    save()
  }
  
  func remove(user: User) {
    if let index = users.index(of: user) {
      users.remove(at: index)
    }
    
    save()
  }
  
  func get(username: String) -> User? {
    for user in users {
      if user.username == username {
        return user
      }
    }
    
    return nil
  }
  
  func save() {
    var array = [[String : String]]()
    for user in users {
      if let dictionary = user.dictionary {
        array.append(dictionary)
      }
    }
    
    let defaults = UserDefaults.standard
    
    defaults.set(array, forKey: Users.users)
    if let username = loggedInUser?.username {
      defaults.set(username, forKey: Users.loggedInUser)
    } else {
      defaults.removeObject(forKey: Users.loggedInUser)
    }
    
    defaults.synchronize()
  }
  
}
