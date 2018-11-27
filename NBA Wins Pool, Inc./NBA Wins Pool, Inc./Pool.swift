//
//  Pool.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/3/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class Pool: Codable {
  struct Pick: Codable {
    struct TeamId: Codable {
      let team_id: String
    }
    let draft_pick_number: Int
    let user: User
    var team: TeamId?
  }
  
  let name: String
  let id: Int
  let max_size: Int
  var members: [User]? {
    didSet {
      if oldValue != members {
        if let old = oldValue, let new = members, let newMember = Set(new).subtracting(old).first {
          let message = old.count == new.count ? "The draft has begun..." : "Tell your other friends to hurry up!"
          UIAlertController.alertOK(title: "\(newMember) joined \(name)!", message: message)
        }
      }
    }
  }
  
  var draft_status: [Pick]? {
    didSet {
      if oldValue != draft_status {
        if let old = oldValue, let new = draft_status, old.filter({ $0.team != nil }).count != new.filter({$0.team != nil}).count {
          var message = "The draft is over. Good luck!"
          var pickedTeamName: String?
          var userWhoPicked: String?
          for pick in picksSortedByDraftNumber {
            if pick.team == nil {
              message = "It's \(pick.user == User.shared ? "your" : "\(pick.user.username)'s") pick!"
              break
            }
            pickedTeamName = pick.getTeam()?.name
            userWhoPicked = pick.user == User.shared ? "You" : pick.user.username
          }
          UIAlertController.alertOK(title: "\(userWhoPicked ?? "?") picked the \(pickedTeamName ?? "?")!", message: message)
        }
      }
    }
  }
}

extension Pool {
  var picksSortedByDraftNumber: [Pick] {
    return draft_status?.sorted { $0.draft_pick_number < $1.draft_pick_number } ?? []
  }
  
  var userWithPick: User? {
    for pick in picksSortedByDraftNumber {
      if pick.team == nil {
        return pick.user
      }
    }
    
    return nil
  }
  
  var isComplete: Bool {
    return picksSortedByDraftNumber.last?.team != nil
  }
  
  func picksForUser(_ user: User) -> [Pick]? {
    return draft_status?.filter { $0.user == user }
  }
  
  func teamsForUser(_ user: User) -> Set<Team> {
    return Set(draft_status?.filter { $0.team != nil && $0.user == user }.map { $0.getTeam()! } ?? [])
  }
  
  func recordForUser(_ user: User) -> Record {
    var record = Record(wins: 0, losses: 0)
    teamsForUser(user).forEach { record = record + ($0.record ?? Record(wins: 0, losses: 0)) }
    return record
  }
}

extension Pool.Pick {
  func getTeam() -> Team? {
    guard let id = team?.team_id else {
      return nil
    }
    return Teams.shared.idToTeam[id]
  }
}

extension Pool {
  var isFull: Bool {
    return max_size == members?.count
  }
  
  var membersSortedByWinPercentage: [User] {
    return members?.sorted { self.recordForUser($0).percentage > self.recordForUser($1).percentage } ?? []
  }
}

extension Pool: Equatable {
  static func ==(poolA: Pool, poolB: Pool) -> Bool {
    return poolA.id == poolB.id
  }
}

extension Pool: Hashable {
  var hashValue: Int {
    return id.hashValue
  }
}

extension Pool.Pick: Equatable {
  static func == (lhs: Pool.Pick, rhs: Pool.Pick) -> Bool {
    return lhs.user == rhs.user && lhs.team == rhs.team && lhs.draft_pick_number == rhs.draft_pick_number
  }
}

extension Pool.Pick.TeamId: Equatable {
  static func == (lhs: Pool.Pick.TeamId, rhs: Pool.Pick.TeamId) -> Bool {
    return lhs.team_id == rhs.team_id
  }
}
