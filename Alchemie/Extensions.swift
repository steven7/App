//
//  Extensions.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/21/17.
//  Copyright © 2017 steve. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func notConnectedToInternetPopup() {
        let alert = UIAlertController(title: "Not connected to internet", message: "Connect to the internet and try again", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func notFilledOutPopup() {
        let alert = UIAlertController(title: "Enter all fields", message: "Please fill out the above fields", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func passwordErrorPopup() {
        let alert = UIAlertController(title: "Passwords missmatch", message: "Please make the password match the confirm password", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func loginErrorPopup() {
        let alert = UIAlertController(title: "Wrong Credentials", message: "Please enter the correct login and password combo", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func errorPopup() {
        let alert = UIAlertController(title: "Error", message: "Something went wrong", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func overwriteWarningPopup(completion: @escaping ()->()) {
        let alert = UIAlertController(title: "Do you want to sync?", message: "Syncing with the server will overwrite all of your saved options and suboptions", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            completion()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func logoutPopup(completion: @escaping ()->()) {
        let alert = UIAlertController(title: "Do you want to log out of this user?", message: "You will need to be online to log back in.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            completion()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
