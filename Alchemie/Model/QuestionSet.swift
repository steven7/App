//
//  QuestionSet.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 1/10/18.
//  Copyright © 2018 steve. All rights reserved.
//

import UIKit

class Answer:NSObject {
    var answerID:String?
    var answerListID:String?
    var answerListitemtext:String?
    var answerListseq:Int?
    
    override init() {
        answerID = " "
        answerListID = " "
        answerListitemtext = " "
        answerListseq = 0
    }
}

class Question: NSObject, Copying {
    var companyNum:Int?     //"CompanyNum": null,
//    var listID:String?         //"ListID": null,
    var optionObjectList:[Answer]?
    var questionNotes:String?  //"QuestionNotes": null,
    //var questionNum:Int?        //"QuestionNum": 1,
    var questionID:String?  // "QuestionSetID": "ac215129-d606-4fe3-813d-da73cb591eae",
    var questionText:String?   //"QuestionText": "Enter some text here:",
    var questionTypeNumber:Int?      //"QuestionType": 1
    var questionType:QuestionTypes?      //"QuestionType": 1
    
    //answer related
    var questionAnswer:String?
    var questionAnswerID:String?
    var imageGuidIfPhotoQuestion:String?
    
    
    var questionNumber:Int?
    var parentQuestionSetID:String?
    
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
    
    required init(original: Question) {
        companyNum = original.companyNum
        optionObjectList = original.optionObjectList
        questionNotes = original.questionNotes
        questionID = original.questionID
        questionText = original.questionText
        questionTypeNumber = original.questionTypeNumber
        questionType = original.questionType
        
        //answer related
        questionAnswer = original.questionAnswer
        questionAnswerID = original.questionAnswerID
        imageGuidIfPhotoQuestion = original.imageGuidIfPhotoQuestion
        
        
        questionNumber = original.questionNumber
        parentQuestionSetID = original.parentQuestionSetID
        
        questionIconPositions = original.questionIconPositions
        questionIconPositionsOne = original.questionIconPositionsOne
        questionIconPositionsTwo = original.questionIconPositionsTwo
        questionIconPositionsThree = original.questionIconPositionsThree
        
    }
    
//    func copy() -> Question {
//        var question = Question()
//        question.questionText = self.questionText
//        question.questionType = self.questionType
//        question.questionAnswer = self.questionAnswer
//        question.questionAnswerID = self.questionAnswerID
//        return
//    }
    
//    func copy() -> Self {
//        return self.init(original: self) as Qu
//    }
    
    var dict:[Int:QuestionTypes] = [ 1 : .text,  2 : .yesOrNo, 3 : .list, 4 : .listMulti, 5 : .photo]
    
    override init(){
        questionText = nil
        questionAnswerID = ""
//        listID = UUID().uuidString
        questionID = UUID().uuidString
        questionText =  ""
        questionTypeNumber = 0
        //answer related
        questionAnswer =  ""
        questionAnswerID =  ""
        imageGuidIfPhotoQuestion =  "" 
        parentQuestionSetID =  ""
    }
    
    
    
    init (text:String) {
        questionText = text
        questionAnswer = ""
        questionAnswerID = ""
//        listID = UUID().uuidString
        questionID = UUID().uuidString
    }
    
    init (text:String, type:Int) {
        questionText = text
        questionType = dict[type]
        questionAnswer = ""
        questionAnswerID = ""
//        listID = UUID().uuidString
        questionID = UUID().uuidString
    }
    
    init (text:String, type:QuestionTypes) {
        questionText = text
        questionType = type
        questionAnswer = ""
        questionAnswerID = ""
//        listID = UUID().uuidString
        questionID = UUID().uuidString
    }
    
    func setType(type:Int) {
        questionTypeNumber = type
        questionType = dict[type]
        questionAnswer = ""
        questionAnswerID = ""
//        listID = UUID().uuidString
        questionID = UUID().uuidString
    }
    
    func getAnswersOptionsObject() -> [Answer] {
        if let optionList = optionObjectList {
            return optionList
        }
        return []
    }
    
    func getAnswersOptions() -> [String] {
        var answerOptions = [String]()
        if let optionList = optionObjectList {
            if optionList.count > 0 {
                for o in optionList {
                    answerOptions.append(o.answerListitemtext!)
                }
            }
            else {
                answerOptions = [ "Option One", "Option Two", "Option Three", "Option Four", "Option Five" ]
            }
        }
        else {
            answerOptions = [ "Option One", "Option Two", "Option Three", "Option Four", "Option Five" ]
        }
        return answerOptions
    }
    
}

class QuestionSet: NSObject {
    
    var companyNum:Int? //"CompanyNum": 0,
    var theID:String? //"ID": "ac215129-d606-4fe3-813d-da73cb591eae",
    var questionList = [Question]()
    var surveyIconImage:UIImage?
    var surveyIconPointer:String?  //"SurveyIcon": null,
    var surveyName:String?  //"SurveyName": "Photo Adventure",
    var surveyType:String?
    var parentOptionID:String?
    
    override init() {
        theID = NSUUID().uuidString
    }
    
    func printQuestionSet(){
        print("companyNum = \(companyNum)")
        print("theID      = \(theID)")
        print("surveyIcon = \(surveyIconPointer)")
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
