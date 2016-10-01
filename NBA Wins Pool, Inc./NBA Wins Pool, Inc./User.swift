//
//  User.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/23/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class User: Equatable, Hashable {
  static var shared = loadSavedUser()
  
  static let loggedInUser = "logged_in_user"
  static let username = "username"
  static let email = "email"
  static let token = "token"
  
  var username: String!
  var email: String?
  var token: String?
  
  static func loadSavedUser() -> User? {
    if let dictionary = UserDefaults.standard.object(forKey: loggedInUser) as? [String: AnyObject] {
      return User(dictionary: dictionary)
    } else {
      return nil
    }
  }
  
  static func saveUser() {
    if let dictionary = shared?.dictionary {
      UserDefaults.standard.set(dictionary, forKey: loggedInUser)
      UserDefaults.standard.synchronize()
    }
  }
  
  init?(dictionary: [String: AnyObject]) {
    for (key, value) in dictionary {
      if let stringValue = value as? String {
        switch key {
        case "token":
          self.token = stringValue
          break
        case "username":
          self.username = stringValue
          break
        case "email":
          self.email = stringValue
          break
        default:
          break
        }
      }
    }
    
    if username == nil {
      return nil
    }
  }
  
  var dictionary: [String : AnyObject]? {
    if let name = username {
      var dictionary: [String : AnyObject] = [User.username : name as AnyObject]
      if let mail = email {
        dictionary[User.email] = mail as AnyObject?
      }
      
      if let auth = token {
        dictionary[User.token] = auth as AnyObject?
      }
      
      return dictionary
    } else {
      return nil
    }
  }
  
  // MARK: Equatable
  
  static func ==(userA: User, userB: User) -> Bool {
    return userA.username == userB.username
  }
  
  // MARK: Hashable
  
  var hashValue: Int {
    return username.hashValue
  }
}
