//
//  UIViewExtension.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 10/9/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

extension UIView {
  
  enum GradientDirection {
    case up, down, left, right
  }
  
  func addGradient(from: UIColor, to: UIColor, direction: GradientDirection) {
    let gradient: CAGradientLayer = CAGradientLayer()
    gradient.frame = self.bounds
    gradient.colors = [from, to]
    
    switch direction {
    case .up:
      gradient.startPoint = CGPoint(x: 1, y: 0.5)
      gradient.endPoint = CGPoint(x: 0, y: 0.5)
    case .down:
      gradient.startPoint = CGPoint(x: 0, y: 0.5)
      gradient.endPoint = CGPoint(x: 1, y: 0.5)
    case .left:
      gradient.startPoint = CGPoint(x: 0.5, y: 1)
      gradient.endPoint = CGPoint(x: 0.5, y: 0)
    case .right:
      gradient.startPoint = CGPoint(x: 0.5, y: 0)
      gradient.endPoint = CGPoint(x: 0.5, y: 1)
    }
    self.layer.insertSublayer(gradient, at: 0)
  }
  
}
