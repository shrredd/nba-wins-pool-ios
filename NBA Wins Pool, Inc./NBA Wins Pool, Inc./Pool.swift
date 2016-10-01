//
//  Pool.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/3/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class Pool: DictionaryBase, Equatable {
  static let name = "name"
  static let id = "id"
  static let maxSize = "max_size"
  static let members = "members"
  
  var name: String!
  var id: Int!
  var maxSize: Int!
  var users = [User]()
  
  override func didSetDictionary(oldValue: [String : AnyObject]) {
    super.didSetDictionary(oldValue: oldValue)
    
    self.maxSize = dictionary[Pool.maxSize] as? Int
    self.name = dictionary[Pool.name] as? String
    self.id = dictionary[Pool.id] as? Int
    if let members = dictionary[Pool.members] as? [[String : AnyObject]] {
      for memberDictionary in members {
        users.append(User(dictionary: memberDictionary))
      }
    } else {
      users.removeAll()
    }
  }
  
  static func ==(poolA: Pool, poolB: Pool) -> Bool {
    return poolA.name == poolB.name && poolA.id == poolB.id && poolA.maxSize == poolB.maxSize
  }
}
