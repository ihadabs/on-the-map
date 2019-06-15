//
//  Udacity.swift
//  OnTheMap
//
//  Created by Hadi Albinsaad on 22/10/2018.
//  Copyright © 2018 Hadi. All rights reserved.
//

import UIKit
import MapKit

class UdacityAPI {
    
    typealias completion = (_ errorMessage: String?) -> ()
    
    static var loginKey = ""
    static var randomFirstName = ""
    static var randomLastName = ""
    static var studentsLocations = [StudentLocation]()
    
    static func checkError(error: Error?, response: URLResponse?) -> String? {
        if error != nil {
            return error?.localizedDescription
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            let statusCodeError = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
            return statusCodeError.localizedDescription
        }
        
        guard statusCode >= 200 && statusCode < 300 else {
            var errorMessage = ""
            switch statusCode {
            case 400:
                errorMessage = "Bad Request"
            case 401:
                errorMessage = "Invalid Credentials"
            case 403:
                errorMessage = "Unauthorized"
            case 405:
                errorMessage = "HTTP Method Not Allowed"
            case 410:
                errorMessage = "URL Changed"
            case 500:
                errorMessage = "Server Error"
            default:
                errorMessage = "Try Again"
            }
            return errorMessage
        }
        return nil
    }
    
    static func login(with email: String, password: String, completion: @escaping completion) {
        
        let urlString = "https://onthemap-api.udacity.com/v1/session"
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let errorMessage = checkError(error: error, response: response) {
                completion(errorMessage)
                return
            }
            
            guard let data = data, data.count > 5 else {
                completion("Data is nil or data length < 5")
                return
            }
            
            let subdata = data[5..<data.count]
            
            guard let result = try? JSONSerialization.jsonObject(with: subdata, options: []) as? [String:Any] else {
                completion("Result is nil or could not be cast to [String:Any]")
                return
            }
            
            if let resultError = result["error"] as? String {
                completion(resultError)
                return
            }
            
            guard let account = result["account"] as? [String:Any], let key = account["key"] as? String else {
                completion("Account | Key is nil")
                return
            }
            
            UdacityAPI.loginKey = key
            
            completion(nil)
            
            }.resume()
    }
    
    static func logout(completion: @escaping completion) {
        
        let urlString = "https://onthemap-api.udacity.com/v1/session"
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let errorMessage = checkError(error: error, response: response) {
                completion(errorMessage)
                return
            }
            
            let newData = data?[5..<data!.count]
            print(String(data: newData!, encoding: .utf8)!)
            
            completion(nil)
            
            }.resume()
    }
    
    static func getRandomData(completion: @escaping completion) {
        
        let url = URL(string: "https://onthemap-api.udacity.com/v1/users/\(UdacityAPI.loginKey)")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let errorMessage = checkError(error: error, response: response) {
                completion(errorMessage)
                return
            }

            let subdata = data![5..<data!.count]
            
            guard let dictionary = try? JSONSerialization.jsonObject(with: subdata, options: []) as? [String : Any] else {
                completion("Result is nil or could not be cast to [String:Any]")
                return
            }
        
            UdacityAPI.randomFirstName = dictionary["first_name"] as? String ?? ""
            UdacityAPI.randomLastName = dictionary["last_name"] as? String ?? ""
            
            completion(nil)
            
            }.resume()
    }
    
    static func postStudentLocation(mediaURL: String, locationCoordinate: CLLocationCoordinate2D, locationName: String, completion: @escaping (String?) -> ()) {
        
        let urlString = "https://onthemap-api.udacity.com/v1/StudentLocation"
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(UdacityAPI.loginKey)\", \"firstName\": \"\(UdacityAPI.randomFirstName)\", \"lastName\": \"\(UdacityAPI.randomLastName)\",\"mapString\": \"\(locationName)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(locationCoordinate.latitude), \"longitude\": \(locationCoordinate.longitude)}".data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let errorMessage = checkError(error: error, response: response) {
                completion(errorMessage)
                return
            }
            
            print(String(data: data!, encoding: .utf8)!)
            
            completion(nil)
            
            }.resume()
    }
    
    static func fetchStudentsLocations(completion: @escaping (String?) -> ()) {
        
        let urlString = "https://onthemap-api.udacity.com/v1/StudentLocation?limit=100&order=-updatedAt"
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let errorMessage = checkError(error: error, response: response) {
                completion(errorMessage)
                return
            }
            
            let dictionary = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
            
            let results = dictionary["results"] as! [[String:Any]]
            
            let dataFromResults = try! JSONSerialization.data(withJSONObject: results, options: [])
            
            let studentsLocations = try! JSONDecoder().decode([StudentLocation].self, from: dataFromResults)
            
            UdacityAPI.studentsLocations = studentsLocations
            
            completion(nil)
            
            }.resume()
    }
}



