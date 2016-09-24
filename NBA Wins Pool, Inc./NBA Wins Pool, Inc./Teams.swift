//
//  Teams.swift
//  NBA Wins Pool
//
//  Created by John Benz Jessen on 9/3/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class Teams {
  
  static let shared = Teams()
  static let standings = "standings"
  static let teams = "teams"
  static let didGetStandings = "Teams.didGetStandings"
  static let didGetTeams = "Teams.didGetTeams"
  
  var teams = [Team]()
  
  init() {
    if let array = UserDefaults.standard.object(forKey: Teams.teams) as? [[String:AnyObject]] {
      setTeams(array: array)
    } else {
      Backend.getTeams { [unowned self] (dictionaries, statusCode, error) in
        if dictionaries != nil {
          UserDefaults.standard.set(dictionaries, forKey: Teams.teams)
          UserDefaults.standard.synchronize()
          self.setTeams(array: dictionaries!)
          NotificationCenter.default.post(name: NSNotification.Name(rawValue: Teams.didGetTeams), object: nil)
        }
      }
    }
    
    if let dictionary = UserDefaults.standard.object(forKey: Teams.standings) as? [String:AnyObject] {
      setStandings(dictionary: dictionary)
    }
    
    Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(getStandings), userInfo: nil, repeats: true)
    getStandings()
  }
  
  @objc func getStandings() {
    Backend.getStandings { [unowned self] (dictionary, statusCode, error) in
      if dictionary != nil {
        if let defaults = UserDefaults.standard.object(forKey: Teams.standings) as? [String:AnyObject] {
          if let dateA = defaults["standings_date"] as? String, let dateB = dictionary?["standings_date"] as? String {
            if dateA == dateB {
              return
            }
          }
        }
        
        UserDefaults.standard.set(dictionary!, forKey: Teams.standings)
        UserDefaults.standard.synchronize()
        self.setStandings(dictionary: dictionary!)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Teams.didGetStandings), object: nil)
      }
    }
  }
  
  func team(id: String) -> Team? {
    for team in teams {
      if team.id == id {
        return team
      }
    }
    
    return nil
  }
  
  func setTeams(array: [[String:AnyObject]]) {
    for dictionary in array {
      
      var stringDictionary = [String : String]()
      for (key, value) in dictionary {
        if let stringValue = value as? String {
          stringDictionary[key] = stringValue
        }
      }
      
      let team = Team(dictionary: stringDictionary)
      teams.append(team)
    }
  }
  
  func setStandings(dictionary: [String : AnyObject]) {
    if teams.count == 0 {
      return
    }
    
    if let standings = dictionary["standing"] as? [[String:AnyObject]] {
      for dictionary in standings {
        if let id = dictionary["team_id"] as? String {
          if let team = team(id: id) {
            team.set(dictionary: dictionary)
          }
        }
      }
    }
  }
}
