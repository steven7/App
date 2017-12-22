//
//  SubOption.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/20/17.
//  Copyright © 2017 steve. All rights reserved.
//

import UIKit

class SubOption: NSObject {
    // var title:String?
    var name:String?
    var city:String?
    var country:String?
    var street:String?
    var subOptionStatus:String?
    var state:String?
    var postalCode:String?
    var pocPhone:String?
    var pocName:String?
    var pocEmail:String?
    
    var subOptionID:String?
    var parentOptionID:String?
    var parentOption:Option?
    
    var itemList = [Item]()
    
    override init (){
        country = ""
        name = ""
        street = ""
        subOptionStatus = ""
        state = ""
        postalCode = ""
        pocPhone = ""
        pocName = ""
        pocEmail = ""
        subOptionID = NSUUID().uuidString
        parentOptionID = ""
        parentOption = nil
    }
    
    init (withParent option:Option){
        country = ""
        name = ""
        street = ""
        subOptionStatus = ""
        state = ""
        postalCode = ""
        pocPhone = ""
        pocName = ""
        pocEmail = ""
        subOptionID = NSUUID().uuidString
        parentOptionID = ""
        parentOption = nil
    }
}
