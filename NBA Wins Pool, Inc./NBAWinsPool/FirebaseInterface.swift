//
//  FirebaseInterface.swift
//  Wins Pool
//
//  Created by John Jessen on 12/13/20.
//  Copyright © 2020 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct FirebaseInterface {
  
  static var db = Firestore.firestore()
  
  static func createPool(_ pool: Pool, completion: @escaping (Error?) -> Void) {
    do {
      try db.collection("pools").document(pool.id).setData(from: pool) { (error) in
        completion(error)
      }
    } catch {
      completion(error)
    }
  }
  
  static func joinPool(id: String, member: Member, completion: @escaping (Error?) -> Void) {
    let documentRef = db.collection("pools").document(id)
    db.runTransaction({ (transaction, errorPointer) -> Any? in
      
      // get the latest pool
      let pool: Pool?
      do {
        try pool = transaction.getDocument(documentRef).data(as: Pool.self)
      } catch let fetchError as NSError {
        errorPointer?.pointee = fetchError
        return nil
      }
      
      guard var p = pool else {
        let error = NSError(
          domain: "AppErrorDomain",
          code: -1,
          userInfo: [
            NSLocalizedDescriptionKey: "Unable to retrieve Pool from snapshot \(documentRef)"
          ]
        )
        errorPointer?.pointee = error
        return nil
      }
      
      // add new member
      p.addMember(member)
      
      guard let dictionary = p.dictionary else {
        let error = NSError(
          domain: "AppErrorDomain",
          code: -1,
          userInfo: [
            NSLocalizedDescriptionKey: "Unable to convert to dictionary pool=\(p)"
          ]
        )
        errorPointer?.pointee = error
        return nil
      }
      
      // update firebase data
      transaction.updateData(dictionary, forDocument: documentRef)
      return nil
    }) { (_, error) in
      completion(error)
    }
  }
  
  static func leavePool(_ pool: Pool, member: Member, completion: @escaping (Error?) -> Void) {
    let documentRef = db.collection("pools").document(pool.id)
    if pool.members == [member] {
      documentRef.delete(completion: completion)
      return
    }
    
    documentRef.updateData([
      "idToMember.\(member.id)": FieldValue.delete()
    ], completion: completion)
  }
  
  static func pickTeam(id teamId: String, poolId: String, member: Member, number: Int, completion: @escaping (Error?) -> Void) {
    let documentRef = db.collection("pools").document(poolId)
    db.runTransaction({ (transaction, errorPointer) -> Any? in
      
      // get the latest pool
      let pool: Pool?
      do {
        try pool = transaction.getDocument(documentRef).data(as: Pool.self)
      } catch let fetchError as NSError {
        errorPointer?.pointee = fetchError
        return nil
      }
      
      guard let p = pool else {
        let error = NSError(
          domain: "AppErrorDomain",
          code: -1,
          userInfo: [
            NSLocalizedDescriptionKey: "Unable to retrieve Pool from snapshot \(documentRef)"
          ]
        )
        errorPointer?.pointee = error
        return nil
      }
      
      guard p.currentPick?.member == member else {
        let error = NSError(
          domain: "AppErrorDomain",
          code: -1,
          userInfo: [
            NSLocalizedDescriptionKey: "It's not your turn to pick."
          ]
        )
        errorPointer?.pointee = error
        return nil
      }
      
      guard p.currentPick?.number == number else {
        let error = NSError(
          domain: "AppErrorDomain",
          code: -1,
          userInfo: [
            NSLocalizedDescriptionKey: "Picking for the wrong draft position."
          ]
        )
        errorPointer?.pointee = error
        return nil
      }
      
      transaction.updateData([
        "numberToPick.\(number).teamId": teamId
      ], forDocument: documentRef)
      return nil
    }) { (_, error) in
      completion(error)
    }
  }
  
  static func addPoolListener(id poolId: String, update: @escaping (Pool?, Error?) -> Void) -> ListenerRegistration {
    return db.collection("pools").document(poolId)
      .addSnapshotListener { (documentSnapshot, error) in
        if error != nil {
          update(nil, error)
          return
        }
        do {
          let updatedPool = try documentSnapshot?.data(as: Pool.self)
          update(updatedPool, error)
        } catch {
          update(nil, error)
        }
      }
  }
  
  static func addPoolsListener(member: Member, update: @escaping ([Pool]?, Error?) -> Void) -> ListenerRegistration {
    let query = db.collection("pools").whereField("idToMember.\(member.id)", isEqualTo: ["id": member.id, "name": member.name])
    return query.addSnapshotListener { (querySnapshot, error) in
      if error != nil {
        update(nil, error)
        return
      }
      let pools = querySnapshot?.documents.compactMap { try? $0.data(as: Pool.self) }
      update(pools, error)
    }
  }
  
  static func getPools(member: Member, completion: @escaping ([Pool]?, Error?) -> Void) {
    let query = db.collection("pools").whereField("idToMember.\(member.id)", isEqualTo: ["id": member.id, "name": member.name])
    query.getDocuments { (querySnapshot, error) in
      if error != nil {
        completion(nil, error)
        return
      }
      let pools = querySnapshot?.documents.compactMap { try? $0.data(as: Pool.self) }
      completion(pools, error)
    }
  }
  
}

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
