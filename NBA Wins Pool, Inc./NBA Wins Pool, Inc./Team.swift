//
//  Team.swift
//  NBA Wins Pool
//
//  Created by John Benz Jessen on 9/3/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

enum Conference: String {
  case East
  case West
}

enum Division: String {
  case Central
  case Pacific
  case Southwest
  case Northwest
  case Atlantic
  case Southeast
}

enum Streak: String {
  case Winning = "win"
  case Losing = "loss"
}

struct Record {
  var wins = 0
  var losses = 0
  func percentage() -> Double {
    if wins + losses == 0 {
      return 0
    }
    return Double(wins) / Double(wins + losses)
  }
}

class Team: DictionaryBase {
  var id: String!
  var abbreviation: String!
  var firstName: String!
  var lastName: String!
  var conference: Conference!
  var division: Division!
  var siteName: String!
  var city: String!
  var state: String!
  
  var record: Record?
  var conferenceRecord: Record?
  var homeRecord: Record?
  var awayRecord: Record?
  var lastTenRecord: Record?
  var gamesBack: Double?
  var rank: Int?
  var playoffSeed: Int?
  var streak: Int?
  var streakType: Streak?
  var pointsScoredPerGame: Double?
  var pointsAllowedPerGame: Double?
  var pointDifferentialPerGame: Double?
  
  override func didSetDictionary(oldValue: [String : AnyObject]) {
    super.didSetDictionary(oldValue: oldValue)
    
    self.abbreviation = dictionary["abbreviation"] as? String
    self.id = dictionary["team_id"] as? String
    self.firstName = dictionary["first_name"] as? String
    self.lastName = dictionary["last_name"] as? String
    if let conference = dictionary["conference"] as? String {
      self.conference = Conference(rawValue: conference)
    }
    if let division = dictionary["division"] as? String {
      self.division = Division(rawValue: division)
    }
    self.siteName = dictionary["site_name"] as? String
    self.city = dictionary["city"] as? String
    self.state = dictionary["state"] as? String
    if let lastTen = dictionary["last_ten"] as? String {
      let array = lastTen.components(separatedBy: "-")
      if let wins = Int(array[0]), let losses = Int(array[1]) {
        self.lastTenRecord = Record(wins: wins, losses: losses)
      }
    }
    if let streakType = dictionary["streak_type"] as? String {
      self.streakType = Streak(rawValue: streakType)
    }
    if let ppg = dictionary["points_scored_per_game"] as? String {
      if let double = Double(ppg) {
        self.pointsScoredPerGame = double
      }
    }
    if let papg = dictionary["points_allowed_per_game"] as? String {
      if let double = Double(papg) {
        self.pointDifferentialPerGame = double
      }
    }
    if let pdpg = dictionary["point_differential_per_game"] as? String {
      if let double = Double(pdpg) {
        self.pointDifferentialPerGame = double
      }
    }
    self.gamesBack = dictionary["games_back"] as? Double
    self.rank = dictionary["rank"] as? Int
    self.playoffSeed = dictionary["playoff_seed"] as? Int
    self.streak = dictionary["streak_total"] as? Int
    if let wins = dictionary["won"] as? Int, let losses = dictionary["lost"] as? Int {
      self.record = Record(wins: wins, losses: losses)
    }
    if let wins = dictionary["home_won"] as? Int, let losses = dictionary["home_lost"] as? Int {
      self.homeRecord = Record(wins: wins, losses: losses)
    }
    if let wins = dictionary["conference_won"] as? Int, let losses = dictionary["conference_lost"] as? Int {
      self.conferenceRecord = Record(wins: wins, losses: losses)
    }
    if let wins = dictionary["away_won"] as? Int, let losses = dictionary["away_lost"] as? Int {
      self.awayRecord = Record(wins: wins, losses: losses)
    }
  }
  
  static func ==(teamA: Team, teamB: Team) -> Bool {
    return teamA.id == teamB.id
  }
  
}
