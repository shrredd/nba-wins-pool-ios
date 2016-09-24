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

class Team {
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
  
  init(dictionary: [String: String]) {
    for (key, value) in dictionary {
      switch key {
      case "abbreviation":
        self.abbreviation = value
        break
      case "team_id":
        self.id = value
        break
      case "first_name":
        self.firstName = value
        break
      case "last_name":
        self.lastName = value
        break
      case "conference":
        self.conference = Conference(rawValue: value)
        break
      case "division":
        self.division = Division(rawValue: value)
        break
      case "site_name":
        self.siteName = value
        break
      case "city":
        self.city = value
        break
      case "state":
        self.state = value
        break
      default:
        break
      }
    }
  }
  
  func set(dictionary: [String : AnyObject]) {
    
    var rec = Record()
    var conferenceRec = Record()
    var homeRec = Record()
    var awayRec = Record()
    
    for (key, value) in dictionary {
      if let stringValue = value as? String {
        switch key {
        case "last_ten":
          let array = stringValue.components(separatedBy: "-")
          if let wins = Int(array[0]), let losses = Int(array[1]) {
            lastTenRecord = Record(wins: wins, losses: losses)
          }
          break
        case "steak_type":
          streakType = Streak(rawValue: stringValue)
          break
        case "points_scored_per_game":
          if let double = Double(stringValue) {
            pointsScoredPerGame = double
          }
          break
        case "points_allowed_per_game":
          if let double = Double(stringValue) {
            pointsAllowedPerGame = double
          }
          break
        case "point_differential_per_game":
          if let double = Double(stringValue) {
            pointDifferentialPerGame = double
          }
          break
        default:
          break
        }
      }
      
      if let doubleValue = value as? Double {
        switch key {
        case "games_back":
          self.gamesBack = doubleValue
          break
        default:
          break
        }
      }
      
      if let intValue = value as? Int {
        switch key {
        case "rank":
          rank = intValue
          break
        case "playoff_seed":
          playoffSeed = intValue
          break
        case "streak_total":
          streak = intValue
          break
        case "won":
          rec.wins = intValue
          break
        case "lost":
          rec.losses = intValue
          break
        case "home_won":
          homeRec.wins = intValue
          break
        case "home_lost":
          homeRec.losses = intValue
          break
        case "conference_won":
          conferenceRec.wins = intValue
          break
        case "conference_lost":
          conferenceRec.losses = intValue
          break
        case "away_won":
          awayRec.wins = intValue
          break
        case "away_lost":
          awayRec.losses = intValue
          break
        default:
          break
        }
      }
    }
    
    record = rec
    homeRecord = homeRec
    conferenceRecord = conferenceRec
    awayRecord = awayRec
  }
}
