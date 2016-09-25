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
  static let size = "size"
  static let usersAndTeams = "usersAndTeams"
  
  let name: String
  let id: String
  let size: Int
  var users = [User]()
  var usersToTeams = [User : [Team]]()
  
  init(name: String, id: String, size: Int) {
    self.name = name
    self.id = id
    self.size = size
  }
  
  init?(dictionary: [String : AnyObject]) {
    if let sizeString = dictionary[Pool.size] as? String,
      let name = dictionary[Pool.name] as? String,
      let id = dictionary[Pool.id] as? String,
      let usernamesToTeamIDs = dictionary[Pool.usersAndTeams] as? [String : [String]] {
      self.size = Int(sizeString)!
      self.name = name
      self.id = id
      for (username, teamIDs) in usernamesToTeamIDs {
        if let user = Users.shared.get(username: username) {
          self.users.append(user)
          var teams = [Team]()
          for id in teamIDs {
            if let team = Teams.shared.team(id: id) {
              teams.append(team)
            }
          }
          usersToTeams[user] = teams
        }
      }
    } else {
      return nil
    }
  }
  
  var dictionary: [String : AnyObject] {
    var usernamesToTeamIDs = [String : [String]]()
    
    for user in users {
      if let username = user.username, let teams = usersToTeams[user] {
        var teamIDs = [String]()
        for team in teams {
          teamIDs.append(team.id)
        }
        usernamesToTeamIDs[username] = teamIDs
      }
    }
    
    return [Pool.name : name as AnyObject,
            Pool.id : id as AnyObject,
            Pool.size : String(size) as AnyObject,
            Pool.usersAndTeams : usernamesToTeamIDs as AnyObject]
  }
  
  static func ==(poolA: Pool, poolB: Pool) -> Bool {
    return poolA.name == poolB.name && poolA.id == poolB.id && poolA.size == poolB.size
  }
  
  
  func teams(user: User) -> [Team]? {
    return usersToTeams[user]
  }
  
  func add(user: User) {
    users.append(user)
    Pools.shared.savePoolUsers()
  }
}
