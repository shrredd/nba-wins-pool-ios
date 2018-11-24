//
//  CreateViewController.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/4/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class CreateViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var poolNameTextField: UITextField!
  @IBOutlet weak var numberOfPlayersSegment: UISegmentedControl!
  @IBOutlet weak var createPoolButton: UIButton!
  @IBOutlet weak var nameBackgroundView: UIView!
  @IBOutlet weak var numberOfPlayersBackgroundView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    nameBackgroundView.layer.cornerRadius = 4.0
    numberOfPlayersBackgroundView.layer.cornerRadius = 4.0
    createPoolButton.layer.cornerRadius = 4.0
    poolNameTextField.delegate = self
    refreshCreatePoolEnabled()
  }
  
  func refreshCreatePoolEnabled() {
    var nameHasCharacters = false
    if let count = poolNameTextField.text?.count {
      nameHasCharacters = count > 0
    }
    
    createPoolButton.isEnabled = nameHasCharacters
  }
  
  // MARK: UITextFieldDelegate
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    view.endEditing(true)
    
    return true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    refreshCreatePoolEnabled()
    return true
  }
  
  @IBAction func didSelectNumberOfPlayers(_ sender: UISegmentedControl) {
    refreshCreatePoolEnabled()
  }
  
  @IBAction func createPoolPressed(_ sender: UIButton) {
    view.endEditing(true)
    
    if let name = poolNameTextField.text,
      let size = numberOfPlayersSegment.titleForSegment(at: numberOfPlayersSegment.selectedSegmentIndex),
      let username = User.shared?.username {
      Pools.shared.createPoolWithName(name, size: size, username: username) { (success) in
        if success {
          _ = self.navigationController?.popViewController(animated: true)
        } else {
          UIAlertController.alertOK(title: "Create Pool Failed", message: "Fail", viewController: self)
        }
      }
    }
  }
  
  @IBAction func backPressed(_ sender: UIBarButtonItem) {
    if let controller = navigationController {
      _ = controller.popViewController(animated: true)
    }
  }
  
}
