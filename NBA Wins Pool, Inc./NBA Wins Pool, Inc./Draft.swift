//
//  Draft.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 10/1/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class Draft: DictionaryBase {
  
  static let status = "draft_status"
  static let pickNumber = "draft_pick_number"
  
  var picks = [User]()
  var selections = [Team]()
  var userWithPick: User? {
    if picks.count == 0 {
      return nil
    }
    
    return picks[selections.count]
  }
  
  var isComplete: Bool {
    return selections.count == picks.count
  }
  
  override func didSetDictionary(oldValue: [String : AnyObject]) {
    super.didSetDictionary(oldValue: oldValue)
    
    if let dictionaries = dictionary[Draft.status] as? [[String : AnyObject]] {
      let sortedDictionaries = dictionaries.sorted(by: { (dictionaryA, dictionaryB) -> Bool in
        if let numberA = dictionaryA[Draft.pickNumber] as? Int, let numberB = dictionaryB[Draft.pickNumber] as? Int {
          return numberA > numberB
        }
        
        return true
      })
      
      picks.removeAll()
      selections.removeAll()
      
      for pickDictionary in sortedDictionaries {
        if let userDictionary = pickDictionary["user"] as? [String : AnyObject] {
          let user = User(dictionary: userDictionary)
          picks.append(user)
          if let teamDictionary = pickDictionary["team"] as? [String : AnyObject] {
            let incompleteTeam = Team(dictionary: teamDictionary)
            if let index = Teams.shared.items.index(of: incompleteTeam) {
              let team = Teams.shared.items[index]
              selections.append(team)
            }
          }
        }
      }
    }
  }
  
}
