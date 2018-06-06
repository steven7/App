////
//  OptionsViewController.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/20/17.
//  Copyright © 2017 steve. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD
import SwiftKeychainWrapper
import Alamofire
import AlamofireImage

class OptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lastSyncedText: UITextView!
    
    @IBOutlet weak var syncButton: UIButton!
    
    var options = [AnyObject]() // actually contains the cells for the table view + option data
    var questions = [QuestionSet]()
    //NSMutableArray()
    //[Option]()
    //var options = [NSManagedObject]()
    
    var currentUserName:String?
    var currentOption:Option?
    var currentSubOption:SubOption?
    var currentOptionTitle:String?
    var currentSubOptionTitle:String?
    
    var optionsLoaded = false
    var questionsLoaded = false
    
    let imageStore = ImageStore.sharedInstance
    var managedContext =  NSManagedObjectContext()
    
    let operationQueue = OperationQueue()
    
    let baseDownloadImageURL = "http://alchemiewebservice20171213043804.azurewebsites.net/service1.svc/downloadimage/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let oNib = UINib(nibName: "OptionTableViewCell", bundle: nil)
        tableView.register(oNib, forCellReuseIdentifier: "optionCell")
        
        let sNib = UINib(nibName: "SubOptionTableViewCell", bundle: nil)
        tableView.register(sNib, forCellReuseIdentifier: "subOptionCell")
        
        let addNib = UINib(nibName: "CreateOptionTableViewCell", bundle: nil)
        tableView.register(addNib, forCellReuseIdentifier: "createOptionCell")
        
        let addSubNib = UINib(nibName: "CreateSubOptionTableViewCell", bundle: nil)
        tableView.register(addSubNib, forCellReuseIdentifier: "createSubOptionCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.syncButton.layer.cornerRadius = 15
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // self.currentUserName = "e@e.com" //appDelegate.currentUserName
        
        self.currentUserName = KeychainWrapper.standard.string(forKey: "userName")
            //appDelegate.currentUserName
        
        // fetchOptionsFromCoreData()
        if let lastSync = UserDefaults.standard.string(forKey: "lastSynced") {
            self.lastSyncedText.text = "Last Synced: \(lastSync)"
        }
        else {
            self.lastSyncedText.text = " "
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        options = fetchOptionsFromCoreData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let option = options[indexPath.row]
        if (option is Option) {
            let o = option as! Option
            //let cell = UITableViewCell()
            //cell.textLabel?.text = o.title
            //cell.textLabel?.text = options[indexPath.row].value(forKey: "optionDescription") as? String
            //cell.textLabel?.textAlignment = .left
            //cell.textLabel?.font.withSize(36.0)
            let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell") as! OptionTableViewCell
            cell.OptionCellLabel.text = o.title
            
            return cell
        }
        else if (option is SubOption) {
            let s = option as! SubOption
            let cell = UITableViewCell()
            cell.textLabel?.text = s.name
            //cell.textLabel?.text = options[indexPath.row].value(forKey: "optionDescription") as? String
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font.withSize(30.0)
            return cell
        }
        else if (option is CreateSubOption){
            let cell = tableView.dequeueReusableCell(withIdentifier: "createSubOptionCell") as! CreateSubOptionTableViewCell
            return cell
        }
            
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "createOptionCell") as! CreateOptionTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let option = options[indexPath.row]
        if (option is Option) {
            print("option")
        }
        else if (option is SubOption) {
            print("sub option")
            let thecurrentSubOption = option as! SubOption
            currentOptionTitle = thecurrentSubOption.parentOption?.title
            currentSubOptionTitle = thecurrentSubOption.name
            currentOption = thecurrentSubOption.parentOption
            currentSubOption = thecurrentSubOption
            self.performSegue(withIdentifier: "optionsToPlacement", sender: self)
        }
        else if (option is CreateSubOption){
            let cso = option as! CreateSubOption
            createSubOptionPopup(withParent: cso.parentOption!, atRow:indexPath.row)
            print("create sub option")
        }
        else if (option is CreateOption) {
            print("create option")
            createOptionPopup()
            return
        }
        else {
            self.performSegue(withIdentifier: "optionsToPlacement", sender: self)
        }
    }
    
    func createOptionPopup(){
        let alert = UIAlertController(title: "Create New Option", message: "Enter the title for the new option", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let createAction = UIAlertAction(title: "Create", style: .default, handler: { action in
            let createdOption = Option()
            createdOption.title = alert.textFields![0].text
            createdOption.user = self.currentUserName
            self.options.removeLast()
            self.options.append(createdOption)
            self.options.append(CreateSubOption(withParent: createdOption))
            self.options.append(CreateOption())
            self.createOptionWithCoreData(with: createdOption)
            self.tableView.reloadData()
        })
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func createSubOptionPopup(withParent option:Option, atRow row:Int ){
        let alert = UIAlertController(title: "Create New Sub Option", message: "Enter the title for the new sub option", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let createAction = UIAlertAction(title: "Create", style: .default, handler: { action in
            let createdSubOption = SubOption()
            createdSubOption.name = alert.textFields![0].text
            createdSubOption.parentOption = option
            createdSubOption.parentOptionID = option.optionID
            self.options.insert(createdSubOption, at: row)
            self.createSubOptionWithCoreData(with: createdSubOption)
            self.tableView.reloadData()
        })
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    ///////////////////////////////
    //
    //    Core data
    //
    ///////////////////////////////
    
    
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
    
    // not in use now
    /*
    func createQuestionSetWithCoreData(with questionSet:QuestionSet, withOption option: Option){
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
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
    */
    
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
    
    func fetchOptionsFromCoreData() -> [AnyObject] {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return []
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "CDOption")
        
        fetchRequest.predicate = NSPredicate(format: "user == %@", self.currentUserName!)
        
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
        
        // theOptions.append(CreateOption())
        
        return theOptions
    }
    
    ////////
    //
    //
    ////////
    
    func getQuestionAnswers(question:Question, forSetID: String, instance: Int) {
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "CDQuestionAnswer")
        
        let questionSetID = NSPredicate(format: "parentQuestionSetID == %@", forSetID)
        let instanceID = NSPredicate(format: "parentIconNumber == %@", instance)
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [questionSetID, instanceID])
        
        fetchRequest.predicate = andPredicate
        
        var theOptions = [AnyObject]()
        var theManagedOptions = [NSManagedObject]()
        do {
            let theManagedAnswers = try self.managedContext.fetch(fetchRequest)
            for oneManagedAnswer in theManagedAnswers {
                
                
                
            }
        }
        catch  let error as NSError {
            print("Could not get answer. \(error), \(error.userInfo)")
        }
    }
    
    
    func eraseOptionsFromCoreDataWithCurrentUser() {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        self.managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "CDOption")
        
        fetchRequest.predicate = NSPredicate(format: "user == %@", self.currentUserName!)
        
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "optionsToPlacement") {
            let placementViewController = segue.destination as! PlacementViewController
            placementViewController.optionTitle = currentOptionTitle
            placementViewController.subOptionOneTitle = currentSubOptionTitle
            placementViewController.currentSubOption = currentSubOption
            placementViewController.currentOption = currentOption
        }
    }
    
    @IBAction func syncButtonPressed(_ sender: Any) {
        
        if ( !Reachability.isConnectedToNetwork() ) {
            notConnectedToInternetPopup()
            return
        }
        
        overwriteWarningPopup(completion: {
            self.syncOperation()
        })
        
    }
    
    func syncOperation() {
        
        SVProgressHUD.show()
        let api = AlchemieAPI()
        
        api.fetchOptionsBetter(completion: {   success, response in
            if (success) {
                print("lololz")
                self.eraseOptionsFromCoreDataWithCurrentUser()
                let downloadedOptions = self.getOptionsFromJSONBetter(withJSON: response)
                self.options.removeAll()
                self.options = downloadedOptions
                self.tableView.reloadData()
            }
            else {
                SVProgressHUD.dismiss()
                self.errorPopup()
            }
            // self.questionsLoaded = true
            //if (self.checkIfEverythingLoaded()){
            //    SVProgressHUD.dismiss()
            //}
        })
        //self.questionsLoaded = true
 
        /*
        api.fetchQuestionSet(completion: {   success, response in
            print(response)
            if (success) {
                print("yayayayayay")
                self.questions = self.getQuestionSetFromJSON(withJSON: response)
                print("dis this freaking work??")
                print(self.questions.count)
                if (self.questions.count > 0) {
                    print(self.questions[0].printQuestionList())
                }
            }
            else {
                print("nononono")
                //self.errorPopup()
            }
            self.questionsLoaded = true
            if (self.checkIfEverythingLoaded()){
                SVProgressHUD.dismiss()
            }
        })
       */
    }
    
    
    
//    func getOptionsFromJSON(withJSON json:[[String: AnyObject]] ) -> [AnyObject] {
//
//        let completionOperation = BlockOperation {
//            // do something
//            self.optionsLoaded = true
//            if (self.checkIfEverythingLoaded()){
//                SVProgressHUD.dismiss()
//            }
//        }
//
//        let dispatchGroup = DispatchGroup()
//
//        var theOptions = [AnyObject]()
//        for option in json {
//            guard let optionName = option["OptionName"] as? String else {
//                print("somethings wrong with the options data")
//                return [AnyObject]()
//            }
//            let newOption = Option()
//            newOption.title = optionName
//            newOption.user = self.currentUserName
//            theOptions.append(newOption)
//            createOptionWithCoreData(with: newOption)
//            guard let subOptions = option["Suboptions"] as? [[String: AnyObject]]else {
//                print("somethings wrong with the options data")
//                return [AnyObject]()
//            }
//
//            // sub options
//            for suboption in subOptions  {
//                guard let suboptionName = suboption["Suboption"] as? String else {
//                    print("somethings wrong with the options data")
//                    return [AnyObject]()
//                }
//                let newSubOption = SubOption()
//                newSubOption.name = suboptionName
//                newSubOption.parentOption = newOption
//                newSubOption.parentOptionID = newOption.optionID
//                guard let imageList = suboption["ImagesList"] as? [[String: AnyObject]] else {
//                    print("somethings wrong with the options data")
//                    return [AnyObject]()
//                }
//
//                theOptions.append(newSubOption)
//                createSubOptionWithCoreData(with: newSubOption)
//
//                // sub option images
//                for image in imageList {
//
//                    let imgPointer = image["ImgPointer"] as? String
//
//                    // guard
//                    let title = image["Title"] as? String //
//
//                    let downloadURL = self.baseDownloadImageURL + "\(imgPointer!)"
//
//                    dispatchGroup.enter()
//
//                    Alamofire.request(downloadURL).responseImage { response in
//                        debugPrint(response)
//                        // let downloadOperation = BlockOperation {
//                            print(response.request)
//                            print(response.response)
//                            debugPrint(response.result)
//
//                            if let theimage = response.result.value {
//                                print("image downloaded: \(theimage)")
//
//                                // should probably do this in queue after images download
//                                let item = Item()
//                                /// <-----  fix this ---->
//                                item.originalImage = theimage // UIImage(named: "questionSetIcon2") // this is temporary image. change it soon
//                                item.imgUUID = imgPointer
//                                item.imgPointer = imgPointer
//                                item.parentSubOptionID = newSubOption.subOptionID
//                                item.caption = title
//
//                                print("one download complete   \(String(describing: title)) on subOtion \(String(describing: newSubOption.name)) and option \(String(describing: newOption.title)) ")
//
//                                DispatchQueue.main.async {
//                                    self.addItemToCurrentSubOptionCoreData(subOption: newSubOption,  item: item )
//
//                                }
//
//                                dispatchGroup.leave()
//
//                        }
//
//                    }
//
//                    dispatchGroup.notify(queue: DispatchQueue.main) {
//                        // completion?(storedError)
//                        print("Downloads Done!!")
//                        self.optionsLoaded = true
//                        if (self.checkIfEverythingLoaded()) {
//                            SVProgressHUD.dismiss()
//                        }
//                    }
//
//                    //completionOperation.addDependency(downloadOperation)
//                    //self.operationQueue.addOperation(downloadOperation)
//                        //completionOperation.addDependency(downloadOperation)
//                        //operationQueue.addOperation(downloadOperation)
//                    //} // let completionOperation = BlockOperation {
//
//
//                } // for image in imageList {
//
//            }
//            theOptions.append(CreateSubOption(withParent: newOption))
//        }
//
//        theOptions.append(CreateOption()) ///  - dont do this its put there automatically
//
//        operationQueue.addOperation(completionOperation)
//
//        return theOptions
//    }
    
    
    // getoptionsEXP
    // this is the ones thats used
    func getOptionsFromJSONBetter(withJSON json:[[String: AnyObject]] ) -> [AnyObject] {
        
        let completionOperation = BlockOperation {
            // do something
            self.optionsLoaded = true
            if (self.checkIfEverythingLoaded()){
                SVProgressHUD.dismiss()
            }
        }
        
        let dispatchGroup = DispatchGroup()
        
        var theOptions = [AnyObject]()
        for option in json {
            
            var optionID = ""
            var optionName = ""
            var projectSummary = ""
            
            if let theOptionID = option["ID"] as? String  {
                print("somethings wrong with the options data")
                optionID = theOptionID
            }
            if let theOptionName = option["OptionName"] as? String {
                print("somethings wrong with the options data")
                optionName = theOptionName
            }
            if let theProjectSummary = option["ProjectSummary"] as? String {
                print("somethings wrong with the options data")
                projectSummary = theProjectSummary
            }
            
            let newOption = Option()
            newOption.title = optionName
            newOption.user = self.currentUserName
            newOption.optionID = optionID
            newOption.optionDescription = projectSummary
            theOptions.append(newOption)
            createOptionWithCoreData(with: newOption)
            guard let subOptions = option["Suboptions"] as? [[String: AnyObject]]else {
                print("somethings wrong with the options data")
                return [AnyObject]()
            }
            
            // sub options
            for suboption in subOptions  {
                var suboptionName = ""
                var suboptionID = ""
                if let theSuboptionName = suboption["Suboption"] as? String {
                    print("somethings wrong with the sub options name data")
                    suboptionName = theSuboptionName
                }
                if let theSuboptionID = suboption["ID"] as? String {
                    print("somethings wrong with the sub options name data")
                    suboptionID = theSuboptionID
                }
                
                let newSubOption = SubOption()
                newSubOption.name = suboptionName
                newSubOption.parentOption = newOption
                newSubOption.parentOptionID = newOption.optionID
                newSubOption.subOptionID = suboptionID
                
                theOptions.append(newSubOption)
                createSubOptionWithCoreData(with: newSubOption)
                
                guard let imageList = suboption["ImagesList"] as? [[String: AnyObject]] else {
                    print("somethings wrong with the options data")
                    return [AnyObject]()
                }
                
                // sub option images
                for image in imageList {
                    
                    let imgPointer = image["ImgPointer"] as? String
                    
                    let itemId = image["LocationID"] as? String // item id = location id
                    
                    // guard
                    let title = image["Title"] as? String //
                    
                    let downloadURL = self.baseDownloadImageURL + "\(imgPointer!)"
                    
                    dispatchGroup.enter()
                    
                    Alamofire.request(downloadURL).responseImage { response in
                        debugPrint(response)
                        // let downloadOperation = BlockOperation {
                        print(response.request)
                        print(response.response)
                        debugPrint(response.result)
                        
                        dispatchGroup.leave()
                        
                        if let theimage = response.result.value {
                            print("image downloaded: \(theimage)")
                            
                            // should probably do this in queue after images download
                            let item = Item()
                            item.originalImage = theimage //
                            item.imgUUID = imgPointer
                            item.imgPointer = imgPointer
                            item.parentSubOptionID = newSubOption.subOptionID
                            item.caption = title
                            item.itemID = itemId
                            
                            print("one download complete   \(String(describing: title)) on subOtion \(String(describing: newSubOption.name)) and option \(String(describing: newOption.title)) ")
                            
                            //DispatchQueue.main.async {
                            
                                self.addItemToCurrentSubOptionCoreData(subOption: newSubOption,  item: item )
                                
                            //}
                            
                        }
                        
                    }
                    
                } // for image in imageList {
                
            }
            
            
            guard let questionSets = option["Questionsets"] as? [[String: AnyObject]]else {
                print("somethings wrong with the options data")
                return [AnyObject]()
            }
            
            var theQuestions = [QuestionSet]()
            var numberOfQuestionLists = 0
            for questionSet in questionSets {
                
                let oneQuestionSet = QuestionSet()
                
                var setCompanyNum = 0
                var setID         = " "
                var setSurveyIcon = " "
                var setSurveyName = " "
                var setSurveyType = " "
                
                if let questionSetCompanyNum = questionSet["CompanyNum"] as? Int {
                    setCompanyNum = questionSetCompanyNum
                }
                else {
                    setCompanyNum = 0
                }
                if let  questionSetID = questionSet["ID"] as? String   {
                    setID = questionSetID
                }
                
                if let questionSetSurveyIcon = questionSet["SurveyIconPointer"] as? String  {
                    setSurveyIcon = questionSetSurveyIcon
                }
                else {
                    
                }
                
                if let  questionSetSurveyName = questionSet["SurveyName"] as? String {
                    setSurveyName = questionSetSurveyName
                    // return [QuestionSet]()
                }
                else {
                    print("somethings wrong with the question data")
                    setSurveyName  = "  "
                }
                
                if let  questionSetSurveyType = questionSet["SurveyType"] as? String  {
                    //print("somethings wrong with the data")
                    //return [QuestionSet]()
                    setSurveyType = questionSetSurveyType
                }
                
//                if () {
//
//                }
                
                
                oneQuestionSet.companyNum = setCompanyNum
                oneQuestionSet.theID      = setID
                oneQuestionSet.surveyIconPointer = setSurveyIcon
                oneQuestionSet.surveyName = setSurveyName
                oneQuestionSet.surveyType = setSurveyType
                oneQuestionSet.parentOptionID = newOption.optionID
                
                
                
                
                let downloadURL = self.baseDownloadImageURL + "\(setSurveyIcon)"
                
                dispatchGroup.enter()
                // dispatchGroup.e
                Alamofire.request(downloadURL).responseImage { response in
                    debugPrint(response)
                    
                    print("  -- one icon!!!")
                    print(response.request)
                    print(response.response)
                    debugPrint(response.result)
                    
                    
                    if let theimage = response.result.value {
                        
                        if let iconPointer = oneQuestionSet.surveyIconPointer {
                            self.imageStore.setImagePNG(theimage, forKey: iconPointer)
                        }
                    }
                    
                    dispatchGroup.leave()
                    
                    
                }
                
                
                guard let questionList = questionSet["QuesList"] as? [[String: AnyObject]] else {
                    print("somethings wrong with the  question data")
                    return [QuestionSet]()
                }
                
                for oneQuestion in questionList  {
                    
                    let question = Question()
                    var qSetID = " "
                    var qText = " "
                    var qType = 1
                    var qNum = 0
                    
                    if let questionSetID = oneQuestion["QuestionSetID"] as? String  {
                        qSetID = questionSetID
                    }
                    
                    if let questionText = oneQuestion["QuestionText"] as? String {
                        qText = questionText
                    }
                    
                    if let questionNumber = oneQuestion["QuestionNum"] as? Int {
                        qNum = questionNumber
                    }
                    
                    if let questionType = oneQuestion["QuestionType"] as? Int {
                        qType = questionType
                        
                        if (questionType == 3 || questionType == 4) {
                            
                            guard let optionList = oneQuestion["OptionList"] as? [[String: AnyObject]] else {
                                print("somethings wrong with the option list data")
                                return [QuestionSet]()
                            }
                            
                            var optionObjectList = [Answer]()
                            
                            for oneOption in optionList {
                                let oneOptionAnswer = Answer()
                                if let answerOptionID = oneOption["ID"] as? String  {
                                    oneOptionAnswer.answerID = answerOptionID
                                }
                                if let answerOptionListID = oneOption["ListID"] as? String  {
                                    oneOptionAnswer.answerListID = answerOptionListID
                                }
                                if let answerOptionListitemtext = oneOption["Listitemtext"] as? String  {
                                    oneOptionAnswer.answerListitemtext = answerOptionListitemtext
                                }
                                if let answerOptionListseq = oneOption["Listseq"] as? Int  {
                                    oneOptionAnswer.answerListseq = answerOptionListseq
                                }
                                optionObjectList.append(oneOptionAnswer)
                            }
                        
                            question.optionObjectList = optionObjectList
                            
                        }
                        
                    }
                    
                    question.questionID = qSetID
                    question.questionText = qText
                    question.parentQuestionSetID = oneQuestionSet.theID
                    question.questionNumber = qNum
                    question.setType(type: qType)
                    print("hopefully added \(qText)")
                    oneQuestionSet.questionList.append(question)
                    // createSubOptionWithCoreData(with: newSubOption)
                    
                    numberOfQuestionLists += 1
                    // createQuestionListOnOptionWithCoreData(with: question, withOption: newOption)
                    
                }
                
                oneQuestionSet.questionList.sort(by: {
                    $0.questionNumber! < $1.questionNumber!
                })
                
                theQuestions.append(oneQuestionSet)
                newOption.questionSetList.append(oneQuestionSet)
                createQuestionSetOnOptionWithCoreData(with: oneQuestionSet, withOption: newOption)
            }
            
            
            theOptions.append(CreateSubOption(withParent: newOption))
            
            
            dispatchGroup.notify(queue: DispatchQueue.main) {
                print("Downloads Done!!")
                self.optionsLoaded = true
                //let formatter = NSDateFormatter()
//                formatter.dateStyle = NSDateFormatterStyle.LongStyle
//                formatter.timeStyle = .MediumStyle
                
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "H:mm  MM/dd/yyyy"
                let result = formatter.string(from: date)
                
                let dateString = formatter.date
                let lastSyncTime =  formatter.string(from: date)
                UserDefaults.standard.set(lastSyncTime, forKey: "lastSynced")
                    //UserDefaults.standard.string(forKey: "lastSynced")
                self.lastSyncedText.text = "Last Synced:  \(lastSyncTime)"
                
                SVProgressHUD.dismiss()
            }
            
        }
        
        
        // theOptions.append(CreateOption()) ///  - dont do this its put there automatically
        
        operationQueue.addOperation(completionOperation)
        
        return theOptions
    }
    
    
    
    
//    func getQuestionSetFromJSON(withJSON json:[[String: AnyObject]] ) -> [QuestionSet] {
//
//        var theQuestions = [QuestionSet]()
//        for questionSet in json {
//            //guard let optionName = option["OptionName"] as? String else {
//            //    print("somethings wrong with the data")
//            //     return [AnyObject]()
//            //}
//            let oneQuestionSet = QuestionSet()
//
//            var setCompanyNum = 0
//            var setID         = " "
//            var setSurveyIcon = " "
//            var setSurveyName = " "
//            var setSurveyType = " "
//
//            if let questionSetCompanyNum = questionSet["CompanyNum"] as? Int {
//                setCompanyNum = questionSetCompanyNum
//            }
//            else {
//                setCompanyNum = 0
//            }
//            if let  questionSetID = questionSet["ID"] as? String   {
//                setID = questionSetID
//            }
//
//            if let questionSetSurveyIcon = questionSet["SurveyIcon"] as? String  {
//                setSurveyIcon = questionSetSurveyIcon
//            }
//            else {
//
//            }
//
//            if let  questionSetSurveyName = questionSet["SurveyName"] as? String {
//                setSurveyName = questionSetSurveyName
//                // return [QuestionSet]()
//            }
//            else {
//                print("somethings wrong with the question data")
//                setSurveyName  = "  "
//            }
//
//            if let  questionSetSurveyType = questionSet["SurveyType"] as? String  {
//                //print("somethings wrong with the data")
//                //return [QuestionSet]()
//                setSurveyType = questionSetSurveyType
//            }
//
//            oneQuestionSet.companyNum = setCompanyNum
//            oneQuestionSet.theID      = setID
//            oneQuestionSet.surveyIconPointer = setSurveyIcon
//            oneQuestionSet.surveyName = setSurveyName
//            oneQuestionSet.surveyType = setSurveyType
//
//            guard let questionList = questionSet["QuesList"] as? [[String: AnyObject]] else {
//                print("somethings wrong with the  question data")
//                return [QuestionSet]()
//            }
//
//            for oneQuestion in questionList  {
//
//                let question = Question()
//                var qSetID = " "
//                var qText = " "
//                var qType = 1
//
//                if let questionSetID = oneQuestion["QuestionSetID"] as? String  {
//                    qSetID = questionSetID
//                }
//
//                if let questionText = oneQuestion["QuestionText"] as? String {
//                    qText = questionText
//                }
//
//                if let questionType = oneQuestion["QuestionType"] as? Int {
//                    qType = questionType
//                }
//
//                question.questionID = qSetID
//                question.questionText = qText
//                question.setType(type: qType)
//                print("hopefully added \(qText)")
//                oneQuestionSet.questionList.append(question)
//                // createSubOptionWithCoreData(with: newSubOption)
//
//                // createQuestionListOnOptionWithCoreData(with: question, withOption: <#T##Option#>)
//
//            }
//            theQuestions.append(oneQuestionSet)
//        }
//        return theQuestions
//
//    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        logoutPopup {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func checkIfEverythingLoaded() -> Bool {
        
        if (optionsLoaded && questionsLoaded) {
            for option in self.options {
                if option is Option {
                    let o = option as! Option
                    print("start parsing q list")
                    if  self.questions.count == 0 {
                        print("not valid question list")
                        continue
                    }
                    // o.questionSet? = self.questions
                    //print("print questions list")
                    //self.questions[0].printQuestionSet()
                    
                    if ( self.questions[0].questionList.count == 0) {
                            continue
                    }
                    
                    print("print questions list")
                    o.questionList = self.questions[0].questionList
                    o.printQuestionList()
                    
                    //self.questions[0].printQuestionList()
                    for question in self.questions[0].questionList  {
                        self.createQuestionListOnOptionWithCoreData(with: question, withOption: o)
                        print("question added to option: \(question.questionText)")
                    }
                    /*
                    else {
                        print("not vlid question list")
                    }*/
                    
                }
            }
            return true
        }
        else {
            return false
        }
        
        
    }
}
