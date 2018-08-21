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
import PopupDialog 
//import Reach

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
    
//    let dataStore = DataStore.shared
    
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
        
        self.currentUserName = KeychainWrapper.standard.string(forKey: "userName")
        
        if let lastSync = UserDefaults.standard.string(forKey: "lastSynced") {
            self.lastSyncedText.text = "Last Synced: \(lastSync)"
        }
        else {
            self.lastSyncedText.text = " "
        }
        
        options = DataStore.shared.fetchOptionsFromCoreData(forUsername: self.currentUserName!)
        self.tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        options = DataStore.shared.fetchOptionsFromCoreData(forUsername: self.currentUserName!)
//        self.tableView.reloadData()
        let reach = ReachabilityHelper()
        if reach.isConnectedToNetworkHelper() == true {
            print("Internet connection OK")
            self.syncButton.isEnabled = true
        } else {
            self.syncButton.isEnabled = false
            self.connectivityLostPopup()
        }
        
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell") as! OptionTableViewCell
            cell.OptionCellLabel.text = o.title
            return cell
        }
        else if (option is SubOption) {
            let s = option as! SubOption
            let cell = UITableViewCell()
            cell.textLabel?.text = s.name
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
    
    func createOptionPopup(){ // not used anmore
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
            DataStore.shared.createOptionWithCoreData(with: createdOption)
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
            DataStore.shared.createSubOptionWithCoreData(with: createdSubOption)
            self.tableView.reloadData()
        })
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
//    func createSubOptionPopup(withParent option:Option, atRow row:Int ){
//        let viewController = UIViewController()
//        let textField = UITextField()
//        viewController.view.addSubview(textField)
//        let popup = PopupDialog(viewController: viewController,
//                                buttonAlignment: .vertical,
//                                transitionStyle: .bounceUp,
//                                preferredWidth: 340,
//                                gestureDismissal: true,
//                                hideStatusBar: false)
//        let okButton = DefaultButton(title: "Create") {
//            let createdSubOption = SubOption()
//            createdSubOption.name = textField.text
//            createdSubOption.parentOption = option
//            createdSubOption.parentOptionID = option.optionID
//            self.options.insert(createdSubOption, at: row)
//            DataStore.shared.createSubOptionWithCoreData(with: createdSubOption)
//            self.tableView.reloadData()
//        }
//        let cancelButton = CancelButton(title: "Cancel", action: nil)
//        popup.addButtons([okButton, cancelButton])
//        self.present(popup, animated: true, completion: nil)
//    }
    
    ///////////////////////////////
    //
    //    Core data
    //
    ///////////////////////////////
    
    
    
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
        let reach = ReachabilityHelper()
        if ( reach.isConnectedToNetworkHelper() == false ) {
            notConnectedToInternetPopup()
            return
        }
        
        overwriteWarningPopup(completion: {
            self.syncOperation()
        })
        
    }
    
    func syncOperation() {
        SVProgressHUD.show()
        AlchemieAPI.shared.fetchOptionsBetter(completion: {   success, response in
            if (success) {
                print("lololz")
                DataStore.shared.eraseOptionsFromCoreDataWithCurrentUser(currentUserName: self.currentUserName!)
                let downloadedOptions = self.getOptionsFromJSONBetter(withJSON: response)
                self.options.removeAll()
                self.options = downloadedOptions
                self.tableView.reloadData()
            }
            else {
                SVProgressHUD.dismiss()
                self.errorPopup()
            }
        })
    }
    
    
  
    
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
            DataStore.shared.createOptionWithCoreData(with: newOption)
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
                DataStore.shared.createSubOptionWithCoreData(with: newSubOption)
                
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
                            
                            
                                DataStore.shared.addItemToCurrentSubOptionCoreData(subOption: newSubOption,  item: item )
                            
                            
                        }
                        
                    }
                    
                }
                
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
                }
                else {
                    print("somethings wrong with the question data")
                    setSurveyName  = "  "
                }
                
                if let  questionSetSurveyType = questionSet["SurveyType"] as? String  {
                    setSurveyType = questionSetSurveyType
                }
                
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
                    numberOfQuestionLists += 1
                    
                }
                
                oneQuestionSet.questionList.sort(by: {
                    $0.questionNumber! < $1.questionNumber!
                })
                
                theQuestions.append(oneQuestionSet)
                newOption.questionSetList.append(oneQuestionSet)
                DataStore.shared.createQuestionSetOnOptionWithCoreData(with: oneQuestionSet, withOption: newOption)
            }
            
            
            theOptions.append(CreateSubOption(withParent: newOption))
            
            
            dispatchGroup.notify(queue: DispatchQueue.main) {
                print("Downloads Done!!")
                self.optionsLoaded = true
                
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "H:mm  MM/dd/yyyy"
                let result = formatter.string(from: date)
                
                let dateString = formatter.date
                let lastSyncTime =  formatter.string(from: date)
                UserDefaults.standard.set(lastSyncTime, forKey: "lastSynced")
                self.lastSyncedText.text = "Last Synced:  \(lastSyncTime)"
                
                SVProgressHUD.dismiss()
            }
            
        }
        
        operationQueue.addOperation(completionOperation)
        theOptions.sort(by: { (left: AnyObject, right:AnyObject) -> Bool in
            if (left is Option && right is Option) {
                let oleft = left as! Option
                let oright = right as! Option
                return oleft.title! < oright.title!
            }
            
            return false
            
        })
        return theOptions
    }
 
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
                    
                    if ( self.questions[0].questionList.count == 0) {
                            continue
                    }
                    
                    print("print questions list")
                    o.questionList = self.questions[0].questionList
                    o.printQuestionList()
                    
                    for question in self.questions[0].questionList  {
                        DataStore.shared.createQuestionListOnOptionWithCoreData(with: question, withOption: o)
                        print("question added to option: \(question.questionText)")
                    } 
                }
            }
            return true
        }
        else {
            return false
        }
        
        
    }
    
    // reachability
    
//    @objc func reachabilityChanged(note: Notification) {
//
//        let reachability = note.object as! Reachability
//
//        switch reachability.connection {
//        case .wifi:
//            print("Reachable via WiFi")
//            self.syncButton.isEnabled = true
//        case .cellular:
//            print("Reachable via Cellular")
//            self.syncButton.isEnabled = true
//        case .none:
//            print("Network not reachable")
//            self.syncButton.isEnabled = false
//            self.connectivityLostPopup()
//        }
//    }
    
    
}
