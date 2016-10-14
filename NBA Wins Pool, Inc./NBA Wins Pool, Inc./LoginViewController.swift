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
  @IBOutlet weak var createAccountBackgroundView: UIView!
  
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var createButton: UIButton!
  
  var backgroundViewOrigin: CGFloat!
  
  init() {
    super.init(nibName: String(describing: LoginViewController.self), bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    backgroundViewOrigin = backgroundView.frame.origin.y
    usernameTextField.delegate = self
    passwordTextField.delegate = self
    emailTextField.delegate = self
    submitButton.layer.cornerRadius = 4.0
    createButton.layer.cornerRadius = 4.0
    backgroundView.layer.cornerRadius = 4.0
    createAccountBackgroundView.layer.cornerRadius = 4.0
    
    refreshButtonsEnabled()
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
    
    var emailValid = false
    if let text = emailTextField.text {
      var components = text.components(separatedBy: "@")
      if components[0].characters.count > 0 && components.count == 2 {
        let rightComponents = components[1].components(separatedBy: ".")
        if rightComponents.count == 2 && rightComponents[0].characters.count > 0 && rightComponents[1].characters.count > 2 {
          emailValid = true
        }
      }
    }
    
    submitButton.isEnabled = usernameCount > 0 && passwordCount > 8
    createButton.isEnabled = submitButton.isEnabled && emailValid
    refresh(button: submitButton)
    refresh(button: createButton)
  }
  
  func refresh(button: UIButton) {
    button.backgroundColor = button.isEnabled ? UIColor.pinkishRed : UIColor.lightGray
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: UITextFieldDelegate
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    animateOffset(up: textField == emailTextField)
    return true
  }
  
  func animateOffset(up: Bool) {
    var offset: CGFloat = 0
    
    if up {
      offset = backgroundViewOrigin - 200.0 - backgroundView.frame.origin.y
    } else {
      offset = backgroundViewOrigin - backgroundView.frame.origin.y
    }
    
    UIView.animate(withDuration: 0.3) {
      for subview in self.view.subviews {
        subview.center = CGPoint(x: subview.center.x, y: subview.center.y + offset)
      }
    }
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if string.contains(" ") {
      return false
    }
    
    if let text = textField.text {
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
    } else if textField == passwordTextField {
      emailTextField.becomeFirstResponder()
    } else {
      self.view.endEditing(true)
      animateOffset(up: false)
    }
    return true
  }
  
  func authenticate() {
    if let username = usernameTextField.text, let password = passwordTextField.text {
      Backend.authenticateUser(username: username, password: password) { [unowned self] (tokenJSON, success) in
        if success, let tokenDictionary = tokenJSON as? [String : AnyObject] {
          if let user = User.shared {
            user.dictionary = tokenDictionary
            self.dismiss()
          } else if let token = tokenDictionary["token"] as? String {
            Backend.getUserDetails(username: username, token: token, completion: { [unowned self] (userJSON, success) in
              if success, let userDictionary = userJSON as? [String : AnyObject] {
                let user = User(dictionary: userDictionary)
                user.dictionary = tokenDictionary
                User.shared = user
                self.dismiss()
                
              } else {
                UIAlertController.alertOK(title: "GET User Details Failed", message: String(describing: userJSON), viewController: self)
              }
              
              })
          }
        } else {
          UIAlertController.alertOK(title: "Authenticate User Failed", message: String(describing: tokenJSON), viewController: self)
        }
      }
    }
  }
  
  func dismiss() {
    User.save()
    Pools.shared.getPools()
    Pools.shared.joinPool()
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
          User.save()
          self.authenticate()
        } else {
          UIAlertController.alertOK(title: "Create User Failed", message: String(describing: userDictionary), viewController: self)
        }
      })
    }
  }
}
