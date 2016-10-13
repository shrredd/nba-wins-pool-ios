//
//  UserTableViewCell.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/17/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var recordLabel: UILabel!
  
  var labels = [UILabel]()
  var teams: [Team]! {
    didSet {
      for label in labels {
        label.removeFromSuperview()
      }
      labels.removeAll()
      
      let width = bounds.size.width/CGFloat(teams.count)
      for (index, team) in teams.enumerated() {
        let origin = CGPoint(x: width * CGFloat(index), y: 0)
        let size = CGSize(width: width, height: bounds.size.height)
        let label = UILabel(frame: CGRect(origin: origin, size: size))
        label.text = team.emoji
        label.textAlignment = .center
        label.backgroundColor = team.primaryColor
        label.font = UIFont(name: "Helvetica", size: 100)
        label.lineBreakMode = .byClipping
        label.alpha = 0.4
        contentView.insertSubview(label, at: 0)
        labels.append(label)
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
}
