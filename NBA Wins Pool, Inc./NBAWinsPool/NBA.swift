//
//  NBA.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Jessen on 11/15/18.
//  Copyright © 2018 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class NBA {
  static let shared = NBA()
  static let standings = "http://data.nba.net/10s/prod/v1/current/standings_conference.json?fbclid=IwAR3HPj4FIv_fRQk6DSW2VvzE8hn_WrNLLGa9I5uQRpPAgcEwRGP6fWeyBTg"
  
  struct Standings: Codable {
    let league: League
  }
  struct League: Codable {
    let standard: Standard
  }
  struct Standard: Codable {
    let conference: Conference
  }
  struct Conference: Codable {
    let east: [Team.Standing]
    let west: [Team.Standing]
  }
  
  struct Team: Codable {
    let isNBAFranchise: Bool
    let isAllStar: Bool
    let city: String
    let altCityName: String
    let fullName: String
    let tricode: String
    let teamId: String
    let nickname: String
    let urlName: String
    let confName: String
    let divName: String
    
    struct Standing: Codable {
      let teamId: String
      let win: String
      let loss: String
      let winPct: String
      let winPctV2: String
      let lossPct: String
      let lossPctV2: String
      let gamesBehind: String
      let divGamesBehind: String
      let clinchedPlayoffsCode: String
      let clinchedPlayoffsCodeV2: String
      let confRank: String
      let confLoss: String
      let divWin: String
      let divLoss: String
      let homeWin: String
      let homeLoss: String
      let awayWin: String
      let awayLoss: String
      let lastTenWin: String
      let lastTenLoss: String
      let streak: String
      let divRank: String
      let isWinStreak: Bool
      let tieBreakerPts: String
    }
  }
  
  func getStandings(completion: @escaping (Bool, Standings?) -> Void) {
    Backend.shared.request(host: "http://data.nba.net/10s/",
                           endPoint: "prod/v1/current/standings_conference.json",
                           parameters: ["fbclid" : "IwAR3HPj4FIv_fRQk6DSW2VvzE8hn_WrNLLGa9I5uQRpPAgcEwRGP6fWeyBTg"],
                           completion: completion)
  }
}

extension NBA.Team.Standing {
  func toTeamId() -> Team.Id? {
    switch teamId {
    case "1610612737": return .hawks
    case "1610612738": return .celtics
    case "1610612751": return .nets
    case "1610612766": return .hornets
    case "1610612741": return .bulls
    case "1610612739": return .cavaliers
    case "1610612742": return .mavericks
    case "1610612743": return .nuggets
    case "1610612765": return .pistons
    case "1610612744": return .warriors
    case "1610612745": return .rockets
    case "1610612754": return .pacers
    case "1610612746": return .clippers
    case "1610612747": return .lakers
    case "1610612763": return .grizzlies
    case "1610612748": return .heat
    case "1610612749": return .bucks
    case "1610612750": return .timberwolves
    case "1610612740": return .pelicans
    case "1610612752": return .knicks
    case "1610612760": return .thunder
    case "1610612753": return .magic
    case "1610612755": return .sixers
    case "1610612756": return .suns
    case "1610612757": return .blazers
    case "1610612758": return .kings
    case "1610612759": return .spurs
    case "1610612761": return .raptors
    case "1610612762": return .jazz
    case "1610612764": return .wizards
    default: return nil
    }
  }
}

extension NBA.Team.Standing {
  var wins: Int {
    return Int(win) ?? 0
  }
  var losses: Int {
    return Int(loss) ?? 0
  }
}


extension NBA.Team: Equatable {
  static func ==(teamA: NBA.Team, teamB: NBA.Team) -> Bool {
    return teamA.teamId == teamB.teamId
  }
}

extension NBA.Team: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(teamId)
  }
}
