//
//  Team.swift
//  NBA Wins Pool
//
//  Created by John Benz Jessen on 9/3/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit
import UserNotifications

struct Record: Codable {
  let wins: Int
  let losses: Int
  
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
}

extension Record: Equatable {
  static func ==(lhs: Record, rhs: Record) -> Bool {
    return lhs.wins == rhs.wins && lhs.losses == rhs.losses
  }
}

extension Record: CustomStringConvertible {
  var description: String {
    return "\(wins)-\(losses) (\(percentage))"
  }
}

class Team: Codable {
  enum Id: String {
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
  
  var id: Id
  var record: Record?
  
  init(id: Id, record: Record? = nil) {
    self.id = id
    self.record = nil
  }
}

//if let old = oldValue, let new = record {
//  if let member = Member.currentMember {
//    for pool in Pools.shared.pools {
//      if pool.teamsForMember(member).contains(self) {
//        let winning = (new.wins - old.wins) > (new.losses - old.losses)
//        UNUserNotificationCenter.addNotificationForTeam(self, winning: winning)
//        break
//      }
//    }
//  }
//}

extension Team.Id: CaseIterable {}
extension Team.Id: Codable {}

extension Team {
  var primaryColor: UIColor {
    switch id {
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
  
  var name: String {
    switch id {
    case .hawks:
      return "Atlanta Hawks"
    case .celtics:
      return "Boston Celtics"
    case .nets:
      return "Brooklyn Nets"
    case .hornets:
      return "Charlotte Hornets"
    case .bulls:
      return "Chicago Bulls"
    case .cavaliers:
      return "Cleveland Cavaliers"
    case .mavericks:
      return "Dallas Mavericks"
    case .nuggets:
      return "Denver Nuggets"
    case .pistons:
      return "Detroit Pistons"
    case .warriors:
      return "Golden State Warriors"
    case .rockets:
      return "Houston Rockets"
    case .pacers:
      return "Indiana Pacers"
    case .clippers:
      return "Los Angeles Clippers"
    case .lakers:
      return "Los Angeles Lakers"
    case .grizzlies:
      return "Memphis Grizzlies"
    case .heat:
      return "Miami Heat"
    case .bucks:
      return "Milwaukee Bucks"
    case .timberwolves:
      return "Minnesota Timberwolves"
    case .pelicans:
      return "New Orleans Pelicans"
    case .knicks:
      return "New York Knicks"
    case .thunder:
      return "Oklahoma City Thunder"
    case .magic:
      return "Orlando Magic"
    case .sixers:
      return "Philadelphia 76ers"
    case .suns:
      return "Phoenix Suns"
    case .blazers:
      return "Portland Trail Blazers"
    case .kings:
      return "Sacramento Kings"
    case .spurs:
      return "San Antonio Spurs"
    case .raptors:
      return "Toronto Raptors"
    case .jazz:
      return "Utah Jazz"
    case .wizards:
      return "Washington Wizards"
    }
  }
  
  var emoji: String {
    switch id {
    case .hawks:
      return "🎰"
    case .celtics:
      return "🇺🇸"
    case .nets:
      return "⏳"
    case .hornets:
      return "🚽"
    case .bulls:
      return "🐄"
    case .cavaliers:
      return "⚰️"
    case .mavericks:
      return "👯‍♂️"
    case .nuggets:
      return "🃏"
    case .pistons:
      return "🚙"
    case .warriors:
      return "🚑"
    case .rockets:
      return "🚀"
    case .pacers:
      return "🚶‍♂️"
    case .clippers:
      return "💾"
    case .lakers:
      return "🇨🇳"
    case .grizzlies:
      return "💩"
    case .heat:
      return "🔥"
    case .bucks:
      return "🦌"
    case .timberwolves:
      return "🥔"
    case .pelicans:
      return "🙏🏿"
    case .knicks:
      return "🤡"
    case .thunder:
      return "🏚"
    case .magic:
      return "🧞‍♂️"
    case .sixers:
      return "🔔"
    case .suns:
      return "🗑"
    case .blazers:
      return "🌲"
    case .kings:
      return "🕳"
    case .spurs:
      return "🌵"
    case .raptors:
      return "🏆"
    case .jazz:
      return "🎷"
    case .wizards:
      return "🔫"
    }
  }
}

extension Team: Equatable {
  static func ==(lhs: Team, rhs: Team) -> Bool {
    return lhs.id == rhs.id
  }
}

extension Team: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
