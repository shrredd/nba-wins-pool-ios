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
  @IBOutlet weak var accountButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  
  enum State {
    case login, create
  }
  
  var state: State = .login {
    didSet {
      var height = passwordTextField.frame.minY - usernameTextField.frame.maxY
      
      switch state {
      case .login:
        titleLabel.text = "Sign In"
        accountButton.setTitle("need an account?", for: .normal)
        submitButton.setTitle("Sign In", for: .normal)
        passwordTextField.returnKeyType = .done
        height += passwordTextField.frame.maxY
      case .create:
        titleLabel.text = "Register"
        accountButton.setTitle("have an account?", for: .normal)
        submitButton.setTitle("Register", for: .normal)
        passwordTextField.returnKeyType = .next
        height += emailTextField.frame.maxY
      }
      
      animate(frame: CGRect(origin: backgroundView.frame.origin,
                            size: CGSize(width: backgroundView.frame.size.width, height: height)))
    }
  }
  
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
    submitButton.layer.cornerRadius = 4.0
    backgroundView.layer.cornerRadius = 4.0
    state = .login
  }
  
  var isValid: Bool {
    var usernameCount = 0
    if let text = usernameTextField.text {
      usernameCount += text.count
    }
    
    var passwordCount = 0
    if let text = passwordTextField.text {
      passwordCount += text.count
    }
    
    var isEmailValid = false
    if let text = emailTextField.text {
      var components = text.components(separatedBy: "@")
      if components[0].count > 0 && components.count == 2 {
        let rightComponents = components[1].components(separatedBy: ".")
        if rightComponents.count == 2 && rightComponents[0].count > 0 && rightComponents[1].count > 2 {
          isEmailValid = true
        }
      }
    }
    
    let isUserNameValid = usernameCount > 0
    let isPasswordValid = passwordCount > 8
    let isLoginValid = isUserNameValid && isPasswordValid
    
    let title = state == .login ? "Login Failed" : "Create Account Failed"
    
    if !isUserNameValid {
      UIAlertController.alertOK(title: title, message: "You must enter a username.")
    } else if !isPasswordValid {
      UIAlertController.alertOK(title: title, message: "You must enter a password that is at least 9 characters long.")
    } else if state == .create && !isEmailValid {
      UIAlertController.alertOK(title: title, message: "You must enter a valid email address to create an account.")
    }
    
    switch state {
    case .login:
      return isLoginValid
    case .create:
      return isLoginValid && isEmailValid
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  func animate(frame: CGRect) {
    UIView.animate(withDuration: 0.2) {
      self.backgroundView.frame = frame
    }
  }
  
  // MARK: UITextFieldDelegate
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return !string.contains(" ")
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTextField {
      passwordTextField.becomeFirstResponder()
    } else if state == .create && textField == passwordTextField {
      emailTextField.becomeFirstResponder()
    } else {
      self.view.endEditing(true)
    }
    return true
  }
  
  func authenticate() {
    if let username = usernameTextField.text, let password = passwordTextField.text {
      Backend.shared.authenticateUser(username: username, password: password) { [unowned self] (tokenJSON, success) in
        if success, let tokenDictionary = tokenJSON as? [String : AnyObject] {
          if let user = User.shared {
            user.dictionary = tokenDictionary
            self.dismiss()
          } else if let token = tokenDictionary["token"] as? String {
            Backend.shared.getUserDetails(username: username, token: token, completion: { [unowned self] (userJSON, success) in
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
  
  func create() {
    if let username = usernameTextField.text, let password = passwordTextField.text, let email = emailTextField.text {
      Backend.shared.createUser(username: username, password: password, email: email, completion: { [unowned self] (userDictionary, success) in
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
  
  func dismiss() {
    User.save()
    Pools.shared.getPools()
    Pools.shared.joinPool()
    self.presentingViewController?.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func submitPressed(_ sender: UIButton) {
    if isValid {
      switch state {
      case .login:
        authenticate()
      case .create:
        create()
      }
    }
  }
  
  @IBAction func accountPressed(_ sender: UIButton) {
    switch state {
    case .login:
      state = .create
    case .create:
      state = .login
    }
  }
}
