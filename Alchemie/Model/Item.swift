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
    var answerSetID:String?
    var editedimgUUID:String?
    var caption:String?
    var parentSubOptionID:String?
    var highlightedBackground:Bool?
    
    var questionIconPositions:[[CGPoint]]?
    var questionIconPositionsOne:[CGPoint]?
    var questionIconPositionsTwo:[CGPoint]?
    var questionIconPositionsThree:[CGPoint]?
    
    var buttonOnes:[QuestionButton]?
    var buttonTwos:[QuestionButton]?
    var buttonThrees:[QuestionButton]?
    
    override init () {
        originalImage = nil
        editedImage = nil
        itemID = NSUUID().uuidString
        imgPointer = ""
        imgUUID = NSUUID().uuidString
        answerSetID = NSUUID().uuidString
        caption = ""
        parentSubOptionID = ""
        highlightedBackground = false
        buttonOnes = [QuestionButton]()
        buttonTwos = [QuestionButton]()
        buttonThrees = [QuestionButton]()
    }
}
