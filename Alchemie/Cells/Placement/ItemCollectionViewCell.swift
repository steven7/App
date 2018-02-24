//
//  ItemCollectionViewCell.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/20/17.
//  Copyright © 2017 steve. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {

    var theimage:UIImage?
    var theimagePointer:String?
    var thecaption:String?
    
    var highlightedBackground:Bool?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionTextLabel: UILabel!
    
    @IBOutlet weak var theBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.image = theimage
        captionTextLabel.text = thecaption
        highlightedBackground = false
        theBackgroundView.backgroundColor = UIColor.clear
        theBackgroundView.layer.cornerRadius = 15
    }

    func setImagewithCaption( image:UIImage, caption:String){
        imageView.image = image
        captionTextLabel.text = caption
    }
    
    func withItem( item: Item){
        imageView.image = item.originalImage
        captionTextLabel.text = item.caption
    }

}
