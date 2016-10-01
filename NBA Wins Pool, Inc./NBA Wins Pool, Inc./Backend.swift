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
  static let pools = "pools/"
  
  static let userName = "username"
  static let userPassword = "password"
  static let userEmail = "email"
  static let userToken = "token"
  
  static let poolName = "name"
  static let poolSize = "max_size"
  static let poolMembers = "members"
  
  // MARK: user creation and authentication
  
  static func createUser(username: String, password: String, email: String, completion: @escaping (AnyObject?, Bool) -> Void) {
    let JSONObject = [userName : username as AnyObject,
                      userPassword : password as AnyObject,
                      userEmail : email as AnyObject]
    uploadJSON(httpMethod: "POST", host: poolHost, endPoint: accounts, JSONObject: JSONObject, completion: completion)
  }
  
  static func authenticateUser(username: String, password: String, completion: @escaping (AnyObject?, Bool) -> Void) {
    let JSONObject = [userName : username as AnyObject,
                      userPassword : password as AnyObject]
    uploadJSON(httpMethod: "POST", host: poolHost, endPoint: auth, JSONObject: JSONObject, completion: completion)
  }
  
  static func getUserDetails(username: String, token: String, completion: @escaping (AnyObject?, Bool) -> Void) {
    requestJSON(httpMethod: "GET", host: poolHost, endPoint: accounts + username + "/",
                fields: ["Authorization" : "Token " + token], completion: completion)
  }
  
  // MARK: pool backend
  
  static func createPool(name: String, size: String, username: String, completion: @escaping (AnyObject?, Bool) -> Void) {
    let members = [username]
    let JSONObject = [poolName : name as AnyObject,
                      poolSize : size as AnyObject,
                      poolMembers : members as AnyObject]
    
    uploadJSON(httpMethod: "POST", host: poolHost, endPoint: pools, JSONObject: JSONObject, completion: completion)
  }
  
  static func getPools(username: String, token: String, completion: @escaping (AnyObject?, Bool) -> Void) {
    requestJSON(httpMethod: "GET", host: poolHost, endPoint: username + "/" + pools,
                fields: ["Authorization" : "Token " + token], completion: completion)
  }
  
  static func joinPool(id: Int, username: String, token: String, completion: @escaping (AnyObject?, Bool) -> Void) {
    let JSONObject = ["member" : username as AnyObject]
    uploadJSON(httpMethod: "PUT", host: poolHost, endPoint: pools + "\(id)",
      fields: ["Authorization" : "Token " + token], JSONObject: JSONObject, completion: completion)
  }
  
  // MARK: team backend
  
  static let teamHost = "https://erikberg.com/"
  static let teamsEndpoint = "nba/teams.json"
  static let standingsEnpoint = "nba/standings.json"
  
  static func getTeams(completion: @escaping (AnyObject?, Bool) -> Void) {
    requestJSON(httpMethod: "GET", host: teamHost, endPoint: teamsEndpoint, completion: completion)
  }
  
  static func getStandings(completion: @escaping (AnyObject?, Bool) -> Void) {
    requestJSON(httpMethod: "GET", host: teamHost, endPoint: standingsEnpoint, completion: completion)
  }
  
  // MARK: helper functions
  
  static func uploadJSON(httpMethod: String,
                         host: String,
                         endPoint: String,
                         parameters: [String : String]? = nil,
                         fields: [String : String]? = nil,
                         JSONObject: [String : AnyObject],
                         completion: @escaping (AnyObject?, Bool) -> Void) {
    
    do {
      let body = try JSONSerialization.data(withJSONObject: JSONObject)
      
      var dictionary = ["Content-Type" : "application/json"]
      if let moreFields = fields {
        for (key, value) in moreFields {
          dictionary[key] = value
        }
      }
      
      requestJSON(httpMethod: httpMethod, host: host, endPoint: endPoint, fields: dictionary, body: body, completion: completion)
    } catch {
      completion(nil, false)
    }
  }
  
  static func requestJSON(httpMethod: String,
                          host: String,
                          endPoint: String,
                          parameters: [String : String]? = nil,
                          fields: [String : String]? = nil,
                          body: Data? = nil,
                          completion: @escaping (AnyObject?, Bool) -> Void) {
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
      
      if let status = statusCode {
        if status.isIn200s() {
          completion(JSON, true)
          return
        }
      }
      
      completion(JSON, false)
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

