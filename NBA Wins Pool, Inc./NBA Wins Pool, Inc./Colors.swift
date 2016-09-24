//
//  Colors.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/17/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

extension UIColor {
  static func pinkishRed() -> UIColor {
    return UIColor(red: 255, green: 0, blue: 91, alpha:1)
  }
  
  static func blueishGray() -> UIColor {
    return UIColor(red: 95, green: 100, blue: 132, alpha:1)
  }
  
  static func almostBlackGray() -> UIColor {
    return UIColor(red: 36, green: 38, blue: 51, alpha:1)
  }
  
  static func lightBlueishGray() -> UIColor {
    return UIColor(red: 173, green: 177, blue: 204, alpha:1)
  }
  
  static func basketballOrange() -> UIColor {
    return UIColor(red: 229, green: 138, blue: 37, alpha:1)
  }
}


extension CALayer {
  func setBorderColorFromUIColor(color: UIColor) {
    self.borderColor = color.cgColor
  }
}
