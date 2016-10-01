//
//  Pools.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/10/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class Pools: StoredDictionaries {
  
  static let shared = Pools()
  var idForInvitedPool: Int?
  
  init() {
    super.init(type: "pools")
    
    Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(getPools), userInfo: nil, repeats: true)
  }
  
  override func dictionaryBase(dictionary: [String : AnyObject]) -> DictionaryBase {
    return Pool(dictionary: dictionary)
  }
  
  var pools: [Pool] {
    return bases as! [Pool]
  }
  
  func add(pool: Pool) {
    super.add(base: pool)
  }
  
  func remove(pool: Pool) {
    super.remove(base: pool)
  }
  
  @objc func getPools() {
    if let user = User.shared {
      if let token = user.token {
        Backend.getPools(username: user.username, token: token, completion: { [unowned self] (poolsArray, success) in
          if success, let array = poolsArray as? [[String : AnyObject]] {
            self.load(array: array)
          } else if let vc = Pools.visibleViewController() {
            UIAlertController.alertFailed(title: "GET Pools Failed", message: String(describing: poolsArray), viewController: vc)
          }
        })
      }
    }
  }
  
  func joinPool() {
    if let user = User.shared {
      if let token = user.token {
        if let id = idForInvitedPool {
          Backend.joinPool(id: id, username: user.username, token: token, completion: { [unowned self] (poolDictionary, success) in
            if success, let dictionary = poolDictionary as? [String : AnyObject] {
              self.add(pool: Pool(dictionary: dictionary))
              self.idForInvitedPool = nil
            } else if let vc = Pools.visibleViewController() {
              UIAlertController.alertFailed(title: "Failed to Join Pool", message: String(describing: poolDictionary), viewController: vc)
            }
          })
        }
      }
    }
  }
  
  static func visibleViewController() -> UIViewController? {
    return (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)?.topViewController
  }
}
