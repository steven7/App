//
//  Extensions.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/21/17.
//  Copyright © 2017 steve. All rights reserved.
//

import Foundation
import UIKit
import PopupDialog

extension UIImage {
    func crop( rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}


extension UIButton {
    
    
    
}

extension UIColor {
    
    static let lightBlue = UIColor(displayP3Red: 0.4, green: 0.66667, blue: 1.0, alpha: 1.0)
    
}

extension UIButton {
    
    /// Creates a duplicate of the terget UIButton
    /// The caller specified the UIControlEvent types to copy across to the duplicate
    ///
    /// - Parameter controlEvents: UIControlEvent types to copy
    /// - Returns: A UIButton duplicate of the original button
    func duplicate(forControlEvents controlEvents: [UIControlEvents]) -> UIButton? {
        
        // Attempt to duplicate button by archiving and unarchiving the original UIButton
        let archivedButton = NSKeyedArchiver.archivedData(withRootObject: self)
        guard let buttonDuplicate = NSKeyedUnarchiver.unarchiveObject(with: archivedButton) as? UIButton else { return nil }
        
        // Copy targets and associated actions
        self.allTargets.forEach { target in
            
            controlEvents.forEach { controlEvent in
                
                self.actions(forTarget: target, forControlEvent: controlEvent)?.forEach { action in
                    buttonDuplicate.addTarget(target, action: Selector(action), for: controlEvent)
                }
            }
        }
        
        return buttonDuplicate
    }
}

extension UIViewController {
    
    
    func notConnectedToInternetPopup() {
//        let alert = UIAlertController(title: "Not connected to internet", message: "Connect to the internet and try again", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//        alert.addAction(okAction)
        
        let popup = PopupDialog(title: "Not connected to internet", message: "Connect to the internet and try again") //, image: image)
        let okButton = DefaultButton(title: "OK", action: nil)
        popup.addButtons([okButton])
        self.present(popup, animated: true, completion: nil)
    }
    
    func notFilledOutPopup() {
//        let alert = UIAlertController(title: "Enter all fields", message: "Please fill out the above fields", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//        alert.addAction(okAction)
        let popup = PopupDialog(title: "Enter all fields", message: "Please fill out the above fields") //,
        let okButton = DefaultButton(title: "OK", action: nil)
        popup.addButtons([okButton])
        self.present(popup, animated: true, completion: nil)
    }
    
    func passwordErrorPopup() {
//        let alert = UIAlertController(title: "Passwords missmatch", message: "Please make the password match the confirm password", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//        alert.addAction(okAction)
        let popup = PopupDialog(title: "Passwords missmatch", message: "Please make the password match the confirm password") //,
        let okButton = DefaultButton(title: "OK", action: nil)
        popup.addButtons([okButton])
        self.present(popup, animated: true, completion: nil)
    }
    
    func loginErrorPopup() {
//        let alert = UIAlertController(title: "Wrong Credentials", message: "Please enter the correct login and password combo", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//        alert.addAction(okAction)
//        self.present(alert, animated: true, completion: nil)
        let popup = PopupDialog(title: "Wrong Credentials", message: "Please enter the correct login and password combo") //,
        let okButton = DefaultButton(title: "OK", action: nil)
        popup.addButtons([okButton])
        self.present(popup, animated: true, completion: nil)
    }
    
    func uploadSuccessPopup() {
//        let alert = UIAlertController(title: "Success", message: "Upload was successful", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//        alert.addAction(okAction)
//        self.present(alert, animated: true, completion: nil)
        let popup = PopupDialog(title: "Success", message: "Upload was successful") //,
        let okButton = DefaultButton(title: "OK", action: nil)
        popup.addButtons([okButton])
        self.present(popup, animated: true, completion: nil)
    }
    
    func partialErrorPopup(num: Int) {
//        let alert = UIAlertController(title: "Error", message: "Something went wrong with \(num) uploads", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//        alert.addAction(okAction)
//        self.present(alert, animated: true, completion: nil)
        let popup = PopupDialog(title: "Error", message: "Something went wrong with \(num) uploads") //,
        let okButton = DefaultButton(title: "OK", action: nil)
        popup.addButtons([okButton])
        self.present(popup, animated: true, completion: nil)
    }
    
    func errorPopup() {
//        let alert = UIAlertController(title: "Error", message: "Something went wrong", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//        alert.addAction(okAction)
//        self.present(alert, animated: true, completion: nil)
        let popup = PopupDialog(title: "Error", message: "Something went wrong")
        let okButton = DefaultButton(title: "OK", action: nil)
        popup.addButtons([okButton])
        self.present(popup, animated: true, completion: nil)
    }
    
    func overwriteWarningPopup(completion: @escaping ()->()) {
//        let alert = UIAlertController(title: "Do you want to sync?", message: "Syncing with the server will overwrite all of your saved options and suboptions", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
//            completion()
//        })
//        alert.addAction(cancelAction)
//        alert.addAction(okAction)
//        self.present(alert, animated: true, completion: nil)
        let popup = PopupDialog(title: "Do you want to sync?", message: "Syncing with the server will overwrite all of your saved options and suboptions")
        let cancelButton = CancelButton(title: "Cancel", action: nil)
        let okButton = DefaultButton(title: "OK", action:  {
            completion()
        })
        popup.addButtons([okButton, cancelButton])
        self.present(popup, animated: true, completion: nil)
    }
    
    func saveQuestionsPopup(completion: @escaping ()->()) {
//        let alert = UIAlertController(title: "Save", message: "Anwers saved. Do you want to exit the questionnaire?", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
//            completion()
//        })
//        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
//        alert.addAction(cancelAction)
//        alert.addAction(okAction)
//        self.present(alert, animated: true, completion: nil)
//        self.present(alert, animated: true, completion: nil)
        let popup = PopupDialog(title: "Save", message: "Anwers saved. Do you want to exit the questionnaire?")
        let cancelButton = CancelButton(title: "No", action: nil)
        let okButton = DefaultButton(title: "Yes", action:  {
            completion()
        })
        popup.addButtons([okButton, cancelButton])
        self.present(popup, animated: true, completion: nil)
    }
    
    func logoutPopup(completion: @escaping ()->()) {
//        let alert = UIAlertController(title: "Do you want to log out of this user?", message: "You will need to be online to log back in.", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
//            completion()
//        })
//        alert.addAction(cancelAction)
//        alert.addAction(okAction)
//        self.present(alert, animated: true, completion: nil)
        let popup = PopupDialog(title: "Do you want to log out of this user?", message: "You will need to be online to log back in.")
        let cancelButton = CancelButton(title: "Cancel", action: nil)
        let okButton = DefaultButton(title: "OK", action:  {
            completion()
        })
        popup.addButtons([okButton, cancelButton])
        self.present(popup, animated: true, completion: nil)
    }
    
    func comingSoonPopup( ) {
        let popup = PopupDialog(title: "Upload Picture", message: "Feature comming soon!")
        let okButton = DefaultButton(title: "OK", action:  nil)
        popup.addButtons([okButton])
        self.present(popup, animated: true, completion: nil)
    }
    
    func connectivityLostPopup() {
        let popup = PopupDialog(title: "Connectivity", message: "Internet connectivity lost. Please connect to Wi-Fi or Cellualr and try again.")
        let okButton = DefaultButton(title: "OK", action:  nil)
        popup.addButtons([okButton])
        self.present(popup, animated: true, completion: nil)
    }
}

protocol Copying {
    init(original: Self)
}

extension Copying {
    func copy() -> Self {
        return Self.init(original: self)
    }
}

extension Array where Element: Copying {
    func clone() -> Array {
        var copiedArray = Array<Element>()
        for element in self {
            copiedArray.append(element.copy())
        }
        return copiedArray
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

