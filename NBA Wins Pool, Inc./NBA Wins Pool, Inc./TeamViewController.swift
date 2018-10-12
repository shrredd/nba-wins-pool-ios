//
//  TeamViewController.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 10/13/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class TeamViewController: UIViewController {
  @IBOutlet weak var emoji: UILabel!
  @IBOutlet weak var record: UILabel!
  @IBOutlet weak var rank: UILabel!
  @IBOutlet weak var gamesBack: UILabel!
  @IBOutlet weak var streak: UILabel!
  @IBOutlet weak var lastTen: UILabel!
  @IBOutlet weak var homeRecord: UILabel!
  @IBOutlet weak var roadRecord: UILabel!
  @IBOutlet weak var conferenceRecord: UILabel!
  @IBOutlet weak var pointsScored: UILabel!
  @IBOutlet weak var pointsAllowed: UILabel!
  @IBOutlet weak var pointDifferential: UILabel!
  
  var team: Team!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.addBackButton(viewController: self)
    refreshUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: Teams.shared.updated), object: nil)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func reloadData() {
    refreshUI()
  }
  
  func refreshUI() {
    title = team.fullName
    emoji.text = team.emoji
    emoji.backgroundColor = team.primaryColor
    
    if let r = team.record {
      record.text = "\(r.wins)-\(r.losses) (\(String(format: "%.1f", r.percentage*100.0)))"
    }
    
    rank.text = "\(team.rank!)"
    gamesBack.text = team.gamesBack == 0 ? "-" : String(format: "%.1f", team.gamesBack!)
    streak.text = (team.streakType == .Winning ? "Won" : "Lost") + " \(team.streak!)"
    lastTen.text = team.lastTenRecord?.asString
    homeRecord.text = team.homeRecord?.asString
    roadRecord.text = team.awayRecord?.asString
    conferenceRecord.text = team.conferenceRecord?.asString
    pointsScored.text = String(format: "%.1f", team.pointsScoredPerGame ?? 0)
    pointsAllowed.text = String(format: "%.1f", team.pointsAllowedPerGame ?? 0)
    pointDifferential.text = String(format: "%.1f", team.pointDifferentialPerGame ?? 0)
  }
}
