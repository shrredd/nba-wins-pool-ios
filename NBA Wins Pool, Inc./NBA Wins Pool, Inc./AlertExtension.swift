//
//  AlertExtension.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/24/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

extension UIAlertController {
  static func visibleViewController() -> UIViewController? {
    return (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)?.topViewController
  }
  
  static func alertOK(title: String, message: String, viewController: UIViewController? = nil) {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default)
    alertController.addAction(OKAction)
    
    var vc = viewController
    if viewController == nil {
      vc = visibleViewController()
    }
    
    vc?.present(alertController, animated: true)
  }
}
