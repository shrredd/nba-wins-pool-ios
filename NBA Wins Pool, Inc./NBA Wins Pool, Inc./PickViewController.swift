//
//  PickViewController.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 10/9/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class PickViewController: UIViewController {
  
  var team: Team!
  var pool: Pool!
  
  @IBOutlet weak var emoji: UILabel!
  @IBOutlet weak var teamName: UILabel!
  @IBOutlet weak var teamRecord: UILabel!
  @IBOutlet weak var button: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Confirm Your Pick"
    emoji.text = team.emoji
    emoji.backgroundColor = team.primaryColor
    button.layer.cornerRadius = 4.0
    teamName.text = team.name
    let r = team.record
    teamRecord.text = "\(r?.wins ?? 0)-\(r?.losses ?? 0) (\(String(format: "%.1f", (r?.percentage ?? 0)*100.0)))"

    navigationController?.addBackButton(viewController: self)
  }
  
  @IBAction func confirmPressed(_ sender: UIButton) {
    Pools.shared.pickTeamWithId(team!.id.rawValue, forPoolWithId: pool.id) { (success) in
      if !success {
        UIAlertController.alertOK(title: "Failed to Make Pick")
      }
    }
    navigationController?.popViewController(animated: true)
  }
  
}
