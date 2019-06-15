//
//  MapVC.swift
//  OnTheMap
//
//  Created by Hadi Albinsaad on 21/10/2018.
//  Copyright © 2018 Hadi. All rights reserved.
//

import UIKit
import MapKit


class MapVC: UIViewController {
    
    var studentsLocations: [StudentLocation]? {
        return UdacityAPI.studentsLocations
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (studentsLocations == nil) {
            reloadStudentsLocations(self)
        } else {
            updateAnnotations()
        }
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
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
        self.checkPostHistory(withIdentifier: "mapToNewLocation")
    }
    
    @IBAction func reloadStudentsLocations(_ sender: Any) {
        UdacityAPI.fetchStudentsLocations { (errorMessage) in
            if let errorMessage = errorMessage {
                self.alert(title: "Error", message: errorMessage)
                return
            }
            DispatchQueue.main.async {
                self.updateAnnotations()
            }
        }
    }
    
    func updateAnnotations() {
        guard let studentsLocations = studentsLocations else {
            return
        }
        
        let annotations = studentsLocations.compactMap { (studentLocation) -> MKPointAnnotation in
            let lat = CLLocationDegrees(studentLocation.latitude ?? 0)
            let long = CLLocationDegrees(studentLocation.longitude ?? 0)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = studentLocation.firstName ?? ""
            let last = studentLocation.lastName ?? ""
            let mediaURL = studentLocation.mediaURL ?? ""
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            return annotation
        }
        
        let newAnnotations = annotations.filter { a in
            return !mapView.annotations.contains { b in
                
                let x = a.coordinate
                let y = b.coordinate
                return Int(x.latitude) == Int(y.latitude)
                    && Int(x.longitude) == Int(y.longitude)
            }
        }
        
        mapView.addAnnotations(newAnnotations)
    }
}

// MARK: - MKMapViewDelegate

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "FancyPinId"
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        guard control == view.rightCalloutAccessoryView else {
            return
        }
        
        guard let mediaURL = view.annotation?.subtitle ?? "", let url = URL(string: mediaURL) else {
            alert(title: "Ooops!", message: "The media URL provided by this student is not a valid URL")
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}

