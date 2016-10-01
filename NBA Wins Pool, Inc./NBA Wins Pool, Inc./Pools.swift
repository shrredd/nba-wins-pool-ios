//
//  Pools.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/10/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class Pools: StoredDictionaries<Pool> {
  
  static let shared = Pools()
  var idForInvitedPool: Int?
  
  init() {
    super.init(type: "pools")
    
    Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(getPools), userInfo: nil, repeats: true)
  }
  
  @objc func getPools() {
    if let user = User.shared {
      if let token = user.token {
        Backend.getPools(username: user.username, token: token, completion: { [unowned self] (poolsArray, success) in
          if success, let array = poolsArray as? [[String : AnyObject]] {
            self.load(array: array)
            self.getPoolStatuses()
          } else if poolsArray != nil {
            UIAlertController.alertOK(title: "GET Pools Failed", message: String(describing: poolsArray))
          }
        })
      }
    }
  }
  
  func getPoolStatuses() {
    for pool in items {
      if let draft = pool.draft {
        if !draft.isComplete && draft.userWithPick != User.shared! {
          pool.getPoolStatus()
        }
      } else {
        pool.getPoolStatus()
      }
    }
  }
  
  func joinPool() {
    if let user = User.shared {
      if let token = user.token {
        if let id = idForInvitedPool {
          Backend.joinPool(id: id, username: user.username, token: token, completion: { [unowned self] (poolDictionary, success) in
            if success, let dictionary = poolDictionary as? [String : AnyObject] {
              self.add(Pool(dictionary: dictionary))
              self.idForInvitedPool = nil
            } else {
              UIAlertController.alertOK(title: "Failed to Join Pool", message: String(describing: poolDictionary))
            }
          })
        }
      }
    }
  }
}
