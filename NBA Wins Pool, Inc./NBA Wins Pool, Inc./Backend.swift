//
//  Backend.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/10/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

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
    self.session = URLSession(configuration: config)
  }
  
  // MARK: user creation and authentication
  
  func createUser(username: String, password: String, email: String, completion: @escaping (Bool, User?) -> Void) {
    let JSONObject: [String : Any] = [userName : username,
                                      userPassword : password,
                                      userEmail : email]
    uploadJSON(host: poolHost, endPoint: accounts, JSONObject: JSONObject, completion: completion)
  }
  
  func authenticateUser(username: String, password: String, completion: @escaping (Bool, User.Token?) -> Void) {
    let JSONObject = [userName : username as Any,
                      userPassword : password as Any]
    uploadJSON(host: poolHost, endPoint: auth, JSONObject: JSONObject, completion: completion)
  }
  
  func getUserDetails(username: String, token: String, completion: @escaping (Bool, User?) -> Void) {
    request(host: poolHost, endPoint: accounts + username + "/",
                fields: ["Authorization" : "Token " + token], completion: completion)
  }
  
  // MARK: pool backend
  
  func createPool(name: String, size: String, username: String, completion: @escaping (Bool, Pool?) -> Void) {
    let members = [username]
    let JSONObject = ["name" : name as Any,
                      "max_size" : size as Any,
                      "members" : members as Any]
    
    uploadJSON(host: poolHost, endPoint: "pools/", JSONObject: JSONObject, completion: completion)
  }
  
  func getPools(username: String, token: String, completion: @escaping (Bool, [Pool]?) -> Void) {
    request(host: poolHost, endPoint: username + "/pools/",
            fields: ["Authorization" : "Token " + token], completion: completion)
  }
  
  func joinPool(id: Int, username: String, token: String, completion: @escaping (Bool, Pool?) -> Void) {
    let JSONObject = ["username" : username as Any]
    uploadJSON(httpMethod: "PUT", host: poolHost, endPoint: "pools/\(id)/members/",
      fields: ["Authorization" : "Token " + token], JSONObject: JSONObject, completion: completion)
  }
  //  http://localhost:3000/api/v1/pools/42/members/
  func leavePool(id: Int, token: String, completion: @escaping (Bool) -> Void) {
    request(httpMethod: "DELETE", host: poolHost, endPoint: "pools/\(id)/members/", fields: ["Authorization" : "Token " + token]) { (success, data) in
      completion(success)
    }
  }
  
  func getPoolWithId(_ id: Int, completion: @escaping (Bool, Pool?) -> Void) {
    request(host: poolHost, endPoint: "pools/\(id)", completion: completion)
  }
  
  func getPicksForPoolId(_ id: Int, completion: @escaping (Bool, [Pool.Pick]?) -> Void) {
    request(host: poolHost, endPoint: "pools/\(id)/draft/", completion: completion)
  }
  
  func pickTeamWithId(_ teamId: String, forPoolWithId poolId: Int, token: String, completion: @escaping (Bool, [Pool.Pick]?) -> Void) {
    let JSONObject = ["team_id" : teamId as Any]
    uploadJSON(httpMethod: "PUT", host: poolHost, endPoint: "pools/\(poolId)/draft/",
      fields: ["Authorization" : "Token " + token], JSONObject: JSONObject, completion: completion)
  }
  
  // MARK: helper functions
  
  func uploadJSON<T: Decodable>(httpMethod: String = "POST",
                                host: String,
                                endPoint: String,
                                parameters: [String : String]? = nil,
                                fields: [String : String]? = nil,
                                JSONObject: [String : Any],
                                completion: @escaping (Bool, T?) -> Void) {
    
    do {
      let body = try JSONSerialization.data(withJSONObject: JSONObject)
      
      var dictionary = ["Content-Type" : "application/json"]
      if let moreFields = fields {
        for (key, value) in moreFields {
          dictionary[key] = value
        }
      }
      
      
      request(httpMethod: httpMethod, host: host, endPoint: endPoint, fields: dictionary, body: body, completion: completion)
    } catch {
      completion(false, nil)
    }
  }
  
  func request<T: Decodable>(httpMethod: String = "GET",
                             host: String,
                             endPoint: String,
                             parameters: [String : String]? = nil,
                             fields: [String : String]? = nil,
                             body: Data? = nil,
                             completion: @escaping (Bool, T?) -> Void) {
    request(httpMethod: httpMethod, host: host, endPoint: endPoint, parameters: parameters, fields: fields, body: body) { (success, data) in
      var t: T?
      if success, let d = data {
        do {
          t = try JSONDecoder().decode(T.self, from: d)
        } catch {
          print(error)
        }
      }
      completion(success, t)
    }
  }
  
  func request(httpMethod: String = "GET",
               host: String,
               endPoint: String,
               parameters: [String : String]? = nil,
               fields: [String : String]? = nil,
               body: Data? = nil,
               completion: @escaping (Bool, Data?) -> Void) {
    var string = ""
    var separator = "?"
    
    if parameters != nil {
      for (parameter, value) in parameters! {
        string += separator + parameter + "=" + value
        separator = "&"
      }
    }
    
    var components = URLComponents(string: host + endPoint)!
    components.queryItems = parameters?.map { URLQueryItem(name: $0, value: $1) }
    components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
    var request = URLRequest(url: components.url!)
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
        if let e = error {
          print(e)
        }
        
        let success = ((response as? HTTPURLResponse)?.statusCode.isIn200s() ?? true) && error == nil
        if !success, let d = data, let string = String(data: d, encoding: .utf8), string != "" {
          UIAlertController.alertOK(title: "Request Failed", message: string)
        }
        completion(success, data)
      }
    }
    task.resume()
  }
}

extension Int {
  func isIn200s() -> Bool {
    return self >= 200 && self < 300
  }
}

