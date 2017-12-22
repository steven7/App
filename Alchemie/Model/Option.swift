//
//  Option.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/20/17.
//  Copyright © 2017 steve. All rights reserved.
//

import UIKit

class Option: NSObject {

    var user:String?
    var title:String?
    var optionID:String?
    var status:String?
    var optionDescription:String?
    var type:String?
    
    override init() {
        title = ""
        optionID = NSUUID().uuidString
        status = ""
        optionDescription = ""
        type = ""
    }
}
