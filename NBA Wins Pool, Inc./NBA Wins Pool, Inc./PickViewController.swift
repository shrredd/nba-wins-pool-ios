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
  @IBOutlet weak var topGradient: UIView!
  @IBOutlet weak var bottomGradient: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Confirm Your Pick"
    emoji.text = team.emoji
    emoji.backgroundColor = team.primaryColor
    button.layer.cornerRadius = 4.0
    teamName.text = team.fullName
    teamRecord.text = "Last Year's Record: ?-?"
    topGradient.addGradient(from: UIColor.black, to: UIColor.clear, direction: .down)
    bottomGradient.addGradient(from: UIColor.clear, to: UIColor.black, direction: .up)
    
    navigationController?.addBackButton(viewController: self)
  }
  
  @IBAction func confirmPressed(_ sender: UIButton) {
    pool.pick(team: team.id)
    _ = navigationController?.popViewController(animated: true)
  }
  
}
