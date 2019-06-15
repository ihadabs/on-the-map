//
//  ListVC.swift
//  OnTheMap
//
//  Created by Hadi Albinsaad on 21/10/2018.
//  Copyright © 2018 Hadi. All rights reserved.
//

import UIKit

class ListVC: UITableViewController {
    
    private let cellId = "FancyCellId"
    
    var studentsLocations: [StudentLocation]? {
        return UdacityAPI.studentsLocations
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (studentsLocations == nil) {
            reloadStudentsLocations(self)
        } else {
            tableView.reloadData()
        }
    }

    @IBAction func logout(_ sender: Any) {
        UdacityAPI.logout { (errorMessage) in
            if let errorMessage = errorMessage {
                self.alert(title: "Error", message: errorMessage)
                return
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func postPin(_ sender: Any) {
        self.checkPostHistory(withIdentifier: "listToNewLocation")
    }
    
    @IBAction func reloadStudentsLocations(_ sender: Any) {
        UdacityAPI.fetchStudentsLocations { (errorMessage) in
            if let errorMessage = errorMessage {
                self.alert(title: "Error", message: errorMessage)
                return
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsLocations?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        cell.textLabel?.text = studentsLocations?[indexPath.row].firstName
        cell.detailTextLabel?.text = studentsLocations?[indexPath.row].mediaURL
        
        cell.imageView?.image = UIImage(named: "pin")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = studentsLocations?[indexPath.row]
        
        guard let mediaURL = studentLocation?.mediaURL, let url = URL(string: mediaURL) else {
            alert(title: "Ooops!", message: "The media URL provided by this student is not a valid URL")
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}

