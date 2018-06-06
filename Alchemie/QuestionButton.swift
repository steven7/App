//
//  QuestionButton.swift
//  Alchemie
//
//  Created by Steve on 4/14/18.
//  Copyright © 2018 steve. All rights reserved.
//

import UIKit

class QuestionButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

//    var buttonQuestionSet:QuestionSet?
    var buttonQuestions:[Question]?
    var answerType:Question.QuestionTypes?
    var answerTypeNumber:Int?
    var questionSetID:String?
    var buttonInstanceID:String?
    var buttonLocation:CGPoint?
    var answersMap = Dictionary<Int, String>()
    var photoCache = Dictionary<Int, UIImage>()
    
    var buttonTypeNumber:Int?
    
//    func setQuestionSet(questionSet: QuestionSet) {
//        self.buttonQuestionSet = questionSet
//    }
//
//    func getQuestionSet() -> QuestionSet? {
//        return buttonQuestionSet
//    }
//
    
    func getTheAnswersMap() -> Dictionary<Int, String> {
        
        return answersMap
        
    }
    
    func addToAnswerMap(answer:String, key:Int) {
        //answersMap.
        answersMap[key] = answer
        
    }
    
    func getFromAnswersMap(key:Int ) -> String {
//        if (answersMap[key] != nil){
//            return ""
//        }
//        else {
            if let ans = answersMap[key] {
                return ans
            }
            return "" // answersMap[key]!
        // }
    }
    
    func setQuestions(questions: [Question]) {
        //var copiedQuestions:[Question] = questions.map{$0.copy()}
        var copiedQuestions = questions.clone()
        self.buttonQuestions = copiedQuestions
    }
    
    func setLocation(point:CGPoint) {
        self.buttonLocation = point
    }
    
    func getLocation() -> CGPoint {
        return self.buttonLocation!
    }
    
    func setType(typeInt: Int) {
        self.buttonTypeNumber = typeInt
    }
    
    func getType() -> Int? {
        return self.buttonTypeNumber
    }
//    func setQuestions(questions: [Question]) {
//        self.buttonQuestions = questions
//    }
//
    func getQuestions() -> [Question]? {
        return buttonQuestions
    }
    
    func clearAnswers() {
        if let questions = buttonQuestions {
            for question in questions {
                question.questionAnswer = ""
            }
        }
    }
    
    func getButtonID() -> String{
        return self.buttonInstanceID!  
    }
    
    func setRandomID() {
        self.buttonInstanceID = UUID().uuidString
    }
    
    func copyButton() -> QuestionButton {
        let copyButton = QuestionButton(type: .custom)
        copyButton.clearAnswers()
        copyButton.setTitle(self.titleLabel?.text, for: .normal)
        copyButton.titleLabel?.font = UIFont(name: "System", size: 20.0)
        copyButton.setTitleColor(UIColor.lightBlue, for: .normal)
        copyButton.backgroundColor = UIColor.clear
        // copyButton.setBackgroundImage(self.currentBackgroundImage, for: .normal)
        //copyButton.setImage(self.currentImage, for: .normal)
        copyButton.setImage(self.image(for: .normal), for: .normal)
        copyButton.imageView?.layer.cornerRadius = 10
        copyButton.layer.cornerRadius = 10
        copyButton.frame = self.frame
        copyButton.tag = self.tag
        copyButton.setRandomID()
        copyButton.answersMap = Dictionary<Int, String>()
        copyButton.photoCache = Dictionary<Int, UIImage>()
//        copyButton.buttonQuestions = self.buttonQuestions
        //copyButton.frame =
        // CGRect(x: buttonThree.frame.minX, y: buttonThree.frame.minY, width: buttonThree.frame.width, height: buttonThree.frame.height)
        return copyButton
    }
    
    func copyButtonWithAnswers() -> QuestionButton {
        let copyButton = QuestionButton(type: .custom)
        copyButton.setTitle(self.titleLabel?.text, for: .normal)
        copyButton.titleLabel?.font = UIFont(name: "System", size: 20.0)
        copyButton.setTitleColor(UIColor.lightBlue, for: .normal)
        copyButton.backgroundColor = UIColor.clear
        // copyButton.setBackgroundImage(self.currentBackgroundImage, for: .normal)
        //copyButton.setImage(self.currentImage, for: .normal)
        copyButton.setImage(self.image(for: .normal), for: .normal)
        copyButton.imageView?.layer.cornerRadius = 10
        copyButton.layer.cornerRadius = 10
        copyButton.frame = self.frame
        copyButton.tag = self.tag
        copyButton.answersMap = Dictionary<Int, String>()
        copyButton.photoCache = Dictionary<Int, UIImage>()
        //        copyButton.buttonQuestions = self.buttonQuestions
        //copyButton.frame =
        // CGRect(x: buttonThree.frame.minX, y: buttonThree.frame.minY, width: buttonThree.frame.width, height: buttonThree.frame.height)
        return copyButton
    }
}
