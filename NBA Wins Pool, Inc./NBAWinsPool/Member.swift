//
//  Member.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/23/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Firebase

struct Member: Codable, Identifiable {
  let id: String
  let name: String
}

extension Member: Equatable {
  static func ==(lhs: Member, rhs: Member) -> Bool {
    return lhs.id == rhs.id
  }
}

extension Member: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension Member: CustomStringConvertible {
  var description: String {
    return "<name=\(name)>"
  }
}

extension Member {
  static var currentMember: Member? {
    return Auth.auth().currentUser?.member
  }
}

extension User {
  var member: Member {
    // TODO: change name
    return Member(id: uid, name: displayName ?? email ?? "Anonymous")
  }
}
