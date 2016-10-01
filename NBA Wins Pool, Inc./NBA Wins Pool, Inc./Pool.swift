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
  static let maxSize = "max_size"
  static let members = "members"
  
  let name: String
  let id: Int
  let maxSize: Int
  var users = [User]()
  
  init(name: String, id: Int, maxSize: Int) {
    self.name = name
    self.id = id
    self.maxSize = maxSize
  }
  
  init?(dictionary: [String : AnyObject]) {
    if let maxSize = dictionary[Pool.maxSize] as? Int,
      let name = dictionary[Pool.name] as? String,
      let id = dictionary[Pool.id] as? Int,
      let members = dictionary[Pool.members] as? [[String : AnyObject]] {
      self.maxSize = maxSize
      self.name = name
      self.id = id
      for memberDictionary in members {
        if let user = User(dictionary: memberDictionary) {
          users.append(user)
        }
      }
    } else {
      return nil
    }
  }
  
  var dictionary: [String : AnyObject] {
    
    var members = [[String : AnyObject]]()
    for user in users {
      if let dictionary = user.dictionary {
        members.append(dictionary)
      }
    }
    
    return [Pool.name : name as AnyObject,
            Pool.id : id as AnyObject,
            Pool.maxSize : maxSize as AnyObject,
            Pool.members : members as AnyObject]
  }
  
  static func ==(poolA: Pool, poolB: Pool) -> Bool {
    return poolA.name == poolB.name && poolA.id == poolB.id && poolA.maxSize == poolB.maxSize
  }
  
  func add(user: User) {
    users.append(user)
  }
}
