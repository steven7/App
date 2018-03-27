//
//  Extensions.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/21/17.
//  Copyright © 2017 steve. All rights reserved.
//

import Foundation
import UIKit

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
    
    func copyButton() -> UIButton {
        let copyButton = UIButton(type: .custom)
        copyButton.setTitle(self.titleLabel?.text, for: .normal)
        copyButton.titleLabel?.font = UIFont(name: "System", size: 20.0)
        copyButton.setTitleColor(UIColor.lightBlue, for: .normal)
        copyButton.backgroundColor = UIColor.clear
        // copyButton.setBackgroundImage(self.currentBackgroundImage, for: .normal)
        //copyButton.setImage(self.currentImage, for: .normal)
        copyButton.setImage(self.image(for: .normal), for: .normal)
        copyButton.imageView?.layer.cornerRadius = 10
        copyButton.layer.cornerRadius = 10
        copyButton.frame = self.frame
        //copyButton.frame =
            // CGRect(x: buttonThree.frame.minX, y: buttonThree.frame.minY, width: buttonThree.frame.width, height: buttonThree.frame.height)
        return copyButton
    }
    
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
    
    func uploadSuccessPopup() {
        let alert = UIAlertController(title: "Success", message: "Upload was successful", preferredStyle: .alert)
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
    
    func comingSoonPopup( ) {
        let alert = UIAlertController(title: "Upload Picture", message: "Feature comming soon!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
