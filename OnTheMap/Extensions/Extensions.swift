//
//  Extension.swift
//  OnTheMap
//
//  Created by Hadi Albinsaad on 21/10/2018.
//  Copyright © 2018 Hadi. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkPostHistory(withIdentifier identifier: String) {
        if UserDefaults.standard.value(forKey: "studentLocation") != nil {
            let alert = UIAlertController(title: "You have already posted a student location, would you like to post another?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Post Another", style: .destructive, handler: { (action) in
                self.performSegue(withIdentifier: identifier, sender: self)
            }))
            present(alert, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: identifier, sender: self)
        }
    }
}


extension UIButton {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
