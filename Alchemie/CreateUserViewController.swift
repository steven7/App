//
//  CreateUserViewController.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/20/17.
//  Copyright © 2017 steve. All rights reserved.
//

import UIKit
import SVProgressHUD

class CreateUserViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var companyTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.continueButton.layer.cornerRadius = 15
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
 
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        
        if ( !ReachabilityHelper.isConnectedToNetworkHelper() ) {
            notConnectedToInternetPopup()
            return
        }
        
        if (nameTextField.text == "" || companyTextField.text == "" || passwordTextField.text == "" || confirmPasswordTextField.text == " ") {
            notFilledOutPopup()
        }
        
        if (self.passwordTextField.text != self.confirmPasswordTextField.text){
            passwordErrorPopup()
            return
        }
        
        
        SVProgressHUD.show()
        AlchemieAPI.shared.createUser(email: nameTextField.text!, company: companyTextField.text!, password: passwordTextField.text!, completion: {
            success  in
            if (success) {
                self.performSegue(withIdentifier: "toConfirm", sender: self)
            }
            else {
                self.loginErrorPopup()
            }
            SVProgressHUD.dismiss()
        })
    }
    
    ///////////
    //
    // MARK: - Notification Center
    //
    ///////////
    
    @objc func keyboardWillHide(noti: Notification) {
        scrollView.contentInset.bottom = 0
    }
    
    @objc func keyboardWillShow(noti: Notification) {
        if let keyboardSize = (noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset.bottom = keyboardSize.height
        }
    }
}
