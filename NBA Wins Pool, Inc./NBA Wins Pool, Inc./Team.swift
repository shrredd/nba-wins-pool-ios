//
//  Team.swift
//  NBA Wins Pool
//
//  Created by John Benz Jessen on 9/3/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

enum TeamIdentifier: String {
  case hawks = "atlanta-hawks"
  case lakers = "los-angeles-lakers"
  case clippers = "los-angeles-clippers"
  case suns = "phoenix-suns"
  case bucks = "milwaukee-bucks"
  case jazz = "utah-jazz"
  case heat = "miami-heat"
  case cavaliers = "cleveland-cavaliers"
  case magic = "orlando-magic"
  case pacers = "indiana-pacers"
  case rockets = "houston-rockets"
  case spurs = "san-antonio-spurs"
  case warriors = "golden-state-warriors"
  case thunder = "oklahoma-city-thunder"
  case pistons = "detroit-pistons"
  case celtics = "boston-celtics"
  case hornets = "charlotte-hornets"
  case pelicans = "new-orleans-pelicans"
  case bulls = "chicago-bulls"
  case nets = "brooklyn-nets"
  case grizzlies = "memphis-grizzlies"
  case blazers = "portland-trail-blazers"
  case kings = "sacramento-kings"
  case sixers = "philadelphia-76ers"
  case timberwolves = "minnesota-timberwolves"
  case knicks = "new-york-knicks"
  case mavericks = "dallas-mavericks"
  case wizards = "washington-wizards"
  case raptors = "toronto-raptors"
  case nuggets = "denver-nuggets"
}

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

struct Record: CustomStringConvertible, Equatable {
  var wins = 0
  var losses = 0
  
  var percentage: Double {
    if wins + losses == 0 {
      return 0
    }
    return Double(wins) / Double(wins + losses)
  }
  
  var asString: String {
    return "\(wins)-\(losses)"
  }
  
  public static func +(lhs: Record, rhs: Record) -> Record {
    return Record(wins: lhs.wins + rhs.wins, losses: lhs.losses + rhs.losses)
  }
  
  // MARK: Equatable
  
  static func ==(lhs: Record, rhs: Record) -> Bool {
    return lhs.wins == rhs.wins && lhs.losses == rhs.losses
  }
  
  // MARK: CustomStringConvertible
  
  var description: String {
    return "\(wins)-\(losses) (\(percentage))"
  }
  
}

class Team: DictionaryBase, CustomStringConvertible, Equatable, Hashable {
  var id: String!
  var abbreviation: String!
  var firstName: String!
  var lastName: String!
  
  var fullName: String! {
    return firstName + " " + lastName
  }
  
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
  
  var primaryColor: UIColor {
    if let team = TeamIdentifier(rawValue: id) {
      switch team {
      case .hawks:
        return UIColor(red: 224, green: 58, blue: 62)
      case .celtics:
        return UIColor(red: 0, green: 131, blue: 72)
      case .nets:
        return UIColor(red: 0, green: 0, blue: 0)
      case .hornets:
        return UIColor(red: 29, green: 17, blue: 96)
      case .bulls:
        return UIColor(red: 206, green: 17, blue: 65)
      case .cavaliers:
        return UIColor(red: 134, green: 0, blue: 56)
      case .mavericks:
        return UIColor(red: 0, green: 125, blue: 197)
      case .nuggets:
        return UIColor(red: 79, green: 168, blue: 255)
      case .pistons:
        return UIColor(red: 0, green: 31, blue: 112)
      case .warriors:
        return UIColor(red: 0, green: 107, blue: 182)
      case .rockets:
        return UIColor(red: 206, green: 17, blue: 65)
      case .pacers:
        return UIColor(red: 0, green: 39, blue: 93)
      case .clippers:
        return UIColor(red: 237, green: 23, blue: 76)
      case .lakers:
        return UIColor(red: 85, green: 37, blue: 130)
      case .grizzlies:
        return UIColor(red: 35, green: 55, blue: 91)
      case .heat:
        return UIColor(red: 152, green: 0, blue: 46)
      case .bucks:
        return UIColor(red: 0, green: 71, blue: 27)
      case .timberwolves:
        return UIColor(red: 0, green: 80, blue: 131)
      case .pelicans:
        return UIColor(red: 0, green: 43, blue: 92)
      case .knicks:
        return UIColor(red: 0, green: 107, blue: 182)
      case .thunder:
        return UIColor(red: 0, green: 125, blue: 195)
      case .magic:
        return UIColor(red: 0, green: 125, blue: 197)
      case .sixers:
        return UIColor(red: 0, green: 102, blue: 182)
      case .suns:
        return UIColor(red: 229, green: 96, blue: 32)
      case .blazers:
        return UIColor(red: 240, green: 22, blue: 58)
      case .kings:
        return UIColor(red: 114, green: 76, blue: 159)
      case .spurs:
        return UIColor(red: 182, green: 191, blue: 191)
      case .raptors:
        return UIColor(red: 206, green: 17, blue: 65)
      case .jazz:
        return UIColor(red: 0, green: 43, blue: 92)
      case .wizards:
        return UIColor(red: 0, green: 37, blue: 102)
      }
    }
    
    return UIColor.clear
  }
  
  var emoji: String {
    if let team = TeamIdentifier(rawValue: id) {
      switch team {
      case .hawks:
        return "🐣"
      case .celtics:
        return "☘"
      case .nets:
        return "🚽"
      case .hornets:
        return "🐝"
      case .bulls:
        return "🐄"
      case .cavaliers:
        return "🏆"
      case .mavericks:
        return "🐴"
      case .nuggets:
        return "💰"
      case .pistons:
        return "🚙"
      case .warriors:
        return "⚔"
      case .rockets:
        return "🚀"
      case .pacers:
        return "👩‍👩‍👧‍👧"
      case .clippers:
        return "⛵️"
      case .lakers:
        return "🌊"
      case .grizzlies:
        return "🐻"
      case .heat:
        return "🔥"
      case .bucks:
        return "🦄"
      case .timberwolves:
        return "🐺"
      case .pelicans:
        return "🎭"
      case .knicks:
        return "🗽"
      case .thunder:
        return "🌪"
      case .magic:
        return "🕴"
      case .sixers:
        return "💩"
      case .suns:
        return "🌞"
      case .blazers:
        return "⛏"
      case .kings:
        return "👑"
      case .spurs:
        return "🐎"
      case .raptors:
        return "🇨🇦"
      case .jazz:
        return "🎷"
      case .wizards:
        return "💫"
      }
    }
    
    return "?"
  }
  
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
        self.pointsAllowedPerGame = double
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
  
  // MARK: Equatable
  
  static func ==(teamA: Team, teamB: Team) -> Bool {
    return teamA.id == teamB.id
  }
  
  // MARK: Hashable
  
  var hashValue: Int {
    return id.hashValue
  }
  
  // MARK: CustomStringConvertible
  
  var description: String {
    return id + " \(record)"
  }
  
}
