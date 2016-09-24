//
//  Pool.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/3/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class Pool: Equatable {
  static let name = "name"
  static let id = "id"
  static let size = "size"
  
  let name: String
  let id: String
  let size: Int
  
  init(name: String, id: String, size: Int) {
    self.name = name
    self.id = id
    self.size = size
  }
  
  init?(dictionary: [String : String]) {
    if let size = dictionary[Pool.size] {
      if let name = dictionary[Pool.name], let id = dictionary[Pool.id], let sizeInt = Int(size) {
        self.name = name
        self.id = id
        self.size = sizeInt
      } else {
        return nil
      }
    } else {
      return nil
    }
  }
  
  var dictionary: [String : String] {
    return [Pool.name : name, Pool.id : id, Pool.size : String(size)]
  }
  
  static func ==(poolA: Pool, poolB: Pool) -> Bool {
    return poolA.name == poolB.name && poolA.id == poolB.id && poolA.size == poolB.size
  }
  
  var users = [User]()
  var userToTeams = [String : [String]]()
  
  func teams(user: User) -> [Team]? {
    if let array = userToTeams[user.username] {
      var teams = [Team]()
      for id in array {
        if let team = Teams.shared.team(id: id) {
          teams.append(team)
        }
      }
      return teams
    }
    
    return nil
  }
  
  func add(user: User) {
    users.append(user)
    Pools.shared.savePoolUsers()
  }
}
