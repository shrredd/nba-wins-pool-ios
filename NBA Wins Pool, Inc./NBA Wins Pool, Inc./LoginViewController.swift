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
      Backend.shared.authenticateUser(username: username, password: password) { [weak self] (success, token) in
        if success, let t = token?.token {
          if let user = User.shared {
            user.token = t
            self?.dismiss()
          } else {
            Backend.shared.getUserDetails(username: username, token: t, completion: { (success, user) in
              if success, let u = user {
                User.shared = u
                u.token = t
                self?.dismiss()
              } else {
                UIAlertController.alertOK(title: "Authenticate User Failed", message: "fail", viewController: self)
              }
            })
          }
        } else {
          UIAlertController.alertOK(title: "Authenticate User Failed", message: "fail", viewController: self)
        }
      }
    }
  }
  
  func create() {
    guard let username = usernameTextField.text, let password = passwordTextField.text, let email = emailTextField.text else { return }
    Backend.shared.createUser(username: username, password: password, email: email, completion: { [weak self] (success, user) in
      if success, let u = user {
        User.shared = u
        User.save()
        self?.authenticate()
      }
    })
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
