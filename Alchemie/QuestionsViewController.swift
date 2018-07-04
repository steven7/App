//
//  QuestionsViewController.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 1/11/18.
//  Copyright © 2018 steve. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreData

class QuestionsViewController: UIViewController,  UITextFieldDelegate,  UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    

    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var popuptableView: UITableView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var dicardButton: UIButton!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var pickerViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var popupTableViewTopConstraint: NSLayoutConstraint!
    
    var pickerQuestions = [ "Question One", "Question Two", "Question Three", "Question Four", "Question Five", "Question Six", "Question Seven", "Question Eight"]
    var pickerAnswers = [Answer]()
    
    var theQuestions = [Question]()
    
    var theQuestionTypes = [Question.QuestionTypes]()
    
    var currentOption:Option?
    var currentSubOption:SubOption?
    var currentItem:Item?
    var currentButton:QuestionButton?
    
    let imagePicker = UIImagePickerController()
    
    var theImage:UIImage?
    var photoButton:UIButton?
    var currentRow:Int?
    
    //var imageCache = Dictionary<String, UIImage>()
    var imageCache = Dictionary<Int, UIImage>()
    
    var currentTextField: UITextField?
    var currentQuestionNumber:Int?
    
    var answerSetXPosition:Double?
    var answerSetYPosition:Double?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.saveButton.layer.cornerRadius = 10
        self.dicardButton.layer.cornerRadius = 10
        
        // picker stuff
        self.imagePicker.delegate = self
        self.pickerView.isHidden = true
        self.pickerView.isUserInteractionEnabled = false
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.popuptableView.isHidden = true
        self.popuptableView.dataSource = self
        self.popuptableView.isUserInteractionEnabled = false
        self.popuptableView.delegate = self
        
        
        if let everyQuestion = self.currentButton?.getQuestions() {
            theQuestions = everyQuestion
        }
        theQuestions.append(Question(text: "Next Question", type: .next) )
        
        
        let tNib = UINib(nibName: "TextQuestionTableViewCell", bundle: nil)
        let yNib = UINib(nibName: "YesOrNoQuestionTableViewCell", bundle: nil)
        let lNib = UINib(nibName: "ListQuestionTableViewCell", bundle: nil)
        let mNib = UINib(nibName: "MultiListQuestionTableViewCell", bundle: nil)
        let pNib = UINib(nibName: "PhotoQuestionTableViewCell", bundle: nil)
        let nqNib = UINib(nibName: "NextQuestionTableViewCell", bundle: nil)
        
        tableView.register(tNib, forCellReuseIdentifier: "textCell")
        tableView.register(yNib, forCellReuseIdentifier: "yesrOrNoCell")
        tableView.register(lNib, forCellReuseIdentifier: "listCell")
        tableView.register(mNib, forCellReuseIdentifier: "multiListCell")
        tableView.register(pNib, forCellReuseIdentifier: "photoCell")
        tableView.register(nqNib, forCellReuseIdentifier: "nextQuestionCell")
        
        tableView.rowHeight = tableView.estimatedRowHeight
        
        self.pickerView.layer.cornerRadius = 10
        self.pickerView.layer.borderColor = UIColor.darkGray.cgColor
        self.pickerView.layer.borderWidth = 1
        
        self.popuptableView.layer.cornerRadius = 10
        self.popuptableView.layer.borderColor = UIColor.darkGray.cgColor
        self.popuptableView.layer.borderWidth = 1
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: .UIKeyboardDidShow , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)), name: .UIKeyboardDidHide , object: nil)
        
        
        print("\n\n\the button id is")
        print("  \(String(describing: currentButton?.buttonInstanceID))   \n")
        
        let ansMap = currentButton?.getTheAnswersMap()
        
        loadAnswers()
        
        for (key, value) in ansMap! {
            print("number: \(key)  with text \(value)")
        }
        print("\n\n\n")
        
        for (key, value) in imageCache {
            print("number: \(key)  with picture --- \(value)")
        }
        print("\n\n\n")
    }

    override func viewDidAppear(_ animated: Bool) {
        if let everyQuestion = self.currentButton?.getQuestions() {
            theQuestions = everyQuestion
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.currentButton?.setQuestions(questions: theQuestions)
        self.currentButton?.photoCache = self.imageCache
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createNextRow(){
        
        let endRow = theQuestions.count - 1
        
        // delete one row model
        // theQuestionTypes.removeLast()
        theQuestions.popLast()
        
        // add two rows to medl
        let newQuestion = Question(text:"Wow! This is the next Question!", type: .list)
        var nextQuestion = Question(text:"Next Question", type: .next)
        if (theQuestions.count == 4) {
            nextQuestion = Question(text:"Done!", type: .next)
        }
        theQuestions.append(newQuestion)
        theQuestions.append(nextQuestion)
        
        //theQuestionTypes.append(.list)
        //theQuestionTypes.append(.next)
        
        let indexPathEnd = IndexPath(row: endRow , section: 0)
        let indexPathAdd = IndexPath(row: endRow + 1 , section: 0)
        
        tableView.beginUpdates()
        
        tableView.deleteRows(at: [indexPathEnd], with: .fade)
        tableView.insertRows(at: [indexPathEnd, indexPathAdd], with: .bottom)
        
        tableView.endUpdates()
        
        // tableView.reloadData()
        
        tableView.scrollToRow(at: indexPathEnd, at: .middle, animated: true)
    }
    
    
//    func photoButtonClosure(button: UIButton, row: Int ) {
//
//        self.photoButton = button
//        self.currentRow = row
//        //self.currentQuestionNumber =
//
//        let photoAlert = UIAlertController(title: "Photo Source", message: "What is the source of the photo?", preferredStyle: .actionSheet)
//        let buttonView = UIView(frame: CGRect(x: button.frame.midX, y: button.frame.minY - 80, width: button.frame.width, height: button.frame.height))
//        //
//        photoAlert.popoverPresentationController?.sourceView = button
//        photoAlert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
//        let libraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { action in
//            self.imagePicker.allowsEditing = false
//            self.imagePicker.sourceType = .photoLibrary
//            self.present(self.imagePicker, animated: true, completion: nil)
//        })
//        let cameraAction  = UIAlertAction(title: "Camera", style: .default, handler: { action in
//            self.imagePicker.allowsEditing = false
//            self.imagePicker.sourceType = .camera
//            self.present(self.imagePicker, animated: true, completion: nil)
//        })
//        photoAlert.addAction(libraryAction)
//        photoAlert.addAction(cameraAction)
//        self.present(photoAlert, animated: true, completion: {
//            print("done lololz")
//        })
//    }

    
//    func photoButtonClosure(button: UIButton ) {
//
//        self.photoButton = button
//
//        let photoAlert = UIAlertController(title: "Photo Source", message: "What is the source of the photo?", preferredStyle: .actionSheet)
//        let buttonView = UIView(frame: CGRect(x: button.frame.midX, y: button.frame.minY - 80, width: button.frame.width, height: button.frame.height))
//        //
//        photoAlert.popoverPresentationController?.sourceView = button // View // button // .superview
//        //photoAlert.popoverPresentationController?.sourceView = self.view
//        photoAlert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
//        //photoAlert.popoverPresentationController?.sourceRect = CGRect(x: button.frame.midX, y: button.frame.maxY - 100, width: 0, height: 0)
//            //(button.superview?.frame)!
//            //CGRect(x: button.frame.midX, y: button.frame.maxY , width: 0, height: 0)
//            // button.frame
//            // CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY - 180, width: 0, height: 0)
//        let libraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { action in
//            self.imagePicker.allowsEditing = false
//            self.imagePicker.sourceType = .photoLibrary
//            self.present(self.imagePicker, animated: true, completion: nil)
//        })
//        let cameraAction  = UIAlertAction(title: "Camera", style: .default, handler: { action in
//            self.imagePicker.allowsEditing = false
//            self.imagePicker.sourceType = .camera
//            self.present(self.imagePicker, animated: true, completion: nil)
//        })
//        photoAlert.addAction(libraryAction)
//        photoAlert.addAction(cameraAction)
//        self.present(photoAlert, animated: true, completion: {
//            print("done lololz")
//        })
//    }
    
    
    
    func buttonClosureWithAns(theanswer:String, row:Int) {
        theQuestions[row].questionAnswer = theanswer
//        self.currentButton?.addToAnswerMap(answer: theanswer, key: row)
        let key = theQuestions[row].questionNumber
        self.currentButton?.addToAnswerMap(answer: theanswer, key: key!)
    }
    
    func textClosureCloseWithAnsPlusRow(textField: UITextField, row: Int) {
        theQuestions[row].questionAnswer = textField.text
//        self.currentButton?.addToAnswerMap(answer: textField.text!, key: row)
        let key = theQuestions[row].questionNumber
        self.currentButton?.addToAnswerMap(answer: textField.text!, key: key!)
    }
 
    func pickerClosureClose() {
        self.pickerView.isHidden = true
        self.pickerView.isUserInteractionEnabled = false 
        self.popuptableView.isHidden = true
        self.popuptableView.isUserInteractionEnabled = false
    }
    
    func textFieldClosure(theanswer:String, row: Int){
        //let indexPath = tableView.indexPathForSelectedRow
        //let ans = currentTextField?.text
        let key = theQuestions[row].questionNumber
        theQuestions[row].questionAnswer = theanswer
        self.currentButton?.addToAnswerMap(answer: theanswer, key: key!)
//        print("Keyboard will hide!")
    }
  
    func pickerClosureCloseWithAnsPlusRow(textField: UITextField, theanswerID:String, row: Int) {
        self.pickerView.isHidden = true
        self.pickerView.isUserInteractionEnabled = false
        let index = self.pickerView.selectedRow(inComponent: 0)
        let theanswer = pickerQuestions[index]
        theQuestions[row].questionAnswer = theanswer
        
        // self.currentButton?.addToAnswerMap(answer: theanswer, key: row)
        let key = theQuestions[row].questionNumber
        self.currentButton?.addToAnswerMap(answer: theanswer, key: key!)
//        if (index < theQuestions.count) {
//
//        }
        textField.text = theanswer
        
        let answersObject = theQuestions[row].getAnswersOptionsObject()
        let answersID = answersObject[index].answerID
        //var answersId = ""
        if index < answersObject.count {
            if let ansID = answersObject[index].answerID {
                theQuestions[row].questionAnswerID = ansID
            }
        }
//
//        theQuestions[row].questionAnswerID = answersID
    }
 
    
    
    func pickerClosureCloseWithAnsPlusRowMulti(textField: UITextField, theanswerID:String,  row: Int) {
        self.pickerView.isHidden = true
        self.pickerView.isUserInteractionEnabled = false
        let index = self.pickerView.selectedRow(inComponent: 0)
        let theanswer = pickerQuestions[index]
        
//        self.currentButton?.addToAnswerMap(answer: theanswer, key: row)
        textField.text?.append("\(theanswer)  ")
        
        // theQuestions[row].questionAnswer?.append("\(theanswer)  ")
        let key = theQuestions[row].questionNumber
        self.currentButton?.addToAnswerMap(answer: textField.text!, key: key!)
        
        let answersObject = theQuestions[row].getAnswersOptionsObject()
        //var answersId = ""
        if index < answersObject.count {
            if let ansID = answersObject[index].answerID {
                theQuestions[row].questionAnswerID = ansID
            }
        }
//        if index < pickerAnswers.count {
//            let ansObject = pickerAnswers[index]
//            theQuestions[row].questionSetID = ansObject.answerListID
//        }
        
    }
    
//    func pickerClosureCloseWithAnsMulti(textField: UITextField) {
//        self.pickerView.isHidden = true
//        self.pickerView.isUserInteractionEnabled = false
//        let index = self.pickerView.selectedRow(inComponent: 0)
//        let theanswer = pickerQuestions[index]
//        textField.text?.append("\(theanswer)  ")
//    }
    
    func pickerClosureOpen() {
        self.pickerView.isHidden = false
        self.pickerView.isUserInteractionEnabled = true
        self.view.bringSubview(toFront: self.pickerView)
//        self.popuptableView.isHidden = false
//        self.popuptableView.isUserInteractionEnabled = true
//        self.view.bringSubview(toFront:self.popuptableView)
    }
    
    func pickerClosureOpen(textField:UITextField) {
        self.pickerView.isHidden = false
        self.pickerView.isUserInteractionEnabled = true
        self.view.bringSubview(toFront: self.pickerView)
//        self.popuptableView.isHidden = false
//        self.popuptableView.isUserInteractionEnabled = true
//        self.view.bringSubview(toFront:self.popuptableView)
    }
    
    func setPickerQuestionsClosure(theQuestions: [String]) {
        print("question closure")
        print(theQuestions)
        self.pickerQuestions = theQuestions
        self.pickerView.reloadAllComponents()
        self.popuptableView.reloadData()
    }
    
    func setPickerPositionClosure(textField: UITextField) {
        //self.pickerView.leadingAnchor
        //    = textField.bounds.minX
        
        let pointthree = self.view.convert(CGPoint.zero, from: textField.superview!.superview! )
        print("point: \(pointthree)")
        
        let dist = pointthree.y - 20.0
        
        print(self.pickerViewTopConstraint.constant)
        self.pickerViewTopConstraint.constant = dist
        print(self.pickerViewTopConstraint.constant)
        
        self.popupTableViewTopConstraint.constant = dist
        
        self.view.layoutIfNeeded()
        print(self.pickerViewTopConstraint.constant)
    }
    
    func keyboardManageClosure(textField: UITextField, _ notification: NSNotification){

        let keyboardSize:CGSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        print("Keyboard size: \(keyboardSize)")

        let keyboardRect = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue

        var pointInTable:CGPoint = textField.superview!.convert(textField.frame.origin, to: tableView)
        var contentOffset:CGPoint = tableView.contentOffset
        contentOffset.y  = pointInTable.y
        if let accessoryView = textField.inputAccessoryView {
            contentOffset.y -= accessoryView.frame.size.height
        }
        tableView.contentOffset = contentOffset

    }

    func keyboardManageClosureClose(textField: UITextField, _ notification: NSNotification){
        textField.resignFirstResponder()
        if ( textField.superview?.superview is UITableViewCell )
        {
            let buttonPosition = textField.convert(CGPoint.zero, to: tableView)
            let indexPath = tableView.indexPathForRow(at: buttonPosition)

            tableView.scrollToRow(at: indexPath!, at: .middle, animated: true)
            //[_tableview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTextField = textField
        return true
    }
    
    
    @objc func keyboardDidShow(_ notification: NSNotification) {
        print("Keyboard will show!")
        // print(notification.userInfo)
        
        let keyboardSize:CGSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        print("Keyboard size: \(keyboardSize)")
        
        let keyboardRect = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        let indexPath = tableView.indexPathForSelectedRow
        print("selected row \(indexPath)")
        /*
        let cell = tableView.cellForRow(at: indexPath!)
        */
        print("current text field \(currentTextField)")
        print("keyboard rect \(keyboardRect)")
        /*
        if ( currentTextField?.frame.contains(keyboardRect) )! {
            tableView.scrollRectToVisible(keyboardRect, animated: true)
        }
        */
    }
    
    @objc func keyboardDidHide(_ notification: NSNotification) {
        
    }
    
    /*
    @objc func (_ notification: NSNotification){
        self.view.endEditing(true)
        pickerClosureClose()
    }
    */
    
    @objc func screenTapped(){
        self.view.endEditing(true)
        pickerClosureClose()
    }
 
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches began?")
        self.view.endEditing(true)
//        pickerClosureClose()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        print("rec gesture?")
        let lastIndex = IndexPath(row: self.theQuestions.count - 1, section: 0)
        if let nextView = self.tableView.cellForRow(at: lastIndex) {
            if let isDesc = touch.view?.isDescendant(of: nextView ) {
                // isKind(of: NextQuestionTableViewCell.classForCoder()))! {
                if isDesc {
                    return false
                }
            }
        }
        return true
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func uploadAnswerForQuestion(num: Int) {
        
        let guid  = theQuestions[num].questionID!
        
        let projectID  = "test lol"
        let questionSetID  = "test lol"
        let answerSetInstanceID  = "test lol"
        let backgroundID  =  self.currentItem!.imgPointer!
        let answerSetXPosition  = 88
        let answerSetYPosition  = 88
        let questionNum  = theQuestions[num].questionNumber!
        let answerType =  theQuestions[num].questionTypeNumber!
        
        let imgPointer = self.currentItem!.imgPointer
        let answer = "test lol"
     
        //SVProgressHUD.show()
        
        AlchemieAPI.shared.uploadAnswers(guid: guid,
                          projectID: projectID,
                          questionSetID: questionSetID,
                          answerSetInstanceID: answerSetInstanceID,
                          backgroundID: backgroundID,
                          answerSetXPosition: answerSetXPosition,
                          answerSetYPosition: answerSetYPosition,
                          questionNum: questionNum,
                          answerType: answerType,
                          imgPointer: imgPointer!,
                          answer: answer,
                          time: " ",
                          tabletID: " ",
                          completion:  {   success, response in
                            
                            if (success) {
                                print("lololz")
                                print(response)
                                self.uploadSuccessPopup()
                            }
                            else {
                                self.errorPopup()
                            }
                            SVProgressHUD.dismiss()
                            // self.questionsLoaded = true
                            //if (self.checkIfEverythingLoaded()){
                            //    SVProgressHUD.dismiss()
                            //}
        })
    }
    
    
    func questionsUpload() {
        
        let dispatchGroup = DispatchGroup()
        var successCount = 0
        var failCount = 0
        
        SVProgressHUD.show()
        
        for oneQuestion in theQuestions {
            
            if (oneQuestion.questionType == .next) {
                continue
            }
            var answer = oneQuestion.questionAnswer!
            
            var questionNum  = 0
            if (oneQuestion.questionType == .photo) {
                answer = "photo"
                questionNum = 1
            }
            else if (answer == "") {
                continue
            }
                
            let guid  = oneQuestion.questionID!
            //let guidd  = oneQuestion.parentQuestionSetID!
        
            let projectID  = guid //oneQuestion.questionID! //oneQuestion.parentQuestionSetID!
            let questionSetID  = oneQuestion.parentQuestionSetID! // oneQuestion.parentQuestionSetID! //questionSetID!
            let answerSetInstanceID  = oneQuestion.questionID! //oneQuestion.parentQuestionSetID!
            let backgroundID  =  self.currentItem!.imgPointer!
            let answerSetXPosition  = Int(self.answerSetXPosition!)
            let answerSetYPosition  = Int(self.answerSetYPosition!)
            let answerType = oneQuestion.questionTypeNumber! //theQuestions[0].questionTypeNumber!
        
            let imgPointer = self.currentItem!.imgPointer
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            let dateTime = formatter.date(from: "2016/10/08 22:31")
            let dateString = dateTime?.description
            
            let device_id = UIDevice.current.identifierForVendor?.uuidString
            
            
            dispatchGroup.enter()
            AlchemieAPI.shared.uploadAnswers(guid: guid,
                              projectID: projectID,
                              questionSetID: questionSetID,
                              answerSetInstanceID: answerSetInstanceID,
                              backgroundID: backgroundID,
                              answerSetXPosition: answerSetXPosition,
                              answerSetYPosition: answerSetYPosition,
                              questionNum: questionNum,
                              answerType: answerType,
                              imgPointer: imgPointer!,
                              answer: answer,
                              time: dateString!,
                              tabletID: device_id!,
                              completion:  {   success, response in
                                
                                if (success) {
                                    print("lololz")
                                    print(response)
                                    successCount += 1
                                }
                                else {
                                    failCount += 1
                                }
                                dispatchGroup.leave()
                                
            })
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            // completion?(storedError)
            print("uploads Done!!")
            if failCount == 0 {
                self.uploadSuccessPopup()
            }
            else if successCount == 0 {
                self.errorPopup()
            }
            else {
                self.partialErrorPopup(num: failCount)
            }
            SVProgressHUD.dismiss()
        }
        
    }
    
    
    func saveAnswers() {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        SVProgressHUD.show()
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let buttonID = self.currentButton?.buttonInstanceID
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDQuestionListInstance")
        
        fetchRequest.predicate = NSPredicate(format: "questionInstanceID == %@", buttonID!)
        
        do {
            
            let instanceToUpdate = try managedContext.fetch(fetchRequest)
            var theInstanceToUpdate: NSManagedObject?
            
            if ( instanceToUpdate.count > 0) {
                 theInstanceToUpdate = instanceToUpdate[0]
    
    //            let entity = NSEntityDescription.entity(forEntityName: "CDQuestionSet",
    //                                           in: managedContext)!
    //
    //            let cdQuestionSet = NSManagedObject(entity: entity,
    //                                                insertInto: managedContext)
     
                
                for (key, value) in (self.currentButton?.answersMap)!  {
                    print("saving \(value) with num \(key) on \(String(describing: self.currentButton?.buttonInstanceID!))")
                    
                    let entityList =
                        NSEntityDescription.entity(forEntityName: "CDQuestionAnswer",
                                                   in: managedContext)!
                    let cdQuestionListAnswer = NSManagedObject(entity: entityList,
                                                               insertInto: managedContext)
                    
                    cdQuestionListAnswer.setValue(self.currentButton?.buttonInstanceID!,     forKeyPath: "parentButtonID")
                    cdQuestionListAnswer.setValue(value,     forKeyPath: "questionAnswerText")
                    cdQuestionListAnswer.setValue(key,     forKeyPath: "questionNumber")
                    
                    let set = NSSet(object: cdQuestionListAnswer)
                    
                    theInstanceToUpdate?.setValue(set, forKey: "questionListAnswers")
                    
                }
                
//                for oneQuestion in self.theQuestions {
//
//                    print("saving \(oneQuestion.questionText) with num \(oneQuestion.questionNumber) on \(self.currentButton?.buttonInstanceID!)")
//
//                    let entityList =
//                        NSEntityDescription.entity(forEntityName: "CDQuestionAnswer",
//                                                   in: managedContext)!
//                    let cdQuestionListAnswer = NSManagedObject(entity: entityList,
//                                                         insertInto: managedContext)
//
//
//                    cdQuestionListAnswer.setValue(self.currentButton?.buttonInstanceID!,     forKeyPath: "parentButtonID")
//                    cdQuestionListAnswer.setValue(oneQuestion.parentQuestionSetID,     forKeyPath: "parentQuestionSetID")
//                    cdQuestionListAnswer.setValue(oneQuestion.questionAnswer,     forKeyPath: "questionAnswerText")
//                    cdQuestionListAnswer.setValue(oneQuestion.questionNumber,     forKeyPath: "questionNumber")
//                    cdQuestionListAnswer.setValue(oneQuestion.questionTypeNumber,     forKeyPath: "questionTypeNumber")
//
//
//                    let set = NSSet(object: cdQuestionListAnswer)
//
//                    theInstanceToUpdate?.setValue(set, forKey: "questionListAnswers")
//                }
            }
            else {
                
                let itemfetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDItem")
                
                itemfetchRequest.predicate = NSPredicate(format: "itemID == %@", self.currentItem!.itemID!)
                
                let themanaged_Items = try managedContext.fetch(itemfetchRequest)
                
                let onemanaged_Item = themanaged_Items[0]
                
                let entity = NSEntityDescription.entity(forEntityName: "CDQuestionListInstance", in: managedContext)!
                
                theInstanceToUpdate = NSManagedObject(entity: entity,
                                                         insertInto: managedContext)
                
                
                let id = self.currentButton?.getButtonID()
//                if(buttonIDSet.contains(id)){
//                    continue
//                }
//                else {
//                    buttonIDSet.insert(id)
//                }
                let parentItemID = self.currentItem?.itemID
                let center = self.currentButton?.getLocation()
                let centerData = NSKeyedArchiver.archivedData(withRootObject: center)
                let qsetID = self.currentButton?.questionSetID
                let type = 0 //button.getType()
                
                theInstanceToUpdate?.setValue(parentItemID, forKey: "parentItemID")
                theInstanceToUpdate?.setValue(id, forKey: "questionInstanceID")
                theInstanceToUpdate?.setValue(centerData, forKey: "buttonCenterPoint")
                theInstanceToUpdate?.setValue(qsetID, forKey: "questionSetID")
                theInstanceToUpdate?.setValue(type, forKey: "questionInstanceType")
                
                for (key, value) in (self.currentButton?.answersMap)! {
                    
                    let entityList =
                        NSEntityDescription.entity(forEntityName: "CDQuestionAnswer",
                                                   in: managedContext)!
                    let cdQuestionListAnswer = NSManagedObject(entity: entityList,
                                                               insertInto: managedContext)
                    
                    
                    print("saving \(value) with num \(key) on \(String(describing: self.currentButton?.buttonInstanceID!))")
                    
                    
                    cdQuestionListAnswer.setValue(self.currentButton?.buttonInstanceID!,     forKeyPath: "parentButtonID")
                    cdQuestionListAnswer.setValue(value,     forKeyPath: "questionAnswerText")
                    cdQuestionListAnswer.setValue(key,     forKeyPath: "questionNumber")
                    
                    //                if (oneQuestion.questionType == .photo) {
                    //
                    //                }
                    
                    let set = NSSet(object: cdQuestionListAnswer)
                    
                    theInstanceToUpdate?.setValue(set, forKey: "questionListAnswers")
                }
//                for oneQuestion in self.theQuestions {
//
//                    let entityList =
//                        NSEntityDescription.entity(forEntityName: "CDQuestionAnswer",
//                                                   in: managedContext)!
//                    let cdQuestionListAnswer = NSManagedObject(entity: entityList,
//                                                               insertInto: managedContext)
//
//
//                    print("saving \(oneQuestion.questionText) with num \(oneQuestion.questionNumber) on \(self.currentButton?.buttonInstanceID!)")
//
//
//                    cdQuestionListAnswer.setValue(self.currentButton?.buttonInstanceID!,     forKeyPath: "parentButtonID")
//                    cdQuestionListAnswer.setValue(oneQuestion.parentQuestionSetID,     forKeyPath: "parentQuestionSetID")
//                    cdQuestionListAnswer.setValue(oneQuestion.questionAnswer,     forKeyPath: "questionAnswerText")
//                    cdQuestionListAnswer.setValue(oneQuestion.questionNumber,     forKeyPath: "questionNumber")
//                    cdQuestionListAnswer.setValue(oneQuestion.questionTypeNumber,     forKeyPath: "questionTypeNumber")
//                    // cdQuestionListAnswer.setValue(self.currentButton.     forKeyPath: "parentIconNumber")
//
//                    //                if (oneQuestion.questionType == .photo) {
//                    //
//                    //                }
//
//                    let set = NSSet(object: cdQuestionListAnswer)
//
//                    theInstanceToUpdate?.setValue(set, forKey: "questionListAnswers")
//                }
                
                onemanaged_Item.setValue(NSSet(object: theInstanceToUpdate!), forKey: "questionListInstance")
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
                let currentTime = dateFormatter.string(from: date)
                onemanaged_Item.setValue(currentTime,     forKeyPath: "timeAnswered")
            }
         
        }
        catch  let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        SVProgressHUD.dismiss()
        
    }
    
    func loadAnswers() {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        var theItems = [AnyObject]()
        var theManagedItems = [NSManagedObject]()
        
//        let questionInstanceAnswerfetchRequest =
//            NSFetchRequest<NSManagedObject>(entityName: "CDQuestionAnswer")
//
//        questionInstancefetchRequest.predicate = NSPredicate(format: "parentButtonID == %@", oneButton.buttonInstanceID!)
//
        
        do {
             
            print("begin fetch")
            
            let questionInstanceAnswerfetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "CDQuestionAnswer")
            
            questionInstanceAnswerfetchRequest.predicate = NSPredicate(format: "parentButtonID == %@", (self.currentButton?.buttonInstanceID)!)
            
            let theAnswers = try managedContext.fetch(questionInstanceAnswerfetchRequest)
            
            
            for oneAnswer in theAnswers {
                
                let text = oneAnswer.value(forKeyPath: "questionAnswerText") as? String
                let number = oneAnswer.value(forKeyPath: "questionNumber") as? Int
                
                print("loading \(text!) with \(number!) from \((self.currentButton?.buttonInstanceID)!)")
                
                self.currentButton?.addToAnswerMap(answer: text!, key: number!)
                
                
            }
            self.tableView.reloadData()
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func clearAnswers() {
        for question in theQuestions {
            question.questionAnswer = ""
        }
        for question in (currentButton?.getQuestions())! {
            question.questionAnswer = ""
        }
        self.tableView.reloadData()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // questionsUpload()
        // saveAnswers()
        saveQuestionsPopup(completion: {
            self.saveAnswers()
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    
    
    @IBAction func discardButtonPressed(_ sender: Any) {
        
//        let guid  = theQuestions[0].questionSetID
//
//        let api = AlchemieAPI()
//
//        api.downloadAnswers(guid: guid!, completion:  {   success, response in
//            print(response)
//        })
        clearAnswers()
        self.navigationController?.popViewController(animated: true)
    }
    
}





extension QuestionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == self.popuptableView) {
            return 3
        }
        
        return theQuestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if (tableView == self.popuptableView) {
            
            let cell = UITableViewCell()
            
            cell.textLabel?.text = "test" //  self.pickerAnswers[indexPath.row].answerListitemtext
            
            print("   ------    ")
            print("   \(self.pickerAnswers)")
            print("   ------    ")
            
            return cell
        }
        
        
        var type:Question.QuestionTypes? //  = theQuestions[indexPath.row].questionType
        var text:String? // = theQuestions[indexPath.row].questionText
        var number:Int?
        //theQuestions[indexPath.row].questionNumber = indexPath.row+1
        
        var theQuestion:Question? //  = theQuestions[indexPath.row]
        var theAnswer:String?
        
        if let everyQuestion = self.currentButton?.getQuestions() {
            
            if (indexPath.row < everyQuestion.count) {
                let oneq = everyQuestion[indexPath.row]
                type = everyQuestion[indexPath.row].questionType
                text = everyQuestion[indexPath.row].questionText
                number = everyQuestion[indexPath.row].questionNumber
                theQuestion = oneq
            }
        }
        else {
            theQuestion = theQuestions[indexPath.row]
            type = theQuestions[indexPath.row].questionType
            text = theQuestions[indexPath.row].questionText
            number = theQuestions[indexPath.row].questionNumber
        }
        
        if (type == .text) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell") as! TextQuestionTableViewCell
            let textString = "  \(indexPath.row+1).  \(String(describing: text!))"
            cell.textLabel?.text = nil
            cell.detailTextLabel?.text = nil
            cell.row = indexPath.row
            cell.pickerClosureCloseWithAnsPlusRow = textClosureCloseWithAnsPlusRow
            cell.textFieldClosure = textFieldClosure
            cell.questionLabel.text = nil
            cell.questionLabel.text = textString
            
            if let answer = theQuestion?.questionAnswer {
                cell.questionText.text = answer
                
            }
            
            let answerString = self.currentButton?.getFromAnswersMap(key: (theQuestion?.questionNumber)!)
            cell.questionText.text = answerString
            
            return cell
        }
        else if (type == .yesOrNo) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "yesrOrNoCell") as! YesOrNoQuestionTableViewCell
            let textString = "  \(indexPath.row+1).  \(String(describing: text!))"
            cell.textLabel?.text = nil
            cell.row = indexPath.row
            cell.buttonClosureWithAns = buttonClosureWithAns
            cell.questionLabel.text = nil
            cell.questionLabel.text = textString
            
            
            // if
            let answer = self.currentButton?.getFromAnswersMap(key: (theQuestion?.questionNumber)!)
            //theQuestion?.questionAnswer {
            if answer == "yes" {
                cell.setYes()
            }
            else if answer == "no" {
                cell.setNo()
            }
            else {
                cell.setNone()
            }
            // }
            
            return cell
        }
        else if (type == .list) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") as! ListQuestionTableViewCell
            cell.reloadInputViews()
            let textString = "  \(indexPath.row+1).  \(String(describing: text!))"
            cell.textLabel?.text = nil
            cell.detailTextLabel?.text = nil
            cell.questionLabel.text = nil
            cell.questionLabel.text = textString
            cell.questionText.text = nil
            cell.row = indexPath.row
            cell.pickerQuestions = theQuestions[indexPath.row].getAnswersOptions()
            cell.pickerAnswers = theQuestions[indexPath.row].getAnswersOptionsObject()
            cell.pickerClosureOpen = pickerClosureOpen
            cell.pickerClosureClose = pickerClosureClose
            cell.pickerPositionClosure = setPickerPositionClosure
            cell.pickerQuestionsClosure = setPickerQuestionsClosure
            //cell.pickerClosureCloseWithAns = pickerClosureCloseWithAns
            cell.pickerClosureCloseWithAnsPlusRow = pickerClosureCloseWithAnsPlusRow
            cell.keyboardManageClosure = keyboardManageClosure
            cell.keyboardManageClosureClose = keyboardManageClosureClose
            if let answer = theQuestion?.questionAnswer {
                cell.questionText.text = answer
            }
            cell.questionText.text = self.currentButton?.getFromAnswersMap(key: (theQuestion?.questionNumber)!)
            return cell
        }
        else if (type == .listMulti) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "multiListCell") as! MultiListQuestionTableViewCell
            let textString = "  \(indexPath.row+1).  \(String(describing: text!))"
            cell.textLabel?.text = nil
            cell.questionLabel.text = nil
            cell.questionLabel.text = textString
            cell.questionText.text = nil
            cell.row = indexPath.row
            cell.pickerQuestions = theQuestions[indexPath.row].getAnswersOptions()
            cell.pickerAnswers = theQuestions[indexPath.row].getAnswersOptionsObject()
            cell.pickerClosureOpen = pickerClosureOpen
            cell.pickerClosureClose = pickerClosureClose
            cell.pickerPositionClosure = setPickerPositionClosure
            cell.pickerQuestionsClosure = setPickerQuestionsClosure
            // cell.pickerClosureCloseWithAnsMulti = pickerClosureCloseWithAnsMulti
            cell.pickerClosureCloseWithAnsPlusRow = pickerClosureCloseWithAnsPlusRowMulti
            cell.keyboardManageClosure = keyboardManageClosure
            cell.keyboardManageClosureClose = keyboardManageClosureClose
            if let answer = theQuestion?.questionAnswer {
                cell.questionText.text = answer
            }
            let ans = self.currentButton?.getFromAnswersMap(key: (theQuestion?.questionNumber)!)
            cell.questionText.text = ans
            return cell
        }
        else if (type == .photo) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell") as! PhotoQuestionTableViewCell
            cell.textLabel?.text = nil
            cell.questionNumber.text = " \(indexPath.row+1). "
            let textString = "\(String(describing: text!))"
            cell.row = indexPath.row
            cell.currentQuestionNumber = (theQuestion?.questionNumber)!
            cell.questionLabel.text = nil
            cell.questionLabel.text = textString
            cell.photoClosure = photoButtonClosure
            let key = (theQuestion?.questionNumber)!
            if let imgPointer = self.currentButton?.getFromAnswersMap(key: key) {
                //if let img = imageCache[indexPath.row] {
                if let img = ImageStore.sharedInstance.image(forKey: imgPointer) {
                    cell.photoButton.setBackgroundImage(img, for: .normal)
                    //imageStore.setImage(img, forKey: imgPointer!)
                }
                else {
                    cell.photoButton.setBackgroundImage(UIImage(named: "addPhoto") , for: .normal)
                }
            }
            else {
                cell.photoButton.setBackgroundImage(UIImage(named: "addPhoto") , for: .normal)
                
            }
            return cell
        }
        else if (type == .next) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nextQuestionCell") as! NextQuestionTableViewCell
            let textString = text!
            cell.textLabel?.text = nil
            cell.detailTextLabel?.text = nil
            //cell.row = indexPath.row
            cell.questionLabel.text = nil
            cell.questionLabel.text = textString
            return cell
        }
        
        let cell = UITableViewCell()
        /*
         let theText = theQuestions[indexPath.row].questionText
         cell.textLabel?.text = "  \(indexPath.row+1).  \(String(describing: theText!))"
         cell.textLabel?.font =  UIFont(name: "Courier", size: 30.0)
         //cell.textLabel?.textAlignment = .center
         */
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (tableView == self.popuptableView) {
            return
        }
        
        if (theQuestions.count ==  6) { /// 11) {
            return
        }
        let type = theQuestions[indexPath.row].questionType
        if (type == .next) {
            createNextRow()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (tableView == self.popuptableView) {
            return 100
        }
        
        var type :Question.QuestionTypes?
        // let type = theQuestionTypes[indexPath.row]
        if let everyQuestion = self.currentButton?.getQuestions() {
            if (indexPath.row < everyQuestion.count) {
                type = everyQuestion[indexPath.row].questionType
            }
        }
        else {
            type = theQuestions[indexPath.row].questionType
        }
        
        if (type == .text) {
            return 150
        }
        else if (type == .yesOrNo) {
            return 150
        }
        else if (type == .list) {
            return 150
        }
        else if (type == .listMulti) {
            return 150
        }
        else if (type == .photo) {
            return 165
        }
        else if (type == .next) {
            return 110
        }
        else {
            return 110
        }
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pickerClosureClose()
    }
}




extension QuestionsViewController: UIImagePickerControllerDelegate {
    // MARK: - Image Picker
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            theImage = pickedImage
            
            if let row = self.currentRow {
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? PhotoQuestionTableViewCell
                cell?.photoButton?.setBackgroundImage(self.theImage, for: .normal)
                //downscale image
                
                // save image
                
                let uniqueID = UUID().uuidString
                
                if (row < imageCache.count) {
                    imageCache[row] = self.theImage
                }
                
                if (row < theQuestions.count) {
//                    theQuestions[row].questionAnswer = uniqueID
                    let key = theQuestions[row].questionNumber
                    self.currentButton?.addToAnswerMap(answer: uniqueID, key: key!)
                }
                
                let qNum = self.currentQuestionNumber
//
                let imageStore = ImageStore.sharedInstance
                imageStore.setImage(pickedImage, forKey: uniqueID)
//                self.currentButton?.addToAnswerMap(answer: uniqueID, key: qNum!)
                self.tableView.reloadData()
                
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func photoButtonClosure(button: UIButton, row: Int, number:Int) {
        
        self.photoButton = button
        self.currentRow = row
        self.currentQuestionNumber = number
        
        let photoAlert = UIAlertController(title: "Photo Source", message: "What is the source of the photo?", preferredStyle: .actionSheet)
        let buttonView = UIView(frame: CGRect(x: button.frame.midX, y: button.frame.minY - 80, width: button.frame.width, height: button.frame.height))
        //
        photoAlert.popoverPresentationController?.sourceView = button
        photoAlert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { action in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let cameraAction  = UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        photoAlert.addAction(libraryAction)
        photoAlert.addAction(cameraAction)
        self.present(photoAlert, animated: true, completion: {
            print("done lololz")
        })
    }
}

extension QuestionsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerQuestions[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerQuestions.count
    }
    
}
