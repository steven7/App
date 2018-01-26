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
    var questionType:Int?      //"QuestionType": 1
    
    override init(){
        
    }
    
    init (text:String) {
        questionText = text
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
