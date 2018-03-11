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
    var questionSetList = [QuestionSet]() // not in use for now
    var questionList = [Question]()
    
    var numberOfQuestionLists:Int?
    var questionIconImgPointerOne:String?
    var questionIconImgPointerTwo:String?
    var questionIconImgPointerThree:String?
    
    override init() {
        title = ""
        optionID = NSUUID().uuidString
        status = ""
        optionDescription = ""
        type = ""
    }
    
    func printQuestionList(){
        
        if questionList.count == 0 {
            print("no questions in this set")
            return
        }
        
        print(" ---  print question list ---  ")
        //if let qList = questionList {
            for question in questionList {
                print("        \(String(describing: question.questionText!))")
            }
        /*
        }
        else {
            print("no questions in this set")
        }*/
    }
}
