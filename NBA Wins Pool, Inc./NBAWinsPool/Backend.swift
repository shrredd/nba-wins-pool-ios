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
    request.httpMethod = httpMethod
    if let headerFields = fields {
      for (key, value) in headerFields {
        request.addValue(value, forHTTPHeaderField: key)
      }
    }
    print("sending request=\(request)")
    let task = session.dataTask(with: request) { (data, response, error) in
      let success = ((response as? HTTPURLResponse)?.statusCode.isIn200s() ?? true) && error == nil
      DispatchQueue.main.async {
        if let e = error {
          print(e)
        }
        
        if !success, let d = data, let string = String(data: d, encoding: .utf8), !string.isEmpty {
          UIAlertController.alertOK(title: "Request Failed", message: string)
        }
        print("received response=\(response?.description ?? "nil")")
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

