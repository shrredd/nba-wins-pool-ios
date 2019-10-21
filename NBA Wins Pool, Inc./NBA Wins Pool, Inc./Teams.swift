//
//  Teams.swift
//  NBA Wins Pool
//
//  Created by John Benz Jessen on 9/3/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit
import UserNotifications

class Teams {
  static let shared = Teams()
  
  var idToTeam = [String : Team]()
  var teams: Set<Team> {
    return Set(idToTeam.values)
  }
  weak var delegate: TeamsDelegate?
  
  init() {
    Team.Id.allCases.forEach { self.idToTeam[$0.rawValue] = Team(id: $0) }
    load()
    Timer.scheduledTimer(timeInterval: 120.0, target: self, selector: #selector(getStandings), userInfo: nil, repeats: true)
    getStandings()
  }
  
  func load() {
    if let data = UserDefaults.standard.value(forKey: "teams") as? Data {
      do {
        let teams = try JSONDecoder().decode([Team].self, from: data)
        for team in teams {
          idToTeam[team.id.rawValue] = team
        }
      } catch {
        print(error)
      }
    }
  }
  
  func updateTeamWithId(_ id: Team.Id, record: Record) -> Bool {
    guard let team = idToTeam[id.rawValue], team.record != record  else { return false }
    team.record = record
    save()
    delegate?.teams(self, didUpdateTeam: team)
    return true
  }
  
  func save() {
    do {
      let data = try JSONEncoder().encode(Array(idToTeam.values))
      UserDefaults.standard.set(data, forKey: "teams")
      UserDefaults.standard.synchronize()
    } catch {
      print(error)
    }
  }
  
  @objc func getStandings(completion: ((Bool) -> Void)? = nil) {
    
    NBA.shared.getStandings { [weak self] (success, standings) in
      var didUpdate = false
      if success, let s = standings {
        // save rankings
        var poolRankings = [Int : Int]()
        if let user = User.shared {
          for pool in Pools.shared.pools {
            let sortedUsers = pool.membersSortedByWinPercentage
            poolRankings[pool.id] = sortedUsers.firstIndex(of: user)
          }
        }
        
        // update standings
        var standings = s.league.standard.conference.east
        standings.append(contentsOf: s.league.standard.conference.west)
        standings.forEach {
          if let id = $0.toTeamId() {
            let record = Record(wins: $0.wins, losses: $0.losses)
            didUpdate = (self?.updateTeamWithId(id, record: record) ?? false) || didUpdate
          }
        }
        
        // check for changes in rankings
        if let user = User.shared {
          for pool in Pools.shared.pools {
            let members = pool.membersSortedByWinPercentage
            if let newRank = members.firstIndex(of: user), let oldRank = poolRankings[pool.id], newRank != oldRank {
              UNUserNotificationCenter.addNotificationForPool(pool, rank: newRank + 1, rising: newRank < oldRank)
            }
          }
        }
      }
      completion?(success)
    }
  }
}

protocol TeamsDelegate: class {
  func teams(_ teams: Teams, didUpdateTeam team: Team)
}
