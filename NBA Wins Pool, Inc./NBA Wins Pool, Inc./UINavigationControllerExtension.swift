//
//  UINavigationControllerExtension.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 10/9/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

extension UINavigationController {
  func addBackButton(viewController: UIViewController) {
    let button = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(popViewController(animated:)))
    button.tintColor = UIColor.pinkishRed
    viewController.navigationItem.leftBarButtonItem = button
  }
}
