//
//  DictionaryBase.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 10/1/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class DictionaryBase {
  
  init(dictionary: [String : AnyObject]) {
    self.dictionary = dictionary
  }
  
  var dictionary: [String : AnyObject] {
    didSet {
      didSetDictionary(oldValue: oldValue)
    }
  }
  
  func didSetDictionary(oldValue: [String : AnyObject]) {
    for (key, value) in oldValue {
      if dictionary[key] == nil {
        dictionary[key] = value
      }
    }
  }
}
