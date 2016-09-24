//
//  User.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/23/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class User: Equatable {
  static let username = "username"
  static let email = "email"
  static let token = "token"
  
  var username: String!
  var email: String?
  var token: String?
  
  init(username: String, email: String? = nil, token: String? = nil) {
    self.username = username
    self.token = token
  }
  
  init?(dictionary: [String: String]) {
    for (key, value) in dictionary {
      switch key {
      case "token":
        self.token = value
        break
      case "username":
        self.username = value
        break
      case "email":
        self.email = value
        break
      default:
        break
      }
    }
    
    if username == nil {
      return nil
    }
  }
  
  var dictionary: [String : String]? {
    if username == nil {
      return nil
    }
    
    var dictionary = [User.username : username!]
    
    if email != nil {
      dictionary[User.email] = email!
    }
    
    if token != nil {
      dictionary[User.token] = token!
    }
    
    return dictionary
  }
  
  static func ==(userA: User, userB: User) -> Bool {
    return userA.username == userB.username
  }
}
