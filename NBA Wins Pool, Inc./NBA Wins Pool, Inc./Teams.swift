//
//  Teams.swift
//  NBA Wins Pool
//
//  Created by John Benz Jessen on 9/3/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class Teams: StoredDictionaries<Team> {
  
  static let shared = Teams()
  static let standingsDate = "standings_date"
  
  var dateUpdated: String?
  
  init() {
    super.init(type: "teams")
    dateUpdated = UserDefaults.standard.object(forKey: Teams.standingsDate) as? String
    
    if items.count == 0 {
      Backend.getTeams { [unowned self] (teamDictionaries, success) in
        if success, let array = teamDictionaries as? [[String : AnyObject]] {
          self.load(array: array)
        }
      }
    }
    
    Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(getStandings), userInfo: nil, repeats: true)
  }
  
  @objc func getStandings() {
    Backend.getStandings { [unowned self] (standingsDictionary, success) in
      if success, let dictionary = standingsDictionary as? [String : AnyObject] {
        if let date = dictionary[Teams.standingsDate] as? String {
          if date != self.dateUpdated {
            if let standings = dictionary["standing"] as? [[String : AnyObject]] {
              self.load(array: standings)
            }
          }
        }
      }
    }
  }
}
