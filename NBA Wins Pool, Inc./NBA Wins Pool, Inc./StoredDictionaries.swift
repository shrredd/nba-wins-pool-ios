//
//  StoredDictionaries.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 10/1/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class StoredDictionaries {
  var bases = [DictionaryBase]()
  
  let type: String
  var updated: String {
    return type + " updated"
  }
  
  init(type: String) {
    self.type = type
    if let array = UserDefaults.standard.object(forKey: type) as? [[String : AnyObject]] {
      load(array: array)
    }
  }
  
  func load(array: [[String : AnyObject]]) {
    for dictionary in array {
      let base = dictionaryBase(dictionary: dictionary)
      if let index = bases.index(of: base) {
        let oldBase = bases[index]
        oldBase.dictionary = base.dictionary
      } else {
        bases.append(base)
      }
    }
    
    save()
    NotificationCenter.default.post(name: Notification.Name(rawValue: updated), object: self)
  }
  
  func dictionaryBase(dictionary: [String : AnyObject]) -> DictionaryBase {
    return DictionaryBase(dictionary: dictionary)
  }
  
  func add(base: DictionaryBase) {
    if let index = bases.index(of: base) {
      let oldBase = bases[index]
      oldBase.dictionary = base.dictionary
    } else {
      bases.append(base)
    }
    
    save()
    NotificationCenter.default.post(name: Notification.Name(rawValue: updated), object: nil)
  }
  
  func remove(base: DictionaryBase) {
    if let index = bases.index(of: base) {
      bases.remove(at: index)
    }
    save()
  }
  
  func removeAll() {
    bases = [DictionaryBase]()
    save()
  }
  
  func save() {
    var dictionaries = [[String : AnyObject]]()
    for base in bases {
      dictionaries.append(base.dictionary)
    }
    
    UserDefaults.standard.set(dictionaries, forKey: type)
    UserDefaults.standard.synchronize()
  }
  
}
