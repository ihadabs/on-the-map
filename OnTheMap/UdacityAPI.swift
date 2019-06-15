//
//  Udacity.swift
//  onthemap
//
//  Created by Hadi Albinsaad on 22/10/2018.
//  Copyright © 2018 Hadi. All rights reserved.
//

import UIKit
import MapKit


class UdacityAPI {
   
    static func postSession(with email: String, password: String, completion: @escaping ([String:Any]?, Error?) -> ()) {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(nil, error)
                return
            }
            
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range)
            let result = try! JSONSerialization.jsonObject(with: newData!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
            completion(result, nil)

        }
        task.resume()
    }
    
    static func deleteSession(completion: @escaping (Error?) -> ()) {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(error)
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            completion(nil)
        }
        task.resume()
    }
    
    class Parse {
        
        static func postStudentLocation(link: String, locationCoordinate: CLLocationCoordinate2D, locationName: String, completion: @escaping (Error?) -> ()) {
            var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
            request.httpMethod = "POST"
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"uniqueKey\": \"111111\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"\(locationName)\", \"mediaURL\": \"\(link)\",\"latitude\": \(locationCoordinate.latitude), \"longitude\": \(locationCoordinate.longitude)}".data(using: .utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil {
                    completion(error)
                    return
                }
                print(String(data: data!, encoding: .utf8)!)
                completion(nil)
                
//                (UIApplication.shared.delegatee as! AppDelegate).memes
//                Global.memes
//                Global.shared.memes
//                Global.init().memes
            }
            task.resume()
        }
    
        static func getStudentsLocations(completion: @escaping ([StudentLocation]?, Error?) -> ()) {
            let BASE_URL = "https://parse.udacity.com/parse/classes/StudentLocation"
            var request = URLRequest(url: URL(string: BASE_URL + "?limit=100&order=-updatedAt" )!)
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil {
                    completion(nil, error)
                    return
                }
                
                let dict = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                print(dict)
                guard let results = dict["results"] as? [[String:Any]] else { return }
                """
                [
                    student = {
                        name = "Ahmed",
                        age = 20
                    },
                    student =  {
                        name = "Ahmed",
                
                    }
                ]
                """
                let resultsData = try! JSONSerialization.data(withJSONObject: results, options: .prettyPrinted)
                let studentsLocations = try! JSONDecoder().decode([StudentLocation].self, from: resultsData)

                
                Global.shared.studentsLocations = studentsLocations
                completion(studentsLocations, nil)
            }
            task.resume()
        }
    } 
    
}
