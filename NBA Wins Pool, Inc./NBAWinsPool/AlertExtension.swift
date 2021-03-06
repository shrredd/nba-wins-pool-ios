//
//  AlertExtension.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/24/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

extension UIAlertController {

  static func alertOK(title: String, message: String? = nil, viewController: UIViewController? = nil) {
    
    let alertController = UIAlertController(title: title, message: message ?? "Unknown error.", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default)
    alertController.addAction(OKAction)
    
    var vc = viewController
    if viewController == nil {
      vc = (UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController as? UINavigationController)?.topViewController
      if let presented = vc?.presentedViewController {
        vc = presented
      }
    }
    
    vc?.presentedViewController?.dismiss(animated: true, completion: nil)
    vc?.present(alertController, animated: true)
  }
}
