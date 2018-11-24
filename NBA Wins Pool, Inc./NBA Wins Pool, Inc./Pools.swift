//
//  Pools.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/10/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class Pools {
  static let shared = Pools()
  var idToPool = [Int : Pool]()
  var pools: Set<Pool> {
    return Set(idToPool.values)
  }
  var idForInvitedPool: Int?
  weak var delegate: PoolsDelegate?
  
  init() {
    load()
    Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(getPools), userInfo: nil, repeats: true)
    Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: #selector(getPicks), userInfo: nil, repeats: true)
  }
  
  func load() {
    if let data = UserDefaults.standard.value(forKey: "pools") as? Data {
      do {
        let pools = try JSONDecoder().decode([Pool].self, from: data)
        for pool in pools {
          idToPool[pool.id] = pool
        }
      } catch {
        print(error)
      }
    }
  }
  
  func getPoolWithId(_ id: Int) {
    Backend.shared.getPoolWithId(id) { [weak self] (success, pool) in
      if success {
        if let p = pool {
          self?.updatePool(p)
        }
      }
    }
  }
  
  @objc func getPools() {
    guard let user = User.shared, let token = user.token else { return }
    Backend.shared.getPools(username: user.username, token: token) { [weak self] (success, pools) in
      if success {
        if let p = pools {
          for pool in p {
            self?.updatePool(pool)
          }
        }
      }
    }
  }
  
  func createPoolWithName(_ name: String, size: String, username: String, completion: @escaping (Bool) -> Void) {
    Backend.shared.createPool(name: name, size: size, username: username, completion: { [weak self] (success, pool) in
      if success {
        if let p = pool {
          self?.updatePool(p)
        }
      }
      completion(success)
    })
  }
  
  func joinPool() {
    guard let id = idForInvitedPool, let user = User.shared, let token = user.token else { return }
    Backend.shared.joinPool(id: id, username: user.username, token: token, completion: { [weak self] (success, pool) in
      if success {
        self?.idForInvitedPool = nil
        if let p = pool {
          self?.updatePool(p)
        }
      } else {
        UIAlertController.alertOK(title: "Failed to Join Pool")
      }
    })
  }
  
  func leavePoolWithId(_ id: Int, completion: @escaping (Bool) -> Void) {
    guard let token = User.shared?.token else {
      completion(false)
      return
    }
    Backend.shared.leavePool(id: id, token: token, completion: { [weak self] (success) in
      if success {
        self?.idToPool[id] = nil
        self?.save()
      }
      completion(success)
    })
  }
  
  func pickTeamWithId(_ id: String, forPoolWithId poolId: Int, completion: @escaping (Bool) -> Void) {
    guard let token = User.shared?.token else {
      completion(false)
      return
    }
    Backend.shared.pickTeamWithId(id, forPoolWithId: poolId, token: token) { [weak self] (success, picks) in
      if success {
        if let p = picks {
          if let pool = self?.idToPool[poolId] {
            self?.updatePicks(p, forPool: pool)
          }
        }
      }
      completion(success)
    }
  }
  
  func getPicksForPool(_ pool: Pool) {
    Backend.shared.getPicksForPoolId(pool.id) { [weak self] (success, picks) in
      if success {
        if let p = picks {
          self?.updatePicks(p, forPool: pool)
        }
      }
    }
  }
  
  @objc func getPicks() {
    for pool in idToPool.values {
      if !pool.isComplete && pool.userWithPick != User.shared {
        getPicksForPool(pool)
      }
    }
  }
  
  func updatePool(_ pool: Pool) {
    var isSaveNeeded = false
    if let p = idToPool[pool.id] {
      isSaveNeeded = p.members != pool.members || p.draft_status != pool.draft_status
      p.members = pool.members
      p.draft_status = pool.draft_status
    } else {
      isSaveNeeded = true
      idToPool[pool.id] = pool
    }
    
    if isSaveNeeded {
      delegate?.pools(self, didUpdatePool: idToPool[pool.id] ?? pool)
      save()
    }
  }
  
  func updatePicks(_ picks: [Pool.Pick], forPool pool: Pool) {
    if pool.draft_status != picks {
      pool.draft_status = picks
      delegate?.pools(self, didUpdatePool: pool)
      save()
    }
    
  }
  
  func save() {
    do {
      let data = try JSONEncoder().encode(Array(idToPool.values))
      UserDefaults.standard.set(data, forKey: "pools")
      UserDefaults.standard.synchronize()
    } catch {
      print(error)
    }
  }
  
  func removeAll() {
    idToPool.removeAll()
    save()
  }
}

protocol PoolsDelegate: class {
  func pools(_ pools: Pools, didUpdatePool pool: Pool)
}
