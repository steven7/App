//
//  CreateSubOption.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/20/17.
//  Copyright © 2017 steve. All rights reserved.
//

import UIKit

class CreateSubOption: NSObject {
    
    var parentOption:Option?
    
    
    init(withParent option:Option) {
        self.parentOption = option
    }
}
