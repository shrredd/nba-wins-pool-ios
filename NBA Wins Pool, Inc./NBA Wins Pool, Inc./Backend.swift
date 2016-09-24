//
//  Backend.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/10/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class Backend {
  
  static let poolHost = "https://steph-curry-mvp.herokuapp.com/api/v1/"
  static let accounts = "accounts/"
  static let auth = "auth/"
  
  static let userName = "username"
  static let userPassword = "password"
  static let userEmail = "email"
  static let userToken = "token"
  
  // MARK: user creation and authentication
  
  static func createUser(username: String, password: String, email: String, completion: @escaping (AnyObject?, Bool) -> Void) {
    let JSONObject = [userName : username,
                      userPassword : password,
                      userEmail : email]
    do {
      let body = try JSONSerialization.data(withJSONObject: JSONObject)
      
      requestJSON(httpMethod: "POST", host: poolHost, endPoint: accounts, fields: ["Content-Type" : "application/json"], body: body) { (JSON, statusCode, error) in
        if let status = statusCode {
          if status.isIn200s() {
            completion(JSON, true)
            return
          }
        }
        
        completion(JSON, false)
      }
      
    } catch {
      completion(nil, false)
    }
  }
  
  static func authenticateUser(username: String, password: String, completion: @escaping (AnyObject?, Bool) -> Void) {
    let JSONObject = [userName : username,
                      userPassword : password]
    
    do {
      let body = try JSONSerialization.data(withJSONObject: JSONObject)
      
      requestJSON(httpMethod: "POST", host: poolHost, endPoint: auth, fields: ["Content-Type" : "application/json"], body: body) { (JSON, statusCode, error) in
        if let status = statusCode {
          if status.isIn200s() {
            completion(JSON, true)
            return
          }
        }
        
        completion(JSON, false)
      }
      
    } catch {
      completion(nil, false)
    }
    
  }
  
  static func getUserDetails(username: String, token: String, completion: @escaping (AnyObject?, Bool) ->Void) {
    requestJSON(httpMethod: "GET", host: poolHost, endPoint: accounts+username+"/", fields: ["Authorization" : "Token " + token]) { (JSON, statusCode, error) in
      if let status = statusCode {
        if status.isIn200s() {
          completion(JSON, true)
          return
        }
      }
      
      completion(JSON, false)
    }
  }
  
  // MARK: pool backend
  
  static func createPool(name: String, size: String, creator: User, completion: (String?) -> Void) {
    completion("pool_id")
  }
  
  static func joinPool(id: String, player: User, completion: (Bool) -> Void) {
    completion(true)
  }
  
  // MARK: team backend
  
  static let teamHost = "https://erikberg.com/"
  static let teamsEndpoint = "nba/teams.json"
  static let standingsEnpoint = "nba/standings.json"
  
  static func getTeams(completion: @escaping ([[String : AnyObject]]?, Int?, Error?) -> Void) {
    requestJSON(httpMethod: "GET", host: teamHost, endPoint: teamsEndpoint) { (JSON, statusCode, error) in
      if let array = JSON as? [[String : AnyObject]] {
        completion(array, statusCode, error)
      } else {
        completion(nil, statusCode, error)
      }
    }
  }
  
  static func getStandings(completion: @escaping ([String : AnyObject]?, Int?, Error?) -> Void) {
    requestJSON(httpMethod: "GET", host: teamHost, endPoint: standingsEnpoint, completion: { (JSON, statusCode, error) in
      if let dictionary = JSON as? [String : AnyObject] {
        completion(dictionary, statusCode, error)
      } else {
        completion(nil, statusCode, error)
      }
    })
  }
  
  // MARK: helper functions
  
  static func requestJSON(httpMethod: String,
                          host: String,
                          endPoint:String,
                          parameters: [String : String]? = nil,
                          fields: [String : String]? = nil,
                          body: Data? = nil,
                          completion: @escaping (AnyObject?, Int?, Error?) -> Void) {
    request(httpMethod: httpMethod, host: host, endPoint: endPoint, parameters: parameters, fields: fields, body: body) { (data, statusCode, error) in
      var JSON: AnyObject? = nil
      if let JSONData = data {
        do {
          JSON = try JSONSerialization.jsonObject(with: JSONData) as AnyObject
        } catch {
          print(error)
          JSON = nil
        }
      }
      
      completion(JSON, statusCode, error)
    }
  }
  
  static func request(httpMethod: String,
                      host: String,
                      endPoint: String,
                      parameters: [String : String]? = nil,
                      fields: [String : String]? = nil,
                      body: Data? = nil,
                      completion: @escaping (Data?, Int?, Error?) -> Void) {
    var string = ""
    var separator = "?"
    
    if parameters != nil {
      for (parameter, value) in parameters! {
        string += separator + parameter + "=" + value
        separator = "&"
      }
    }
    
    if let escapedString = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
      let url = URL(string: host + endPoint + escapedString)
      var request = URLRequest(url: url!)
      request.httpBody = body
      request.cachePolicy = .reloadIgnoringLocalCacheData
      request.httpMethod = httpMethod
      if let headerFields = fields {
        for (key, value) in headerFields {
          request.addValue(value, forHTTPHeaderField: key)
        }
      }
      
      
      let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        DispatchQueue.main.async {
          if error != nil {
            print(error)
          }
          
          if let httpResponse = response as? HTTPURLResponse {
            completion(data, httpResponse.statusCode, error)
          } else {
            completion(data, nil, error)
          }
          
        }
      }
      task.resume()
    }
  }
}

extension Int {
  func isIn200s() -> Bool {
    return self >= 200 && self < 300
  }
}

