//
//  NewPinVC.swift
//  OnTheMap
//
//  Created by Hadi Albinsaad on 21/10/2018.
//  Copyright © 2018 Hadi. All rights reserved.
//

import UIKit
import CoreLocation


class NewPinVC: UIViewController, UITextFieldDelegate {
    
    var locationCoordinate: CLLocationCoordinate2D!
    var locationName: String!

    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromNewPinVCToShareVC" {
            let vc = segue.destination as! ShareVC
            vc.locationCoordinate = locationCoordinate
            vc.locationName = locationName
//            vc.link = linkField.text
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateUI(processing: Bool) {
        DispatchQueue.main.async {
            if processing {
                self.findButton.setTitle("", for: .normal)
            } else{
                self.findButton.setTitle("Find", for: .normal)
            }
            self.locationField.isUserInteractionEnabled = !processing
            self.findButton.isEnabled = !processing
        }
    }
    
    @IBAction func find(_ sender: UIButton) {
        updateUI(processing: true)
        guard let locationName = locationField.text?.trimmingCharacters(in: .whitespaces), !locationName.isEmpty
        else {
            alert(title: "Waring", message: "Location should not be empty :(")
            updateUI(processing: false)
            return
        }
        
        getCoordinateFrom(location: locationName) { (locationCoordinate, error) in
            if let error = error {
                self.alert(title: "Error", message: "Try different city name :(")
                print(error.localizedDescription)
                self.updateUI(processing: false)
                return
            }
            
            self.locationCoordinate = locationCoordinate
            self.locationName = locationName
            self.updateUI(processing: false)

            self.performSegue(withIdentifier: "fromNewPinVCToShareVC", sender: self)
        }
    }
    
    func getCoordinateFrom(location: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(location) { placemarks, error in
            completion(placemarks?.first?.location?.coordinate, error)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
