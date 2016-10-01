//
//  StoredDictionaries.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 10/1/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class StoredDictionaries<Item> where Item: DictionaryBase, Item: Equatable {
  var items = [Item]()
  
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
      let newItem = Item(dictionary: dictionary)
      if let index = items.index(of: newItem) {
        let oldItem = items[index]
        oldItem.dictionary = newItem.dictionary
      } else {
        items.append(newItem)
      }
    }
    
    save()
    NotificationCenter.default.post(name: Notification.Name(rawValue: updated), object: self)
  }
  
  func add(_ item: Item) {
    if let index = items.index(of: item) {
      let oldItem = items[index]
      oldItem.dictionary = item.dictionary
    } else {
      items.append(item)
    }
    
    save()
    NotificationCenter.default.post(name: Notification.Name(rawValue: updated), object: nil)
  }
  
  func remove(_ item: Item) {
    if let index = items.index(of: item) {
      items.remove(at: index)
    }
    save()
  }
  
  func removeAll() {
    items = [Item]()
    save()
  }
  
  func save() {
    var dictionaries = [[String : AnyObject]]()
    for item in items {
      dictionaries.append(item.dictionary)
    }
    
    UserDefaults.standard.set(dictionaries, forKey: type)
    UserDefaults.standard.synchronize()
  }
  
}
