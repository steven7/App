//
//  CreateItemViewController.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/22/17.
//  Copyright © 2017 steve. All rights reserved.
//

import UIKit

class CreateItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var photoButton: UIButton!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!
    
    var theImage:UIImage?
    let imagePicker = UIImagePickerController()
    
    var createItemCompletion: ((UIImage, String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        theImage = photoButton.backgroundImage(for: .normal)
        self.doneButton.layer.cornerRadius = 15
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func photoButtonPressed(_ sender: Any) {
        /*
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        self.present(self.imagePicker, animated: true, completion: {
            
        })
        */
        let photoAlert = UIAlertController(title: "Photo Source", message: "What is the source of the photo?", preferredStyle: .actionSheet)
        //photoAlert.popoverPresentationController?.sourceView = photoButton
        photoAlert.popoverPresentationController?.sourceView = self.view
        photoAlert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        photoAlert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY - 180, width: 0, height: 0)
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { action in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let cameraAction  = UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        photoAlert.addAction(libraryAction)
        photoAlert.addAction(cameraAction)
        self.present(photoAlert, animated: true, completion: {
            print("done lololz")
        })
    }
    
    
    // MARK: - Image Picker
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //imageView.contentMode = .ScaleAspectFit
            theImage = pickedImage
            //photoButton.imageView?.image = pickedImage
            photoButton.setBackgroundImage(self.theImage, for: .normal)
        } 
        dismiss(animated: true, completion: {
            //self.photoButton.imageView?.image = self.theImage
            //self.photoButton.setBackgroundImage(self.theImage, for: .normal)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        //self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    
    @IBAction func doneButttonPressed(_ sender: Any) {
        var caption = ""
        if let cap = self.titleTextField.text{
            caption = cap
        }
        createItemCompletion!(theImage!, caption)
        self.navigationController?.popViewController(animated: true)
        //self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillHide(noti: Notification) {
        let contentInsets = UIEdgeInsets.zero
        //scrollView.contentInset = contentInsets
        //scrollView.scrollIndicatorInsets = contentInsets
        if let keyboardSize = (noti.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        } 
    }
    
    @objc func keyboardWillShow(noti: Notification) {
        /*
        guard let userInfo = noti.userInfo else { return }
        guard var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset*/
        if let keyboardSize = (noti.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
}
