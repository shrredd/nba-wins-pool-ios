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
  
  func updateTeamWithId(_ id: Team.Id, record: Record) {
    guard let team = idToTeam[id.rawValue], team.record != record  else { return }
    team.record = record
    save()
    delegate?.teams(self, didUpdateTeam: team)
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
      guard success, let s = standings else {
        completion?(false)
        return
      }
      
      guard let member = Member.currentMember else {
        completion?(true)
        return
      }
      
      FirebaseInterface.getPools(member: member) { (result, error) in
        let pools = result ?? []
        let completePools = pools.filter { $0.isComplete }
        completePools.forEach { UNUserNotificationCenter.addDraftPickNotification(pool: $0) }
        
        // save rankings
        var poolRankings = [String : Int]()
        for pool in completePools {
          let sortedMembers = pool.membersSortedByWinPercentage
          poolRankings[pool.id] = sortedMembers.firstIndex(of: member)
        }
        
        // update standings
        var standings = s.league.standard.conference.east
        standings.append(contentsOf: s.league.standard.conference.west)
        standings
          .filter { $0.toTeamId() != nil }
          .forEach {
            let id = $0.toTeamId()!
            let record = Record(wins: $0.wins, losses: $0.losses)
            
            // add notification for change in team record
            if let team = self?.idToTeam[id.rawValue], let oldRecord = team.record, oldRecord != record {
              for pool in completePools {
                if pool.teamsForMember(member).contains(team) {
                  let isWinning = (record.wins - oldRecord.wins) > (record.losses - oldRecord.losses)
                  UNUserNotificationCenter.addNotificationForTeam(team, record:record, winning: isWinning)
                  break
                }
              }
            }
            self?.updateTeamWithId(id, record: record)
          }

        // check for changes in rankings
        for pool in completePools {
          let members = pool.membersSortedByWinPercentage
          if let newRank = members.firstIndex(of: member), let oldRank = poolRankings[pool.id], newRank != oldRank {
            UNUserNotificationCenter.addNotificationForPool(pool, rank: newRank + 1, rising: newRank < oldRank)
          }
        }
        
        completion?(true)
      }
    }
  }
}

protocol TeamsDelegate: class {
  func teams(_ teams: Teams, didUpdateTeam team: Team)
}
