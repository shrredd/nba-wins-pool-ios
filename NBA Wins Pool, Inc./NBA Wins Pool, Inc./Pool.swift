//
//  Pool.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/3/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class Pool: DictionaryBase, Equatable, CustomStringConvertible {
  static let name = "name"
  static let id = "id"
  static let maxSize = "max_size"
  static let members = "members"
  
  static let didUpdateDraft = "Pool.didUpdateDraft"
  
  var name: String!
  var id: Int!
  var maxSize: Int!
  var users = [User]()
  
  var draft: Draft? {
    didSet {
      if let oldCount = oldValue?.picks.count, let newCount = draft?.picks.count  {
        if newCount > oldCount {
          NotificationCenter.default.post(name: Notification.Name(rawValue: Pool.didUpdateDraft), object: self)
        }
      }
    }
  }
  
  var isFull: Bool {
    return maxSize == users.count
  }
  
  func teams(user: User) -> [Team] {
    var teams = [Team]()
    if let d = draft {
      for (index, u) in d.picks.enumerated() where index < d.selections.count {
        if user == u {
          teams.append(d.selections[index])
        }
      }
    }
    
    return teams
  }
  
  func record(user: User) -> Record {
    var record = Record(wins: 0, losses: 0)
    
    for team in teams(user: user) {
      if let teamRecord = team.record {
        record = record + teamRecord
      }
    }
    
    return record
  }
  
  override func didSetDictionary(oldValue: [String : AnyObject]) {
    super.didSetDictionary(oldValue: oldValue)
    
    self.maxSize = dictionary[Pool.maxSize] as? Int
    self.name = dictionary[Pool.name] as? String
    self.id = dictionary[Pool.id] as? Int
    users.removeAll()
    if let members = dictionary[Pool.members] as? [[String : AnyObject]] {
      for memberDictionary in members {
        users.append(User(dictionary: memberDictionary))
      }
    }
    
    if let draftStatus = dictionary[Draft.status] as? [[String : AnyObject]] {
      self.draft = Draft(dictionary: [Draft.status : draftStatus as AnyObject])
    }
  }
  
  func getPoolInfo() {
    Backend.getPoolInfo(id: id) { [unowned self] (poolDictionary, success) in
      if success, let dict = poolDictionary as? [String : AnyObject] {
        self.dictionary = dict
      } else {
        UIAlertController.alertOK(title: "GET Pool Info Failed", message: String(describing: poolDictionary))
      }
    }
  }
  
  func getDraftStatus() {
    Backend.getDraftStatus(id: id) { (draftArray, success) in
      if success, let array  = draftArray as? [[String : AnyObject]] {
        self.dictionary = ["draft_status" : array as AnyObject]
      } else {
        UIAlertController.alertOK(title: "GET Draft Status Failed", message: String(describing: draftArray))
      }
    }
  }
  
  func pick(team: String) {
    if let token = User.shared?.token {
      Backend.pickTeam(poolID: id, teamID: team, token: token, completion: { (draftArray, success) in
        if success, let array  = draftArray as? [[String : AnyObject]] {
          self.dictionary = ["draft_status" : array as AnyObject]
        } else {
          UIAlertController.alertOK(title: "Failed to Make Pick", message: String(describing: draftArray))
        }
      })
    }
  }
  
  // MARK: CustomStringConvertible
  
  var description: String {
    var printMe = ""
    
    
    if let n = name {
      printMe += n + " "
    }
    
    if let i = id {
      printMe += String(describing: i) + " "
    }
    
    if let size = maxSize {
      printMe += String(describing: size) + " "
    }
    
    printMe += String(describing: users)
    
    return printMe
  }
  
  // MARK: Equatable
  
  static func ==(poolA: Pool, poolB: Pool) -> Bool {
    return poolA.id == poolB.id
  }
}
