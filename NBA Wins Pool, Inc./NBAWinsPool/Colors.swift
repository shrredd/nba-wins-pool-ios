//
//  Colors.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/17/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

extension UIColor {
  
  convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
    self.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1)
  }
  
  static var pinkishRed: UIColor {
    return UIColor(red: 255, green: 0, blue: 91)
  }
  
  static var blueishGray: UIColor {
    return UIColor(red: 95.0/255.0, green: 100.0/255.0, blue: 132.0/255.0, alpha:1)
  }
  
  static var almostBlackGray: UIColor {
    return UIColor(red: 36.0/255.0, green: 38.0/255.0, blue: 51.0/255.0, alpha:1)
  }
  
  static var lightBlueishGray: UIColor {
    return UIColor(red: 173.0/255.0, green: 177.0/255.0, blue: 204.0/255.0, alpha:1)
  }
  
  static var basketballOrange: UIColor {
    return UIColor(red: 229.0/255.0, green: 138.0/255.0, blue: 37.0/255.0, alpha:1)
  }
}

extension CALayer {
  func setBorderColorFromUIColor(color: UIColor) {
    self.borderColor = color.cgColor
  }
}
