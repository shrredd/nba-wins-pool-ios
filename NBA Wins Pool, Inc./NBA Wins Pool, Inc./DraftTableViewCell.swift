//
//  DraftTableViewCell.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 10/8/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class DraftTableViewCell: UITableViewCell {
  @IBOutlet weak var pick: UILabel!
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var emoji: UILabel!
  @IBOutlet weak var leftGradient: UIView!
  @IBOutlet weak var rightGradient: UIView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    leftGradient.addGradient(from: UIColor.black, to: UIColor.clear, direction: .left)
    rightGradient.addGradient(from: UIColor.clear, to: UIColor.black, direction: .right)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
