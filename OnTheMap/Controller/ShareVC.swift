//
//  ShareVC.swift
//  OnTheMap
//
//  Created by Hadi Albinsaad on 21/10/2018.
//  Copyright © 2018 Hadi. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ShareVC: UIViewController, UITextFieldDelegate {
    
    var locationName: String!
    var locationCoordinate: CLLocationCoordinate2D!
    var annotation = MKPointAnnotation()
    
    var pinRegion: MKCoordinateRegion {
        return MKCoordinateRegion(center: locationCoordinate!, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
    
    @IBOutlet weak var linkField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var annotation = MKPointAnnotation()
//        annotation.coordinate = locationCoordinate!
//        annotation.title = Global.studentName.0 + " " + Global.studentName.1
//        annotation.subtitle = linkField.text ?? ""
//
//        mapView.addAnnotation(annotation)
//        mapView.selectAnnotation(annotation, animated: true)
        
        
        linkField.addTarget(self, action: #selector(linkDidChange(_:)), for: .allEditingEvents)
        
        mapView.addAnnotation(annotation)
        updateSampleAnnotation()
    }
    
    @IBAction func submit(_ sender: Any) {
        UdacityAPI.postStudentLocation(mediaURL: linkField.text ?? "", locationCoordinate: locationCoordinate, locationName: locationName) { (errorMessage) in
            if let errorMessage = errorMessage {
                self.alert(title: "Error", message: errorMessage)
                return
            }
            UserDefaults.standard.set(self.locationName, forKey: "studentLocation")
            DispatchQueue.main.async {
                self.parent!.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    
        view.endEditing(true)
    }
    
    @objc func linkDidChange(_ textField: UITextField) {
        updateSampleAnnotation()
    }
    
    func updateSampleAnnotation() {
        
        annotation.coordinate = locationCoordinate!
        annotation.title = UdacityAPI.randomFirstName + " " + UdacityAPI.randomLastName
        annotation.subtitle = linkField.text ?? ""
        
        mapView.setRegion(pinRegion, animated: true)
        
        let isSelected = mapView.selectedAnnotations.contains { $0 === self.annotation }
        if !isSelected {
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ShareVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pinId"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}
