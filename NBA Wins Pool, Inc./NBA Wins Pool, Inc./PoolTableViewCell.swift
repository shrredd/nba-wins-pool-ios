//
//  PoolTableViewCell.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/10/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class PoolTableViewCell: UITableViewCell {
  
  @IBOutlet weak var button: UIButton!
  @IBOutlet weak var curvedView: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var membersLabel: UILabel!
  
  weak var delegate: PoolTableViewCellDelegate?
  
  @IBOutlet weak var buttonBackgroundView: UIView!
  override func layoutSubviews() {
    super.layoutSubviews()
    curvedView.layer.cornerRadius = 4.0
    buttonBackgroundView.layer.cornerRadius = 4.0
    button.layer.cornerRadius = 4.0
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  @IBAction func buttonPressed(_ sender: UIButton) {
    delegate?.poolCellButtonPressed(cell: self)
  }
}

protocol PoolTableViewCellDelegate: class {
  func poolCellButtonPressed(cell: PoolTableViewCell)
}
