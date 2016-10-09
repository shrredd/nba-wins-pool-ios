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
    setup(gradientView: leftGradient, leftward: true)
    setup(gradientView: rightGradient, leftward: false)
  }
  
  func setup(gradientView: UIView, leftward: Bool) {
    let gradient: CAGradientLayer = CAGradientLayer()
    gradient.frame = leftGradient.bounds
    gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
    gradient.startPoint = CGPoint(x: leftward ? 1 : 0, y: 0.5)
    gradient.endPoint = CGPoint(x: leftward ? 0 : 1, y: 0.5)
    gradientView.layer.insertSublayer(gradient, at: 0)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
