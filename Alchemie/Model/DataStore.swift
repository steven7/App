//
//  DataStore.swift
//  Alchemie
//
//  Created by Steve on 7/4/18.
//  Copyright © 2018 steve. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataStore: NSObject {
    
    static let shared = DataStore()

    let imageStore = ImageStore.sharedInstance
    
    private override init( ) {
        
    }
    
    func createOptionWithCoreData(with option:Option){
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "CDOption",
                                       in: managedContext)!
        let cdOption = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
        
        cdOption.setValue(option.title, forKeyPath: "title")
        cdOption.setValue(option.optionID, forKeyPath: "optionID")
        cdOption.setValue(option.status, forKeyPath: "status")
        cdOption.setValue(option.optionDescription, forKeyPath: "optionDescription")
        cdOption.setValue(option.type, forKeyPath: "type")
        cdOption.setValue(option.user, forKeyPath: "user")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    
    func createSubOptionWithCoreData(with subOption:SubOption){
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let parentOptionID = subOption.parentOption?.optionID
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDOption")
        
        fetchRequest.predicate = NSPredicate(format: "optionID == %@", parentOptionID!)
        
        do {
            let optionsToUpdate = try managedContext.fetch(fetchRequest)
            let optionToUpdate = optionsToUpdate[0]
            
            let entity = NSEntityDescription.entity(forEntityName: "CDSubOption", in: managedContext)!
            
            let cdSubOption = NSManagedObject(entity: entity,
                                              insertInto: managedContext)
            
            //////////
            if let subID = cdSubOption.value(forKey: "subOptionID") as? String {
                if (subID == subOption.subOptionID) {
                    return
                }
            }
            
            // optionToUpdate.setValue(NSSet(object: newAddress), forKey: "addresses")
            
            cdSubOption.setValue(subOption.name,            forKeyPath: "name")
            cdSubOption.setValue(subOption.city,            forKeyPath: "city")
            cdSubOption.setValue(subOption.country,         forKeyPath: "country")
            cdSubOption.setValue(subOption.street,          forKeyPath: "street")
            cdSubOption.setValue(subOption.subOptionStatus, forKeyPath: "subOptionStatus")
            cdSubOption.setValue(subOption.state,           forKeyPath: "state")
            cdSubOption.setValue(subOption.postalCode,      forKeyPath: "postalCode")
            cdSubOption.setValue(subOption.pocPhone,        forKeyPath: "pocPhone")
            cdSubOption.setValue(subOption.pocName,         forKeyPath: "pocName")
            cdSubOption.setValue(subOption.pocEmail,        forKeyPath: "pocEmail")
            cdSubOption.setValue(subOption.subOptionID,     forKeyPath: "subOptionID")
            cdSubOption.setValue(subOption.parentOptionID,  forKeyPath: "parentOptionID")
            
            optionToUpdate.setValue(NSSet(object: cdSubOption), forKey: "subOptions")
            
            do {
                try managedContext.save()
                //people.append(person)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
    }
    
    func createQuestionListOnOptionWithCoreData(with question:Question, withOption option: Option){
        
        //DispatchQueue.main.async(execute: {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        //})
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let parentOptionID = option.optionID
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "CDOption")
        
        fetchRequest.predicate = NSPredicate(format: "optionID == %@", parentOptionID!)
        
        do {
            let optionsToUpdate = try managedContext.fetch(fetchRequest)
            let optionToUpdate = optionsToUpdate[0]
            
            let entity =
                NSEntityDescription.entity(forEntityName: "CDQuestionList",
                                           in: managedContext)!
            let cdQuestionList = NSManagedObject(entity: entity,
                                                 insertInto: managedContext)
            
            if let questionID = cdQuestionList.value(forKey: "questionSetID") as? String {
                if (questionID == question.questionID!) {
                    return
                }
            }
            
            cdQuestionList.setValue(question.questionText,          forKeyPath: "questionText")
            cdQuestionList.setValue(question.questionID,            forKeyPath: "questionSetID")
            cdQuestionList.setValue(option.optionID,                forKeyPath: "parentOptionID")
            cdQuestionList.setValue(question.parentQuestionSetID,   forKeyPath: "parentQuestionSetID")
            cdQuestionList.setValue(question.questionTypeNumber,    forKeyPath: "questionTypeNumber")
            
            optionToUpdate.setValue(NSSet(object: cdQuestionList), forKey: "questionList")
            
            //            if let optionObjectList = question.optionObjectList {
            //                for oneAnswerOption in optionObjectList {
            //
            //                    let entityList = NSEntityDescription.entity(forEntityName: "CDQuestionAnswerOptions",
            //                    in: managedContext)!
            //                    let CDQuestionAnswerOptions = NSManagedObject(entity: entityList,
            //                                                                  insertInto: managedContext)
            //
            //                    CDQuestionAnswerOptions.setValue(oneAnswerOption.answerID,           forKeyPath: "questionAnswerOptionID")
            //                    CDQuestionAnswerOptions.setValue(oneAnswerOption.answerListID,       forKeyPath: "questionAnswerOptionListID")
            //                    CDQuestionAnswerOptions.setValue(oneAnswerOption.answerListitemtext, forKeyPath: "questionAnswerOptionListitemtext")
            //                    CDQuestionAnswerOptions.setValue(oneAnswerOption.answerListseq,      forKeyPath: "questionAnswerOptionListseq")
            //
            //                    cdQuestionList.setValue(NSSet(object: CDQuestionAnswerOptions), forKey: "answerOptions")
            //
            //                }
            //            }
            
            do {
                try managedContext.save()
                //people.append(person)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    func createQuestionSetOnOptionWithCoreData(with questionSet:QuestionSet, withOption option: Option){
        
        //DispatchQueue.main.async(execute: {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        //})
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let parentOptionID = option.optionID
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "CDOption")
        
        fetchRequest.predicate = NSPredicate(format: "optionID == %@", parentOptionID!)
        
        do {
            
            let optionsToUpdate = try managedContext.fetch(fetchRequest)
            let optionToUpdate = optionsToUpdate[0]
            
            let entity =
                NSEntityDescription.entity(forEntityName: "CDQuestionSet",
                                           in: managedContext)!
            
            let cdQuestionSet = NSManagedObject(entity: entity,
                                                insertInto: managedContext)
            
            if let questionSetID = cdQuestionSet.value(forKey: "questionSetID") as? String {
                if (questionSetID == questionSet.theID) {
                    return
                }
            }
            
            cdQuestionSet.setValue(questionSet.companyNum,           forKeyPath: "companyNum")
            cdQuestionSet.setValue(questionSet.surveyIconPointer,    forKeyPath: "iconImgPointer")
            cdQuestionSet.setValue(questionSet.surveyName,           forKeyPath: "surveyName")
            cdQuestionSet.setValue(questionSet.theID,                forKeyPath:"questionSetID")
            cdQuestionSet.setValue(option.optionID,                  forKeyPath: "parentOptionID")
            
            
            for oneQuestion in questionSet.questionList {
                
                let entityList =
                    NSEntityDescription.entity(forEntityName: "CDQuestionList",
                                               in: managedContext)!
                let cdQuestionList = NSManagedObject(entity: entityList,
                                                     insertInto: managedContext)
                
                
                
                cdQuestionList.setValue(oneQuestion.questionText,     forKeyPath: "questionText")
                cdQuestionList.setValue(oneQuestion.questionID,       forKeyPath: "questionSetID")
                cdQuestionList.setValue(questionSet.theID,            forKeyPath: "parentQuestionSetID")
                cdQuestionList.setValue(option.optionID,              forKeyPath: "parentOptionID")
                cdQuestionList.setValue(oneQuestion.questionTypeNumber,   forKeyPath: "questionTypeNumber")
                cdQuestionList.setValue(oneQuestion.questionNumber,   forKeyPath: "questionNumber")
                
                if let optionObjectList = oneQuestion.optionObjectList {
                    for oneAnswerOption in optionObjectList {
                        
                        let entityList = NSEntityDescription.entity(forEntityName: "CDQuestionAnswerOptions",
                                                                    in: managedContext)!
                        let cdQuestionAnswerOptions = NSManagedObject(entity: entityList,
                                                                      insertInto: managedContext)
                        
                        //cdQuestionList.setValue(oneQuestion.questionAnswerID,   forKeyPath: "questionAnswerOptionID")
                        cdQuestionAnswerOptions.setValue(oneAnswerOption.answerID,           forKeyPath: "questionAnswerOptionID")
                        cdQuestionAnswerOptions.setValue(oneAnswerOption.answerListID,       forKeyPath: "questionAnswerOptionListID")
                        cdQuestionAnswerOptions.setValue(oneAnswerOption.answerListitemtext, forKeyPath: "questionAnswerOptionListitemtext")
                        cdQuestionAnswerOptions.setValue(oneAnswerOption.answerListseq,      forKeyPath: "questionAnswerOptionListseq")
                        
                        // cdQuestionList.setValue(NSSet(object: cdQuestionAnswerOptions), forKey: "answerOptions")
                        
                    }
                }
                
                cdQuestionSet.setValue(NSSet(object: cdQuestionList), forKey: "questionList")
                
            }
            
            /*
             
             let entityList =
             NSEntityDescription.entity(forEntityName: "CDQuestionList",
             in: managedContext)!
             let cdQuestionList = NSManagedObject(entity: entityList,
             insertInto: managedContext)
             
             cdQuestionList.setValue(question.questionText,     forKeyPath: "questionText")
             cdQuestionList.setValue(question.questionSetID,    forKeyPath: "questionSetID")
             cdQuestionList.setValue(option.optionID,           forKeyPath: "parentOptionID")
             
             cdQuestionList.setValue(question.questionTypeNumber,   forKeyPath: "questionTypeNumber")
             
             optionToUpdate.setValue(NSSet(object: cdQuestionList), forKey: "questionList")
             */
            
            optionToUpdate.setValue(NSSet(object: cdQuestionSet), forKey: "questionSet")
            
            do {
                try managedContext.save()
                //people.append(person)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    func addItemToCurrentSubOptionCoreData(item: Item, currentSubOption:SubOption ){
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        let subOptionID = currentSubOption.subOptionID
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "CDSubOption")
        
        fetchRequest.predicate = NSPredicate(format: "subOptionID == %@", subOptionID!)
        
        do {
            
            let subOptionsToUpdate = try managedContext.fetch(fetchRequest)
            let subOptionToUpdate = subOptionsToUpdate[0]
            
            let entity =
                NSEntityDescription.entity(forEntityName: "CDItem",
                                           in: managedContext)!
            let cdItem = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
            
            
            cdItem.setValue(item.caption,            forKeyPath: "caption")
            cdItem.setValue(item.itemID,             forKeyPath: "itemID")
            cdItem.setValue(item.imgUUID,            forKeyPath: "imgUUID")
            cdItem.setValue(item.imgPointer,         forKeyPath: "imgPointer")
            cdItem.setValue(subOptionID,             forKeyPath: "parentSubOptionID")
            //cdItem.setValue(item.parentSubOptionID,  forKeyPath: "parentSubOptionID")
            
            imageStore.setImage(item.originalImage!, forKey: item.imgUUID!)
            
            let set = NSSet(object: cdItem)
            
            subOptionToUpdate.setValue(set, forKey: "items")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        } 
    }
    
    func addItemToCurrentSubOptionCoreData(subOption: SubOption, item: Item ){
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        let subOptionID = subOption.subOptionID
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "CDSubOption")
        
        fetchRequest.predicate = NSPredicate(format: "subOptionID == %@", subOptionID!)
        
        do {
            
            let subOptionsToUpdate = try managedContext.fetch(fetchRequest)
            let subOptionToUpdate = subOptionsToUpdate[0]
            
            let entity =
                NSEntityDescription.entity(forEntityName: "CDItem",
                                           in: managedContext)!
            let cdItem = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
            
            
            
            if let itemID = cdItem.value(forKey: "itemID") as? String {
                if (itemID == item.itemID) {
                    return
                }
            }
            
            cdItem.setValue(item.itemID,             forKeyPath: "itemID")
            cdItem.setValue(item.caption,            forKeyPath: "caption")
            cdItem.setValue(item.imgUUID,            forKeyPath: "imgUUID")
            cdItem.setValue(item.imgPointer,         forKeyPath: "imgPointer")
            cdItem.setValue(item.parentSubOptionID,  forKeyPath: "parentSubOptionID")
            
            // fix this
            imageStore.setImage(item.originalImage!, forKey: item.imgUUID!)
            
            let set = NSSet(object: cdItem)
            
            subOptionToUpdate.setValue(set, forKey: "items")
            
            do {
                try managedContext.save()
                //people.append(person)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
    }
    
    ///////
    //
    // fetch from core data
    //
    ///////
    
    func fetchOptionsFromCoreData(forUsername: String) -> [AnyObject] {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return []
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "CDOption")
        
        fetchRequest.predicate = NSPredicate(format: "user == %@", forUsername)
        
        var theOptions = [AnyObject]()
        var theManagedOptions = [NSManagedObject]()
        do {
            theManagedOptions = try managedContext.fetch(fetchRequest)
            for oneManagedOption in theManagedOptions {
                let oneOption = Option()
                oneOption.title = oneManagedOption.value(forKeyPath: "title") as? String
                oneOption.user = oneManagedOption.value(forKeyPath: "user") as? String
                oneOption.optionID = oneManagedOption.value(forKeyPath: "optionID") as? String
                oneOption.status = oneManagedOption.value(forKeyPath: "status") as? String
                oneOption.optionDescription = oneManagedOption.value(forKeyPath: "optionDescription") as? String
                oneOption.type = oneManagedOption.value(forKeyPath: "type") as? String
                oneOption.questionIconImgPointerOne = oneManagedOption.value(forKeyPath: "questionIconImgPointerOne") as? String
                oneOption.questionIconImgPointerTwo = oneManagedOption.value(forKeyPath: "questionIconImgPointerTwo") as? String
                oneOption.questionIconImgPointerThree = oneManagedOption.value(forKeyPath: "questionIconImgPointerThree") as? String
                
                
                
                // get questions
                //                let questionfetchRequest =
                //                    NSFetchRequest<NSManagedObject>(entityName: "CDQuestionList")
                //
                //                questionfetchRequest.predicate = NSPredicate(format: "parentOptionID == %@", oneOption.optionID!)
                //
                // get question sets
                let questionSetfetchRequest =
                    NSFetchRequest<NSManagedObject>(entityName: "CDQuestionSet")
                
                questionSetfetchRequest.predicate = NSPredicate(format: "parentOptionID == %@", oneOption.optionID!)
                
                
                do {
                    /////
                    
                    let theManaged_QuestionSets = try managedContext.fetch(questionSetfetchRequest)
                    var questionsetSet = Set<String>()
                    for oneQuestionSet in theManaged_QuestionSets {
                        
                        let questionSet = QuestionSet()
                        questionSet.companyNum  = oneQuestionSet.value(forKeyPath: "companyNum") as? Int
                        questionSet.surveyIconPointer   = oneQuestionSet.value(forKeyPath: "iconImgPointer") as? String
                        questionSet.surveyName  = oneQuestionSet.value(forKeyPath: "surveyName") as? String
                        questionSet.theID = oneQuestionSet.value(forKeyPath: "questionSetID") as? String
                        questionSet.parentOptionID   = oneQuestionSet.value(forKeyPath: "parentOptionID") as? String
                        
                        if (questionsetSet.contains(questionSet.theID!)) {
                            continue
                        }
                        else {
                            questionsetSet.insert(questionSet.theID!)
                        }
                        
                        // get questions
                        let questionfetchRequest =
                            NSFetchRequest<NSManagedObject>(entityName: "CDQuestionList")
                        
                        questionfetchRequest.predicate = NSPredicate(format: "parentQuestionSetID == %@", questionSet.theID!)
                        
                        
                        let theManaged_Questions = try managedContext.fetch(questionfetchRequest)
                        var oneQuestionSet = Set<String>()
                        
                        // oneQuestion = question set? // q in qsets
                        for oneQuestion in theManaged_Questions {
                            
                            let question = Question()
                            question.questionID  = oneQuestion.value(forKeyPath: "questionSetID") as? String // question id not actually the set id
                            question.questionText   = oneQuestion.value(forKeyPath: "questionText") as? String
                            question.questionAnswer = oneQuestion.value(forKeyPath: "questionAnswer") as? String
                            question.questionNumber = oneQuestion.value(forKeyPath: "questionNumber") as? Int
                            question.parentQuestionSetID = oneQuestion.value(forKeyPath: "parentQuestionSetID") as? String
                            if (oneQuestionSet.contains(question.questionID!) || oneQuestionSet.contains(question.questionText!)) {
                                continue
                            }
                            else {
                                oneQuestionSet.insert(question.questionID!)
                                oneQuestionSet.insert(question.questionText!)
                            }
                            if let qTypeNumber   = oneQuestion.value(forKeyPath: "questionTypeNumber") as? Int {
                                question.setType(type: qTypeNumber)
                                if (qTypeNumber == 3 || qTypeNumber == 4) {
                                    var theAnswerOptions = [Answer]()
                                    let questionOptionsfetchRequest =
                                        NSFetchRequest<NSManagedObject>(entityName: "CDQuestionAnswerOptions")
                                    let theManaged_QuestionOptions = try managedContext.fetch(questionOptionsfetchRequest)
                                    var oneAnswerOptionSet = Set<String>()
                                    var oneAnswerOptionTextSet = Set<String>()
                                    var oneAnswerOptionListSet = Set<String>()
                                    for oneAnswer in theManaged_QuestionOptions {
                                        let answerOption = Answer()
                                        answerOption.answerID = oneAnswer.value(forKeyPath: "questionAnswerOptionID") as? String
                                        answerOption.answerListID = oneAnswer.value(forKeyPath: "questionAnswerOptionListID") as? String
                                        answerOption.answerListitemtext = oneAnswer.value(forKeyPath: "questionAnswerOptionListitemtext") as? String
                                        answerOption.answerListseq = oneAnswer.value(forKeyPath: "questionAnswerOptionListseq") as? Int
                                        if (oneAnswerOptionSet.contains(answerOption.answerID!) && oneAnswerOptionTextSet.contains(answerOption.answerListitemtext!)
                                            && oneAnswerOptionListSet.contains(answerOption.answerListID!)) {
                                            continue
                                        }
                                        else {
                                            oneAnswerOptionSet.insert(answerOption.answerID!)
                                            oneAnswerOptionTextSet.insert(answerOption.answerListitemtext!)
                                            oneAnswerOptionListSet.insert(answerOption.answerListID!)
                                        }
                                        theAnswerOptions.append(answerOption)
                                    }
                                    question.optionObjectList = theAnswerOptions
                                }
                            }
                            else {
                                question.setType(type: 1)
                            }
                            oneOption.questionList.append(question)
                            
                            
                            
                            
                            // if
                            if let dataOne = oneQuestion.value(forKey: "questionIconPositionsOne") as? Data {
                                let unarchiveObjectOne = NSKeyedUnarchiver.unarchiveObject(with: dataOne)
                                let arrayObjectOne = unarchiveObjectOne as AnyObject? as! [CGPoint]
                                question.questionIconPositionsOne = arrayObjectOne
                                
                                
                                
                            }
                            else {
                                question.questionIconPositionsOne = [CGPoint]()
                            }
                            
                            if let dataTwo = oneQuestion.value(forKey: "questionIconPositionsTwo") as? Data {
                                let unarchiveObjectTwo = NSKeyedUnarchiver.unarchiveObject(with: dataTwo)
                                let arrayObjectTwo = unarchiveObjectTwo as AnyObject? as! [CGPoint]
                                question.questionIconPositionsTwo = arrayObjectTwo
                            }
                            else {
                                question.questionIconPositionsTwo = [CGPoint]()
                            }
                            
                            if let dataThree = oneQuestion.value(forKey: "questionIconPositionsThree") as? Data {
                                let unarchiveObjectThree = NSKeyedUnarchiver.unarchiveObject(with: dataThree)
                                let arrayObjectThree = unarchiveObjectThree as AnyObject? as! [CGPoint]
                                question.questionIconPositionsThree = arrayObjectThree
                            }
                            else {
                                question.questionIconPositionsThree = [CGPoint]()
                            }
                            
                            
                            
                            
                            questionSet.questionList.append(question)
                            //                            questionSet.questionList.sort({
                            //                                $0.q
                            //                            })
                            
                            questionSet.questionList.sort(by: {
                                $0.questionNumber! < $1.questionNumber!
                            })
                        }
                        
                        
                        oneOption.questionSetList.append(questionSet)
                    }
                    
                    /////
                    
                    
                    //                    // asigns to question list and not the question set
                    //                    // will probably take out
                    //                    let theManaged_Questions = try managedContext.fetch(questionfetchRequest)
                    //                    var numOfQuestionLists = 0
                    //                    for oneQuestion in theManaged_Questions {
                    //                        let question = Question()
                    //                        question.questionID  = oneQuestion.value(forKeyPath: "questionSetID") as? String
                    //                        question.questionText   = oneQuestion.value(forKeyPath: "questionText") as? String
                    //                        if let qTypeNumber   = oneQuestion.value(forKeyPath: "questionTypeNumber") as? Int {
                    //                            question.setType(type: qTypeNumber)
                    //                        }
                    //                        else {
                    //                            question.setType(type: 1)
                    //                        }
                    //                        oneOption.questionList.append(question)
                    //
                    //                        // if
                    //                         if let dataOne = oneQuestion.value(forKey: "questionIconPositionsOne") as? Data {
                    //                            let unarchiveObjectOne = NSKeyedUnarchiver.unarchiveObject(with: dataOne)
                    //                            let arrayObjectOne = unarchiveObjectOne as AnyObject! as! [CGPoint]
                    //                            question.questionIconPositionsOne = arrayObjectOne
                    //                        }
                    //                        else {
                    //                            question.questionIconPositionsOne = [CGPoint]()
                    //                        }
                    //
                    //                        if let dataTwo = oneQuestion.value(forKey: "questionIconPositionsTwo") as? Data {
                    //                            let unarchiveObjectTwo = NSKeyedUnarchiver.unarchiveObject(with: dataTwo)
                    //                            let arrayObjectTwo = unarchiveObjectTwo as AnyObject! as! [CGPoint]
                    //                            question.questionIconPositionsTwo = arrayObjectTwo
                    //                        }
                    //                        else {
                    //                            question.questionIconPositionsTwo = [CGPoint]()
                    //                        }
                    //
                    //                        if let dataThree = oneQuestion.value(forKey: "questionIconPositionsThree") as? Data {
                    //                            let unarchiveObjectThree = NSKeyedUnarchiver.unarchiveObject(with: dataThree)
                    //                            let arrayObjectThree = unarchiveObjectThree as AnyObject! as! [CGPoint]
                    //                            question.questionIconPositionsThree = arrayObjectThree
                    //                        }
                    //                        else {
                    //                            question.questionIconPositionsThree = [CGPoint]()
                    //                        }
                    //
                    //                        //questionIconPositions = oneQuestion.value(forKeyPath:
                    //
                    //                        numOfQuestionLists  += 1
                    //                    }
                    //
                    //                    oneOption.numberOfQuestionLists = numOfQuestionLists
                    //
                    theOptions.append(oneOption)
                    
                    
                    // sub options
                    
                    // get sub options
                    let subfetchRequest =
                        NSFetchRequest<NSManagedObject>(entityName: "CDSubOption")
                    
                    subfetchRequest.predicate = NSPredicate(format: "parentOptionID == %@", oneOption.optionID!)
                    
                    
                    let theManaged_SubOptions = try managedContext.fetch(subfetchRequest)
                    var subOptionIdSet = Set<String>()
                    for oneManaged_SubOption in theManaged_SubOptions {
                        let oneSubOption = SubOption()
                        oneSubOption.subOptionID = oneManaged_SubOption.value(forKeyPath: "subOptionID") as? String
                        if (subOptionIdSet.contains(oneSubOption.subOptionID!)){
                            print("dupe found")
                            continue
                        }
                        else {
                            subOptionIdSet.insert(oneSubOption.subOptionID!)
                        }
                        oneSubOption.name = oneManaged_SubOption.value(forKeyPath: "name") as? String
                        oneSubOption.city = oneManaged_SubOption.value(forKeyPath: "city") as? String
                        oneSubOption.country = oneManaged_SubOption.value(forKeyPath: "country") as? String
                        oneSubOption.street = oneManaged_SubOption.value(forKeyPath: "street") as? String
                        oneSubOption.subOptionStatus = oneManaged_SubOption.value(forKeyPath: "subOptionStatus") as? String
                        oneSubOption.state = oneManaged_SubOption.value(forKeyPath: "state") as? String
                        oneSubOption.postalCode = oneManaged_SubOption.value(forKeyPath: "postalCode") as? String
                        oneSubOption.pocPhone = oneManaged_SubOption.value(forKeyPath: "pocPhone") as? String
                        oneSubOption.pocName = oneManaged_SubOption.value(forKeyPath: "pocName") as? String
                        oneSubOption.pocEmail = oneManaged_SubOption.value(forKeyPath: "pocEmail") as? String
                        oneSubOption.parentOptionID = oneManaged_SubOption.value(forKeyPath: "parentOptionID") as? String
                        oneSubOption.parentOption = oneOption
                        for subOption in theOptions {
                            let s = subOption as? SubOption
                            if (s?.subOptionID == oneSubOption.subOptionID) {
                                continue
                            }
                        }
                        theOptions.append(oneSubOption)
                    }
                }
                catch  let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
                
                theOptions.append(CreateSubOption(withParent: oneOption))
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return theOptions
    }
    
    
    func fetchItemsFromCoreData(currentSubOption: SubOption) -> [AnyObject] {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return []
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "CDItem")
        
        let subOptionID = currentSubOption.subOptionID
        
        fetchRequest.predicate = NSPredicate(format: "parentSubOptionID == %@", subOptionID!)
        
        var theItems = [AnyObject]()
        var theManagedItems = [NSManagedObject]()
        
        do {
            
            theManagedItems = try managedContext.fetch(fetchRequest)
            print("begin fetch")
            
            var itemIdSet = Set<String>()
            
            for oneManagedItem in theManagedItems {
                let oneItem = Item()
                oneItem.itemID   = oneManagedItem.value(forKeyPath: "itemID")   as? String
                if (itemIdSet.contains(oneItem.itemID!)){
                    print("dupe found")
                    continue
                }
                else {
                    itemIdSet.insert(oneItem.itemID!)
                }
                oneItem.caption    = oneManagedItem .value(forKeyPath: "caption") as? String
                oneItem.imgUUID    = oneManagedItem .value(forKeyPath: "imgUUID") as? String
                oneItem.imgPointer = oneManagedItem .value(forKeyPath: "imgPointer") as? String
                oneItem.editedimgUUID = oneManagedItem.value(forKeyPath: "editedimgPointer") as? String
                //oneItem.questionIconPositionsThree = oneManagedItem.value( forKeyPath: "questionIconPositionsThree") as? String
                
                if let dataOne = oneManagedItem.value(forKey: "questionIconPositionsOne") as? Data {
                    let unarchiveObjectOne = NSKeyedUnarchiver.unarchiveObject(with: dataOne)
                    let arrayObjectOne = unarchiveObjectOne as AnyObject! as! [CGPoint]
                    oneItem.questionIconPositionsOne = arrayObjectOne
                }
                else {
                    oneItem.questionIconPositionsOne = [CGPoint]()
                }
                
                if let dataTwo = oneManagedItem.value(forKey: "questionIconPositionsTwo") as? Data {
                    let unarchiveObjectTwo = NSKeyedUnarchiver.unarchiveObject(with: dataTwo)
                    let arrayObjectTwo = unarchiveObjectTwo as AnyObject! as! [CGPoint]
                    oneItem.questionIconPositionsTwo = arrayObjectTwo
                }
                else {
                    oneItem.questionIconPositionsTwo = [CGPoint]()
                }
                
                if let dataThree = oneManagedItem.value(forKey: "questionIconPositionsThree") as? Data {
                    let unarchiveObjectThree = NSKeyedUnarchiver.unarchiveObject(with: dataThree)
                    let arrayObjectThree = unarchiveObjectThree as AnyObject! as! [CGPoint]
                    oneItem.questionIconPositionsThree = arrayObjectThree
                }
                else {
                    oneItem.questionIconPositionsThree = [CGPoint]()
                }
                
                ///
                ///
                ///
                let questionInstancefetchRequest =
                    NSFetchRequest<NSManagedObject>(entityName: "CDQuestionListInstance")
                
                questionInstancefetchRequest.predicate = NSPredicate(format: "parentItemID == %@", oneItem.itemID!)
                
                var theManagedInstances = try managedContext.fetch(questionInstancefetchRequest)
                
                var buttonIdSet = Set<String>()
                
                for instance in theManagedInstances {
                    
                    let oneButton = QuestionButton()
                    
                    oneButton.buttonInstanceID = instance.value(forKeyPath: "questionInstanceID") as? String
                    
                    if (buttonIdSet.contains(oneButton.buttonInstanceID!)){
                        print("dupe found")
                        continue
                    }
                    else {
                        buttonIdSet.insert(oneButton.buttonInstanceID!)
                    }
                    
                    oneButton.questionSetID    = instance.value(forKeyPath: "questionSetID") as? String
                    oneButton.buttonTypeNumber = instance.value(forKeyPath: "questionInstanceType") as? Int
                    oneButton.timeAnswered     = instance.value(forKeyPath: "timeAnswered") as? String
                    
                    if let dataPoint = instance.value(forKey: "buttonCenterPoint") as? Data {
                        let unarchiveObjectThree = NSKeyedUnarchiver.unarchiveObject(with: dataPoint)
                        let point = unarchiveObjectThree as AnyObject? as! CGPoint
                        oneButton.setLocation(point: point)
                    }
                    else {
                        oneButton.setLocation(point: CGPoint())
                    }
                    
                    if (oneButton.buttonTypeNumber == 0) {
                        oneItem.buttonOnes?.append(oneButton)
                    }
                    else if (oneButton.buttonTypeNumber == 1) {
                        oneItem.buttonTwos?.append(oneButton)
                    }
                    else if (oneButton.buttonTypeNumber == 2) {
                        oneItem.buttonThrees?.append(oneButton)
                    }
                    
                    let questionInstanceAnswerfetchRequest =
                        NSFetchRequest<NSManagedObject>(entityName: "CDQuestionAnswer")
                    
                    questionInstancefetchRequest.predicate = NSPredicate(format: "parentButtonID == %@", oneButton.buttonInstanceID!)
                    
                    let theAnswers = try managedContext.fetch(questionInstanceAnswerfetchRequest)
                    
                    
                    for oneAnswer in theAnswers {
                        
                        
                        let text = oneAnswer.value(forKeyPath: "questionAnswerText") as? String
                        let number = oneAnswer.value(forKeyPath: "questionNumber") as? Int
                        
                        print("loading \(text) with \(number) from \(oneButton.buttonInstanceID!)")
                        
                        oneButton.addToAnswerMap(answer: text!, key: number!)
                        
                        //                        let answer = Answer()
                        //                        answer.answerID = theAnswers.value(forKeyPath: "caption") as? String
                        //                        answer.answerListitemtext = theAnswers.value(forKeyPath: "caption") as? String
                        //
                        //                        cdQuestionListAnswer.setValue(oneQuestion.questionAnswer,     forKeyPath: "")
                        //                        cdQuestionListAnswer.setValue(oneQuestion.questionNumber,     forKeyPath: "")
                        //                        let index =
                        
                        //oneButton.getQuestions()
                        
                        //                        answer.= theAnswers.value(forKeyPath: "caption") as? String
                        //                        answer.= theAnswers.value(forKeyPath: "caption") as? String
                        //                        answer.= theAnswers.value(forKeyPath: "caption") as? String
                        //                        answer.= theAnswers.value(forKeyPath: "caption") as? String
                        //
                        //                        cdQuestionListAnswer.setValue(self.currentButton?.buttonInstanceID!,     forKeyPath: "parentButtonID")
                        //                        cdQuestionListAnswer.setValue(oneQuestion.parentQuestionSetID,     forKeyPath: "parentQuestionSetID")
                        //                        cdQuestionListAnswer.setValue(oneQuestion.questionAnswer,     forKeyPath: "questionAnswerText")
                        //                        cdQuestionListAnswer.setValue(oneQuestion.questionNumber,     forKeyPath: "questionNumber")
                        //                        cdQuestionListAnswer.setValue(oneQuestion.questionTypeNumber,     forKeyPath: "questionTypeNumber")
                    }
                    
                    //                    oneButton = oneManagedItem.value(forKeyPath: "editedimgPointer") as? String
                    //
                    
                    //cdQuestionInstance.setValue(parentItemID, forKey: "parentItemID")
                    //cdQuestionInstance.setValue(id, forKey: "questionInstanceID")
                    //cdQuestionInstance.setValue(centerData, forKey: "buttonCenterPoint")
                    //cdQuestionInstance.setValue(qsetID, forKey: "questionSetID")
                    //cdQuestionInstance.setValue(type, forKey: "questionInstanceType")
                }
                
                ////
                ////
                ////
                
                oneItem.originalImage = imageStore.image(forKey: oneItem.imgUUID!)
                if let editedImageID = oneItem.editedimgUUID {
                    oneItem.editedImage = imageStore.image(forKey: editedImageID)
                }
                else {
                    oneItem.editedImage = nil
                }
                
                print("one item!!")
                print("  -  \(oneItem.caption)")
                print("  -  \(oneItem.imgUUID)")
                print("  -  \(oneItem.originalImage)")
                
                theItems.append(oneItem)
                
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        theItems.append(CreateItem())
        
        return theItems
    }
    
    
    
    ////////
    //
    //
    ////////
    
//    func getQuestionAnswers(question:Question, forSetID: String, instance: Int) {
//
//        let fetchRequest =
//            NSFetchRequest<NSManagedObject>(entityName: "CDQuestionAnswer")
//
//        let questionSetID = NSPredicate(format: "parentQuestionSetID == %@", forSetID)
//        let instanceID = NSPredicate(format: "parentIconNumber == %@", instance)
//        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [questionSetID, instanceID])
//
//        fetchRequest.predicate = andPredicate
//
//        var theOptions = [AnyObject]()
//        var theManagedOptions = [NSManagedObject]()
//        do {
//            let theManagedAnswers = try self.managedContext.fetch(fetchRequest)
//            for oneManagedAnswer in theManagedAnswers {
//            }
//        }
//        catch  let error as NSError {
//            print("Could not get answer. \(error), \(error.userInfo)")
//        }
//    }
    
    
    func eraseOptionsFromCoreDataWithCurrentUser(currentUserName: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        var managedContext =  NSManagedObjectContext()
        managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "CDOption")
        
        fetchRequest.predicate = NSPredicate(format: "user == %@", currentUserName)
        
        do {
            let theManagedOptions = try managedContext.fetch(fetchRequest)
            
            for oneManagedOption in theManagedOptions {
                
                let optionID = oneManagedOption.value(forKeyPath: "optionID") as? String
                
                let subfetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDSubOption")
                subfetchRequest.predicate = NSPredicate(format: "parentOptionID == %@", optionID!)
                
                let theManagedSubOptions = try managedContext.fetch(subfetchRequest)
                
                for sub in theManagedSubOptions {
                    
                    let itemRequest = NSFetchRequest<NSManagedObject>(entityName: "CDItem")
                    itemRequest.predicate = NSPredicate(format: "parentSubOptionID == %@", optionID!)
                    let theManagedItems = try managedContext.fetch(itemRequest)
                    for i in theManagedItems {
                        managedContext.delete(i)
                    }
                    
                    managedContext.delete(sub)
                }
                
                let quesfetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDQuestionList")
                quesfetchRequest.predicate = NSPredicate(format: "parentOptionID == %@", optionID!)
                let theManagedQuestions = try managedContext.fetch(subfetchRequest)
                for q in theManagedQuestions {
                    managedContext.delete(q)
                }
                
                let squesfetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDQuestionSet")
                squesfetchRequest.predicate = NSPredicate(format: "parentOptionID == %@", optionID!)
                let theManagedQuestionSets = try managedContext.fetch(subfetchRequest)
                for q in theManagedQuestions {
                    managedContext.delete(q)
                }
                
                managedContext.delete(oneManagedOption)
            }
            
            appDelegate.saveContext()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    
    func saveButtonPositionsToCoreData(buttonOnes:[QuestionButton], buttonTwos:[QuestionButton], buttonThrees:[QuestionButton], currentItem: Item ) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let currentItemId = currentItem.itemID
        
        do {
            
            let itemfetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDItem")
            
            itemfetchRequest.predicate = NSPredicate(format: "itemID == %@", currentItemId!)
            
            let themanaged_Items = try managedContext.fetch(itemfetchRequest)
            
            let onemanaged_Item = themanaged_Items[0]
            
            
            var buttonIDSet = Set<String>()
            for button in buttonOnes {
                
                let entity = NSEntityDescription.entity(forEntityName: "CDQuestionListInstance", in: managedContext)!
                
                let cdQuestionInstance = NSManagedObject(entity: entity,
                                                         insertInto: managedContext)
                
                let id = button.getButtonID()
                if(buttonIDSet.contains(id)){
                    continue
                }
                else {
                    buttonIDSet.insert(id)
                }
                let parentItemID = currentItem.itemID
                let center = button.getLocation()
                let centerData = NSKeyedArchiver.archivedData(withRootObject: center)
                let qsetID = button.questionSetID
                let type = 0
                
                cdQuestionInstance.setValue(parentItemID, forKey: "parentItemID")
                cdQuestionInstance.setValue(id, forKey: "questionInstanceID")
                cdQuestionInstance.setValue(centerData, forKey: "buttonCenterPoint")
                cdQuestionInstance.setValue(qsetID, forKey: "questionSetID")
                cdQuestionInstance.setValue(type, forKey: "questionInstanceType")
                
                onemanaged_Item.setValue(NSSet(object: cdQuestionInstance), forKey: "questionListInstance")
                
            }
            
            for button in buttonTwos {
                
                let entity = NSEntityDescription.entity(forEntityName: "CDQuestionListInstance", in: managedContext)!
                
                let cdQuestionInstance = NSManagedObject(entity: entity,
                                                         insertInto: managedContext)
                
                let id = button.getButtonID()
                if(buttonIDSet.contains(id)){
                    continue
                }
                else {
                    buttonIDSet.insert(id)
                }
                let parentItemID = currentItem.itemID
                let center = button.getLocation()
                let centerData = NSKeyedArchiver.archivedData(withRootObject: center)
                let qsetID = button.questionSetID
                let type = 1
                
                cdQuestionInstance.setValue(parentItemID, forKey: "parentItemID")
                cdQuestionInstance.setValue(id, forKey: "questionInstanceID")
                cdQuestionInstance.setValue(centerData, forKey: "buttonCenterPoint")
                cdQuestionInstance.setValue(qsetID, forKey: "questionSetID")
                cdQuestionInstance.setValue(type, forKey: "questionInstanceType")
                
                onemanaged_Item.setValue(NSSet(object: cdQuestionInstance), forKey: "questionListInstance")
            }
            
            for button in buttonThrees {
                
                let entity = NSEntityDescription.entity(forEntityName: "CDQuestionListInstance", in: managedContext)!
                
                let cdQuestionInstance = NSManagedObject(entity: entity,
                                                         insertInto: managedContext)
                
                let id = button.getButtonID()
                if(buttonIDSet.contains(id)){
                    continue
                }
                else {
                    buttonIDSet.insert(id)
                }
                let parentItemID = currentItem.itemID
                let center = button.getLocation()
                let centerData = NSKeyedArchiver.archivedData(withRootObject: center)
                let qsetID = button.questionSetID
                let type = 2 // button.getType()
                cdQuestionInstance.setValue(parentItemID, forKey: "parentItemID")
                cdQuestionInstance.setValue(id, forKey: "questionInstanceID")
                cdQuestionInstance.setValue(centerData, forKey: "buttonCenterPoint")
                cdQuestionInstance.setValue(qsetID, forKey: "questionSetID")
                cdQuestionInstance.setValue(type, forKey: "questionInstanceType")
                onemanaged_Item.setValue(NSSet(object: cdQuestionInstance), forKey: "questionListInstance")
            }
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
}
