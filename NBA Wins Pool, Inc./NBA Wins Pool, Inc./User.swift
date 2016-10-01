//
//  User.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/23/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class User: DictionaryBase, Hashable {
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
  
  override func didSetDictionary(oldValue: [String : AnyObject]) {
    super.didSetDictionary(oldValue: oldValue)
    
    self.username = dictionary[User.username] as? String
    self.email = dictionary[User.email] as? String
    self.token = dictionary[User.token] as? String
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
