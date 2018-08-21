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
    
    @IBOutlet weak var deleteButton: UIButton!
    
    var theImage:UIImage?
    var editMode = false
    var currentEditItem: Item?
    let imagePicker = UIImagePickerController()
    
    var createItemCompletion: ((UIImage, String) -> ())?
    var editItemCompletion: ((Item, UIImage, String, Bool) -> ())?
    var deleteItemCompletion: ((Item, UIImage, String) -> ())?
    var imageChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        theImage = photoButton.backgroundImage(for: .normal)
        self.doneButton.layer.cornerRadius = 15
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        if (editMode) {
            self.photoButton.setBackgroundImage(currentEditItem?.originalImage, for: .normal)
            self.titleTextField.text = currentEditItem?.caption
            self.doneButton.setTitle("Save Changes", for: .normal)
            self.doneButton.backgroundColor = UIColor.lightGray
            self.deleteButton.layer.cornerRadius = 15
            self.deleteButton.isHidden = false
            self.deleteButton.isUserInteractionEnabled = true
        }
        else {
            self.deleteButton.isHidden = true
            self.deleteButton.isUserInteractionEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func photoButtonPressed(_ sender: Any) {
        
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
            theImage = pickedImage
            photoButton.setBackgroundImage(self.theImage, for: .normal)
            imageChanged = true
        } 
        dismiss(animated: true, completion: {
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
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
        if (editMode) {
            self.currentEditItem?.originalImage = theImage
            self.currentEditItem?.editedImage = nil
            editItemCompletion!(self.currentEditItem!, theImage!, caption, imageChanged)
        }
        else {
            createItemCompletion!(theImage!, caption)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        var caption = ""
        if let cap = self.titleTextField.text{
            caption = cap
        }
        deleteItemCompletion!(self.currentEditItem!, theImage!, caption)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillHide(noti: Notification) {
        let contentInsets = UIEdgeInsets.zero
        if let keyboardSize = (noti.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        } 
    }
    
    @objc func keyboardWillShow(noti: Notification) {
        if let keyboardSize = (noti.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
}
