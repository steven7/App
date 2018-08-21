//
//  LoginViewController.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/20/17.
//  Copyright © 2017 steve. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftKeychainWrapper

class LoginViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func unwindToLogin(segue:UIStoryboardSegue) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.layer.cornerRadius = 15
        // Do any additional setup after loading the view.
        
        if(checkIfLastLooggedIn()){
            self.performSegue(withIdentifier: "toOptions", sender: self)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
 
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
         self.view.endEditing(true)
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkIfLastLooggedIn() -> Bool{
        let retrievedName: String? = KeychainWrapper.standard.string(forKey: "userName")
        print("Retrieved name is: \(retrievedName)")
        if let name = retrievedName {
            return true
        }
        else {
            print("nil yo")
            return false
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
 
    @IBAction func createUserPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "toCreateUser", sender: self)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        let reach = ReachabilityHelper()
        if  !reach.isConnectedToNetworkHelper()   {
            notConnectedToInternetPopup()
            return
        }
        
        if (nameTextField.text == "" || companyTextField.text == "" || passwordTextField.text == "") {
            notFilledOutPopup()
        }
        
        
        SVProgressHUD.show()
        AlchemieAPI.shared.loginUser(email: nameTextField.text!, company: companyTextField.text!, password: passwordTextField.text!, completion: {
            success  in
            if (success) {
                let saveSuccessful: Bool   = KeychainWrapper.standard.set(self.nameTextField.text!, forKey: "userName")
                let saveSuccessfult: Bool  = KeychainWrapper.standard.set(self.companyTextField.text!, forKey: "userCompany")
                let saveSuccessfultt: Bool = KeychainWrapper.standard.set(self.passwordTextField.text!, forKey: "userPassword")
                print("Save was successful: \(saveSuccessful)  \(saveSuccessfult)  \(saveSuccessfultt) ")
                self.performSegue(withIdentifier: "toOptions", sender: self)
            }
            else {
                self.errorPopup()
            }
            SVProgressHUD.dismiss()
        })
        
    }
    
    //---------------------------------
    // MARK: - Notification Center
    //---------------------------------
    
    @objc func keyboardWillHide(noti: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillShow(noti: Notification) {
        
        guard let userInfo = noti.userInfo else { return }
        guard var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
}
