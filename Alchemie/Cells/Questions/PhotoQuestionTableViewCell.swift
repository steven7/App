//
//  PhotoQuestionTableViewCell.swift
//  Alchemie
//
//  Created by Steve on 1/13/18.
//  Copyright © 2018 steve. All rights reserved.
//

import UIKit

class PhotoQuestionTableViewCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var photoButton: UIButton!
    
    var theImage:UIImage?
    let imagePicker = UIImagePickerController()
    
    var photoClosure:((UIButton)->())?
    
    @IBAction func photoButtonPressed(_ sender: Any) {
        photoClosure!(photoButton)
        /*
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
        })*/
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.photoButton.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Image Picker
    /*
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //imageView.contentMode = .ScaleAspectFit
            theImage = pickedImage
            //photoButton.imageView?.image = pickedImage
            photoButton.setBackgroundImage(self.theImage, for: .normal)
        }
        //dismiss(animated: true, completion: {
            //self.photoButton.imageView?.image = self.theImage
            //self.photoButton.setBackgroundImage(self.theImage, for: .normal)
        //})
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //dismiss(animated: true, completion: nil)
    }
    */
}
