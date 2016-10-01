//
//  LoginViewController.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/23/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
  @IBOutlet weak var backgroundView: UIView!
  
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var createButton: UIButton!
  
  init() {
    super.init(nibName: String(describing: LoginViewController.self), bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    usernameTextField.delegate = self
    passwordTextField.delegate = self
    emailTextField.delegate = self
    submitButton.isEnabled = false
    createButton.isEnabled = false
  }
  
  func refreshButtonsEnabled() {
    var usernameCount = 0
    if let text = usernameTextField.text {
      usernameCount += text.characters.count
    }
    
    var passwordCount = 0
    if let text = passwordTextField.text {
      passwordCount += text.characters.count
    }
    
    var emailCount = 0
    var components = 0
    if let text = emailTextField.text {
      components = text.components(separatedBy: ["@", "."]).count
      emailCount += text.characters.count
    }
    
    submitButton.isEnabled = usernameCount > 0 && passwordCount > 0
    createButton.isEnabled = submitButton.isEnabled && emailCount > 8 && components == 3
  }

  
  // MARK: UITextFieldDelegate
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if string.contains(" ") {
      return false
    }
    
    if let text = textField.text{
      let nsString = text as NSString
      let newString = nsString.replacingCharacters(in: range, with: string)
      textField.text = newString
      refreshButtonsEnabled()
      textField.text = text
    }
    
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTextField {
      passwordTextField.becomeFirstResponder()
    } else {
      self.view.endEditing(true)
    }
    return true
  }
  
  func authenticate() {
    if let username = usernameTextField.text, let password = passwordTextField.text {
      Backend.authenticateUser(username: username, password: password) { [unowned self] (tokenDictionary, success) in
        if success, let dictionary = tokenDictionary as? [String : String] {
          if let token = dictionary["token"] {
            if let user = User.shared {
              user.token = token
              self.dismiss()
            } else {
              Backend.getUserDetails(username: username, token: token, completion: { [unowned self] (userDictionary, success) in
                if success, let dictionary = userDictionary as? [String : AnyObject] {
                  let user = User(dictionary: dictionary)
                  user.token = token
                  User.shared = user
                  self.dismiss()
                  
                } else {
                  UIAlertController.alertFailed(title: "GET User Details Failed", message: String(describing: userDictionary), viewController: self)
                }
                
              })
            }
          }
        } else {
          UIAlertController.alertFailed(title: "Authenticate User Failed", message: String(describing: tokenDictionary), viewController: self)
        }
      }
    }
  }
  
  func dismiss() {
    Pools.shared.getPools()
    Pools.shared.joinPool()
    User.saveUser()
    self.presentingViewController?.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func submitPressed(_ sender: UIButton) {
    authenticate()
  }
  
  @IBAction func createPressed(_ sender: UIButton) {
    if let username = usernameTextField.text, let password = passwordTextField.text, let email = emailTextField.text {
      Backend.createUser(username: username, password: password, email: email, completion: { [unowned self] (userDictionary, success) in
        if success, let dictionary = userDictionary as? [String : AnyObject] {
          let user = User(dictionary: dictionary)
          User.shared = user
          User.saveUser()
          self.authenticate()
        } else {
          UIAlertController.alertFailed(title: "Create User Failed", message: String(describing: userDictionary), viewController: self)
        }
      })
    }
  }
}
