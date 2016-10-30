//
//  Teams.swift
//  NBA Wins Pool
//
//  Created by John Benz Jessen on 9/3/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit
import UserNotifications

class Teams: StoredDictionaries<Team> {
  
  static let shared = Teams()
  static let standingsDate = "standings_date"
  
  var dateUpdated: String?
  
  init() {
    super.init(type: "teams")
    dateUpdated = UserDefaults.standard.object(forKey: Teams.standingsDate) as? String
    
    if items.count == 0 {
      Backend.shared.getTeams { [unowned self] (teamDictionaries, success) in
        if success, let array = teamDictionaries as? [[String : AnyObject]] {
          self.load(array: array)
        }
      }
    }
    
    Timer.scheduledTimer(timeInterval: 120.0, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
  }
  
  @objc func refresh() {
    getStandings()
  }
  
  func getStandings(result: ((UIBackgroundFetchResult) -> Void)? = nil) {
    
    var teamRecords = [String : Record]()
    for team in items {
      if let record = team.record {
        teamRecords[team.id] = record
      }
    }
    
    var poolRankings = [Int : Int]()
    
    if let user = User.shared {
      for pool in Pools.shared.items {
        let sortedUsers = pool.sortedUsers
        poolRankings[pool.id] = sortedUsers.index(of: user)
      }
    }
    
    Backend.shared.getStandings { [unowned self] (standingsDictionary, success) in
      var updated = false
      if success, let dictionary = standingsDictionary as? [String : AnyObject] {
        if let date = dictionary[Teams.standingsDate] as? String {
          if date != self.dateUpdated {
            if let standings = dictionary["standing"] as? [[String : AnyObject]] {
              self.load(array: standings)
              updated = true
            }
          }
        }
      }
      
      if let user = User.shared {
        var userTeams = Set<Team>()
        for pool in Pools.shared.items {
          for team in pool.teams(user: user) {
            userTeams.insert(team)
          }
        }
        
        for team in self.items {
          if let name = team.fullName {
            if userTeams.contains(team) {
              if let oldRecord = teamRecords[team.id], let newRecord = team.record {
                if newRecord != oldRecord {
                  let didWin = newRecord.wins > oldRecord.wins
                  let title = "The \(name) " + (didWin ? "Won! :D" : "Lost :(")
                  let body = "Their record is now \(newRecord.asString)."
                  UNUserNotificationCenter.current().addNotification(title: title, body: body)
                }
              }
            }
          }
        }
        
        for pool in Pools.shared.items {
          let sortedUsers = pool.sortedUsers
          if let newRank = sortedUsers.index(of: user), let oldRank = poolRankings[pool.id] {
            if newRank != oldRank {
              let didRise = newRank > oldRank
              let title = (didRise ? "You're moving up in " : "Uh oh, you got passed in ") + pool.name
              let body = "Your rank in the pool is now \(newRank + 1)"
              UNUserNotificationCenter.current().addNotification(title: title, body: body)
            }
          }
          
        }
      }
      
      var fetchResult: UIBackgroundFetchResult = .noData
      if !success {
        fetchResult = .failed
      } else if updated {
        fetchResult = .newData
      }
      
      if let r = result {
        r(fetchResult)
      }
    }
  }
}
