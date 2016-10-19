//
//  Backend.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/10/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import Foundation

class Backend {
  
  static let shared = Backend()
  
  let poolHost = "https://steph-curry-mvp.herokuapp.com/api/v1/"
  let accounts = "accounts/"
  let auth = "auth/"
  
  let userName = "username"
  let userPassword = "password"
  let userEmail = "email"
  let userToken = "token"
  
  let session: URLSession
  
  init() {
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    self.session = URLSession(configuration: config)
  }
  
  // MARK: user creation and authentication
  
  func createUser(username: String, password: String, email: String, completion: @escaping (AnyObject?, Bool) -> Void) {
    let JSONObject = [userName : username as AnyObject,
                      userPassword : password as AnyObject,
                      userEmail : email as AnyObject]
    uploadJSON(host: poolHost, endPoint: accounts, JSONObject: JSONObject, completion: completion)
  }
  
  func authenticateUser(username: String, password: String, completion: @escaping (AnyObject?, Bool) -> Void) {
    let JSONObject = [userName : username as AnyObject,
                      userPassword : password as AnyObject]
    uploadJSON(host: poolHost, endPoint: auth, JSONObject: JSONObject, completion: completion)
  }
  
  func getUserDetails(username: String, token: String, completion: @escaping (AnyObject?, Bool) -> Void) {
    requestJSON(host: poolHost, endPoint: accounts + username + "/",
                fields: ["Authorization" : "Token " + token], completion: completion)
  }
  
  // MARK: pool backend
  
  func createPool(name: String, size: String, username: String, completion: @escaping (AnyObject?, Bool) -> Void) {
    let members = [username]
    let JSONObject = ["name" : name as AnyObject,
                      "max_size" : size as AnyObject,
                      "members" : members as AnyObject]
    
    uploadJSON(host: poolHost, endPoint: "pools/", JSONObject: JSONObject, completion: completion)
  }
  
  func getPools(username: String, token: String, completion: @escaping (AnyObject?, Bool) -> Void) {
    requestJSON(host: poolHost, endPoint: username + "/pools/",
                fields: ["Authorization" : "Token " + token], completion: completion)
  }
  
  func joinPool(id: Int, username: String, token: String, completion: @escaping (AnyObject?, Bool) -> Void) {
    let JSONObject = ["username" : username as AnyObject]
    uploadJSON(httpMethod: "PUT", host: poolHost, endPoint: "pools/" + "\(id)/members/",
      fields: ["Authorization" : "Token " + token], JSONObject: JSONObject, completion: completion)
  }
  
  func getPoolInfo(id: Int, completion: @escaping (AnyObject?, Bool) -> Void) {
    requestJSON(host: poolHost, endPoint: "pools/\(id)", completion: completion)
  }
  
  func getDraftStatus(id: Int, completion: @escaping (AnyObject?, Bool) -> Void) {
    requestJSON(host: poolHost, endPoint: "pools/\(id)/draft/", completion: completion)
  }
  
  func pickTeam(poolID: Int, teamID: String, token: String, completion: @escaping (AnyObject?, Bool) -> Void) {
    let JSONObject = ["team_id" : teamID as AnyObject]
    uploadJSON(httpMethod: "PUT", host: poolHost, endPoint: "pools/\(poolID)/draft/",
      fields: ["Authorization" : "Token " + token], JSONObject: JSONObject, completion: completion)
  }
  
  // MARK: team backend
  
  let teamHost = "https://erikberg.com/"
  let teamsEndpoint = "nba/teams.json"
  let standingsEnpoint = "nba/standings.json"
  
  func getTeams(completion: @escaping (AnyObject?, Bool) -> Void) {
    requestJSON(host: teamHost, endPoint: teamsEndpoint, fields: ["User-Agent" : "WinsPool/1.0 (benz.jessen@gmail.com)"], completion: completion)
  }
  
  func getStandings(completion: @escaping (AnyObject?, Bool) -> Void) {
    requestJSON(host: teamHost, endPoint: standingsEnpoint, fields: ["User-Agent" : "WinsPool/1.0 (benz.jessen@gmail.com)"], completion: completion)
  }
  
  // MARK: helper functions
  
  func uploadJSON(httpMethod: String = "POST",
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
  
  func requestJSON(httpMethod: String = "GET",
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
  
  func request(httpMethod: String,
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
      
      let task = self.session.dataTask(with: request) { (data, response, error) in
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

