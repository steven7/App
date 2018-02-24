//
//  QuestionSet.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 1/10/18.
//  Copyright © 2018 steve. All rights reserved.
//

import UIKit



class Question: NSObject {
    var companyNum:Int?     //"CompanyNum": null,
    var listID:String?         //"ListID": null,
    var optionList:[String]?   //"OptionList": [],
    var questionNotes:String?  //"QuestionNotes": null,
    var questionNum:Int?        //"QuestionNum": 1,
    var questionSetID:String?  // "QuestionSetID": "ac215129-d606-4fe3-813d-da73cb591eae",
    var questionText:String?   //"QuestionText": "Enter some text here:",
    var questionTypeNumber:Int?      //"QuestionType": 1
    var questionType:QuestionTypes?      //"QuestionType": 1
    
    var questionIconPositions:[[CGPoint]]?
    var questionIconPositionsOne:[CGPoint]?
    var questionIconPositionsTwo:[CGPoint]?
    var questionIconPositionsThree:[CGPoint]?
    
    enum QuestionTypes  {
        case text
        case yesOrNo
        case list
        case listMulti
        case photo
        case next
    }
    
    var dict:[Int:QuestionTypes] = [ 1 : .text,  2 : .yesOrNo, 3 : .list, 4 : .listMulti, 5 : .photo]
    
    override init(){
        questionText = nil
    }
    
    init (text:String) {
        questionText = text
    }
    
    init (text:String, type:Int) {
        questionText = text
        questionType = dict[type]
    }
    
    init (text:String, type:QuestionTypes) {
        questionText = text
        questionType = type
    }
    
    func setType(type:Int) {
        questionTypeNumber = type
        questionType = dict[type]
    }
}

class QuestionSet: NSObject {
    
    var companyNum:Int? //"CompanyNum": 0,
    var theID:String? //"ID": "ac215129-d606-4fe3-813d-da73cb591eae",
    var questionList = [Question]()
    var surveyIcon:String?  //"SurveyIcon": null,
    var surveyName:String?  //"SurveyName": "Photo Adventure",
    var surveyType:String?
    
    func printQuestionSet(){
        print("companyNum = \(companyNum)")
        print("theID      = \(theID)")
        print("surveyIcon = \(surveyIcon)")
        print("surveyName = \(surveyName)")
        print("surveyType = \(surveyType)")
    }
    
    func printQuestionList(){
        
        if questionList.count == 0 {
            print("no questions in this set")
            return
        }
        
        for question in questionList {
            print("\(String(describing: question.questionText))")
        }
    }
}
