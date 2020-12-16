//
//  CreateViewController.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/4/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var poolNameTextField: UITextField!
  @IBOutlet weak var numberOfPlayersSegment: UISegmentedControl!
  @IBOutlet weak var createPoolButton: UIButton!
  @IBOutlet weak var nameBackgroundView: UIView!
  @IBOutlet weak var numberOfPlayersBackgroundView: UIView!
  
  var user: User? {
    return Auth.auth().currentUser
  }
  
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
    
    // TODO: change to use username
    guard let uid = user?.uid, let username = user?.displayName ?? user?.email else {
      UIAlertController.alertOK(title: "Create Pool Failed", message: "Failed to get current info.", viewController: self)
      return
    }
    
    let index = numberOfPlayersSegment.selectedSegmentIndex
    guard let poolName = poolNameTextField.text,
          let sizeString = numberOfPlayersSegment.titleForSegment(at: index),
          let size = Int(sizeString) else { return }
    let pool = Pool(id: UUID().uuidString,
                    name: poolName,
                    size: size,
                    members: [.init(id: uid, name: username)])
    FirebaseInterface.createPool(pool) { (error) in
      guard let e = error else {
        _ = self.navigationController?.popViewController(animated: true)
        return
      }
      UIAlertController.alertOK(title: "Create Pool Failed", message: e.localizedDescription, viewController: self)
    }
  }
  
  @IBAction func backPressed(_ sender: UIBarButtonItem) {
    if let controller = navigationController {
      _ = controller.popViewController(animated: true)
    }
  }
  
}
