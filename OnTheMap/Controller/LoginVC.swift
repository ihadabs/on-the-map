//
//  LoginVC.swift
//  OnTheMap
//
//  Created by Hadi Albinsaad on 21/10/2018.
//  Copyright © 2018 Hadi. All rights reserved.
//

import UIKit


class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBAction func register(_ sender: Any) {
        guard let url = URL(string: "https://auth.udacity.com/sign-up") else {
            print("Invaild Registertion URL!")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func login(_ sender: UIButton) {
        view.endEditing(true)
        updateUI(processing: true)
        
        guard let email = emailField.text?.trimmingCharacters(in: .whitespaces),
            let password = passwordField.text?.trimmingCharacters(in: .whitespaces),
            !email.isEmpty, !password.isEmpty
        else {
            alert(title: "Waring", message: "Email and Password should not be empty!")
            updateUI(processing: false)
            return
        }
        
 
        UdacityAPI.login(with: email, password: password) { errorMessage in
            self.updateUI(processing: false)
            if let errorMessage = errorMessage {
                self.alert(title: "Error", message: errorMessage)
                return
            }
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ShowTapVC", sender: self)
            }
        }
    }
    
    func updateUI(processing: Bool) {
        DispatchQueue.main.async {
            self.emailField.isUserInteractionEnabled = !processing
            self.passwordField.isUserInteractionEnabled = !processing
            self.loginButton.isEnabled = !processing
            self.activityIndicator.isHidden = !processing
            if processing {
                self.loginButton.setTitle("", for: .normal)
            } else {
                self.loginButton.setTitle("Login", for: .normal)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailField {
            passwordField.becomeFirstResponder()
        } else {
            passwordField.resignFirstResponder()
        }
        return true
    }
    
}
