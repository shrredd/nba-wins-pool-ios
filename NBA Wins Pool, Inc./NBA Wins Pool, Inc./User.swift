//
//  User.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/23/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class User: Codable {
  static var shared = loadSavedUser()
  
  struct Token: Codable {
    let token: String
  }
  
  let username: String
  var email: String?
  var token: String?
  
  static func loadSavedUser() -> User? {
    guard let data = UserDefaults.standard.object(forKey: "logged_in_user") else { return nil }
    
    if let dictionary = data as? [String : Any] {
      do {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        return try JSONDecoder().decode(User.self, from: data)
      } catch {
        print(error)
      }
    }
    if let d = data as? Data {
      do {
        return try JSONDecoder().decode(User.self, from: d)
      } catch {
        print(error)
      }
    }
    return nil
  }
  
  static func save() {
    guard let user = shared else {
      UserDefaults.standard.removeObject(forKey: "logged_in_user")
      UserDefaults.standard.synchronize()
      return
    }
    
    do {
      let data = try JSONEncoder().encode(user)
      UserDefaults.standard.set(data, forKey: "logged_in_user")
      UserDefaults.standard.synchronize()
    } catch {
      print(error)
    }
  }
}

extension User: Equatable {
  static func ==(userA: User, userB: User) -> Bool {
    return userA.username == userB.username
  }
}

extension User: Hashable {
  var hashValue: Int {
    return username.hashValue
  }
}

extension User: CustomStringConvertible {
  var description: String {
    var printMe = ""
    printMe += username + " "
    
    if let mail = email {
      printMe += mail + " "
    }
    
    if let auth = token {
      printMe += auth
    }
    
    return printMe
  }
}
