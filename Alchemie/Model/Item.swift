//
//  Item.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/22/17.
//  Copyright © 2017 steve. All rights reserved.
//

import Foundation
import UIKit

class Item: NSObject {
    
    var originalImage:UIImage?
    var editedImage:UIImage?
    var itemID:String?
    var imgPointer:String?
    var imgUUID:String?
    var editedimgUUID:String?
    var caption:String?
    var parentSubOptionID:String?
    var highlightedBackground:Bool?
    
    var questionIconPositions:[[CGPoint]]?
    var questionIconPositionsOne:[CGPoint]?
    var questionIconPositionsTwo:[CGPoint]?
    var questionIconPositionsThree:[CGPoint]?
    
    override init () {
        originalImage = nil
        editedImage = nil
        itemID = NSUUID().uuidString
        imgPointer = ""
        imgUUID = NSUUID().uuidString
        caption = ""
        parentSubOptionID = ""
        highlightedBackground = false
    }
}
