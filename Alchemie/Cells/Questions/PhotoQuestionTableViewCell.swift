//
//  PhotoQuestionTableViewCell.swift
//  Alchemie
//
//  Created by Steve on 1/13/18.
//  Copyright © 2018 steve. All rights reserved.
//

import UIKit

class PhotoQuestionTableViewCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var questionNumber: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var photoButton: UIButton!
    
    var theImage:UIImage?
    let imagePicker = UIImagePickerController()
    
    //var photoClosure:((UIButton)->())?
    
    var photoClosure:((UIButton, Int, Int)->())?
    
    var row:Int?
    var currentQuestionNumber:Int?
    
    @IBAction func photoButtonPressed(_ sender: Any) {
        // photoClosure!(photoButton)
        photoClosure!(photoButton, row!, currentQuestionNumber!)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.photoButton.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getAnswer() -> String {
        if (photoButton.currentBackgroundImage != nil) {
            return "photo"
        }
        else {
            return UUID().uuidString
        }
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
