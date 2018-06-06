//
//  BigImageViewController.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/27/17.
//  Copyright © 2017 steve. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD

class BigImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var eraseIconsButton: UIButton!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var bigImage: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var bottomBackgroundView: UIView!
    
    
    
    var theImage:UIImage?
    
    let imageStore = ImageStore.sharedInstance
    
    var touchedLocation = CGPoint(x: 0.0, y: 0.0)
    
    var currentOption:Option?
    var currentSubOption:SubOption?
    var currentItem:Item?
    var currentButton: QuestionButton?
    
    // var questions = [QuestionSet]()
    
    @IBOutlet weak var stackView: UIStackView!
    
    
    
    @IBOutlet weak var buttonOne: QuestionButton!
    @IBOutlet weak var buttonTwo: QuestionButton!
    @IBOutlet weak var buttonThree: QuestionButton!
    
    var buttonImageOne: UIImage?
    var buttonImageTwo: UIImage?
    var buttonImageThree: UIImage?
    
    var onDismiss: ( (UIView)  -> (UIImage) )?
    
    var thumbnailImageView: UIImageView?
    
    
    var buttonOnes = [QuestionButton]()
    var buttonTwos = [QuestionButton]()
    var buttonThrees = [QuestionButton]()
    
    var panGestureOne   = UIPanGestureRecognizer()
    var panGestureTwo   = UIPanGestureRecognizer()
    var panGestureThree = UIPanGestureRecognizer()
    
    var answerSetXPosition:Double?
    var answerSetYPosition:Double?
    
    let api = AlchemieAPI()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        bigImage.image = theImage
        
        // Do any additional setup after loading the view.
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 3.5
        self.scrollView.delegate = self;
        
        self.view.isUserInteractionEnabled = true
        self.buttonOne.isUserInteractionEnabled = true
        self.stackView.isUserInteractionEnabled = true
        self.bigImage.isUserInteractionEnabled = true
        self.scrollView.isUserInteractionEnabled = true
        
        self.buttonOne.layer.cornerRadius = 10
        self.buttonTwo.layer.cornerRadius = 10
        self.buttonThree.layer.cornerRadius = 10
        
        // draggable buttons
        
        panGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonOne(_:) ) )
        panGestureTwo   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonTwo(_:) ) )
        panGestureThree = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonThree(_:) ) )
        
        self.buttonOne.isUserInteractionEnabled = true
        self.buttonOne.addGestureRecognizer(panGestureOne)
        
        self.buttonTwo.isUserInteractionEnabled = true
        self.buttonTwo.addGestureRecognizer(panGestureTwo)
        
        self.buttonThree.isUserInteractionEnabled = true
        self.buttonThree.addGestureRecognizer(panGestureThree)
      
        
        self.view.bringSubview(toFront: eraseIconsButton)
        
        
        self.uploadButton.layer.cornerRadius = 15
        
        
        let questionSetCount = self.currentOption?.questionSetList.count
        print("we have \(questionSetCount!) questions sets here")
        
        
        if (questionSetCount! >= 3 ) {
            let keyOne = self.currentOption?.questionSetList[0].surveyIconPointer
            self.buttonImageOne = self.imageStore.image(forKey: keyOne!)
            let keyTwo = self.currentOption?.questionSetList[1].surveyIconPointer
            self.buttonImageTwo = self.imageStore.image(forKey: keyTwo!)
            let keyThree = self.currentOption?.questionSetList[2].surveyIconPointer
            self.buttonImageThree = self.imageStore.image(forKey: keyThree!)
            DispatchQueue.main.async {
                self.buttonOne.setImage(self.buttonImageOne, for: .normal)
                self.buttonTwo.setImage(self.buttonImageTwo, for: .normal)
                self.buttonThree.setImage(self.buttonImageThree, for: .normal)
                self.setUpInitialPanGesturesOne()
                self.setUpInitialPanGesturesTwo()
                self.setUpInitialPanGesturesThree()
            }
        }
        else if (questionSetCount! == 2) {
            self.buttonThree.isEnabled = false
            self.buttonThree.isHidden = true
            removeButtonThrees()
            let keyOne = self.currentOption?.questionSetList[0].surveyIconPointer
            self.buttonImageOne = self.imageStore.image(forKey: keyOne!)
            let keyTwo = self.currentOption?.questionSetList[1].surveyIconPointer
            self.buttonImageTwo = self.imageStore.image(forKey: keyTwo!)
            DispatchQueue.main.async {
                self.buttonOne.setImage(self.buttonImageOne, for: .normal)
                self.buttonTwo.setImage(self.buttonImageTwo, for: .normal)
                self.setUpInitialPanGesturesOne()
                self.setUpInitialPanGesturesTwo() 
            }
        }
        else if (questionSetCount! == 1){
            self.buttonOne.isEnabled = false
            self.buttonOne.isHidden = true
            self.buttonThree.isEnabled = false
            self.buttonThree.isHidden = true
            removeButtonOnes()
            removeButtonThrees()
            let keyOne = self.currentOption?.questionSetList[0].surveyIconPointer
            self.buttonImageTwo = self.imageStore.image(forKey: keyOne!)
            DispatchQueue.main.async {
                self.buttonTwo.setImage(self.buttonImageTwo, for: .normal)
                self.setUpInitialPanGesturesTwo()
            }
        }
        else if (questionSetCount! == 0){
            self.buttonOne.isEnabled = false
            self.buttonOne.isHidden = true
            self.buttonTwo.isEnabled = false
            self.buttonTwo.isHidden = true
            self.buttonThree.isEnabled = false
            self.buttonThree.isHidden = true
            removeButtonOnes()
            removeButtonTwos()
            removeButtonThrees()
        }
        
        // getThreeButtonPositionOnImage()
        
        placeButtonsOnImage()
        
        printIconPositions()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveOperation()
    }
    
    func copyQuestionArray(questionList: [Question]) {
        
    }
//
//    func setUpInitialPanGestures() {
//
//        let copyButtonOne = buttonOne.copyButton()
//        // var copyArrayOne = self.currentOption!.questionSetList[0].questionList
////        copyButtonOne.setQuestions(questions: copyArrayOne)
//        copyButtonOne.setQuestions(questions: self.currentOption!.questionSetList[0].questionList)
//        copyButtonOne.isUserInteractionEnabled = true
//        let panGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
//        copyButtonOne.addGestureRecognizer(panGestureOne)
//        copyButtonOne.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
//        self.buttonOnes.append(copyButtonOne)
//        self.view.addSubview(copyButtonOne)
//
//        let copyButtonTwo = buttonTwo.copyButton()
//        // var copyArrayTwo = self.currentOption!.questionSetList[1].questionList
//        // copyButtonTwo.setQuestions(questions: copyArrayTwo)
//        copyButtonOne.setQuestions(questions: self.currentOption!.questionSetList[1].questionList)
//        copyButtonTwo.isUserInteractionEnabled = true
//        let panGestureTwo   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
//        copyButtonTwo.addGestureRecognizer(panGestureTwo)
//        copyButtonTwo.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
//        self.buttonTwos.append(copyButtonTwo)
//        self.view.addSubview(copyButtonTwo)
//
//        let copyButtonThree = buttonThree.copyButton()
//        // var copyArrayThree = self.currentOption!.questionSetList[2].questionList
//        // copyButtonThree.setQuestions(questions: copyArrayThree)
//        copyButtonOne.setQuestions(questions: self.currentOption!.questionSetList[2].questionList)
//        copyButtonThree.isUserInteractionEnabled = true
//        let panGestureThree = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
//        copyButtonThree.addGestureRecognizer(panGestureThree)
//        copyButtonThree.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
//        self.buttonThrees.append(copyButtonThree)
//        self.view.addSubview(copyButtonThree)
//
//    }
    
    func setUpInitialPanGesturesOne() {
        let copyButtonOne = buttonOne.copyButton()
        // copyButtonOne.setQuestions(questions: copyArrayOne)
        copyButtonOne.setQuestions(questions: self.currentOption!.questionSetList[0].questionList)
        copyButtonOne.isUserInteractionEnabled = true
        let panGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButtonOne.addGestureRecognizer(panGestureOne)
        copyButtonOne.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        copyButtonOne.setImage(self.buttonImageOne, for: .normal)
        copyButtonOne.setType(typeInt: 0)
        self.buttonOnes.append(copyButtonOne)
        self.view.addSubview(copyButtonOne)
    }
    
    func setUpInitialPanGesturesTwo() {
        let copyButtonTwo = buttonTwo.copyButton()
        // copyButtonTwo.setQuestions(questions: copyArrayTwo)
        copyButtonTwo.setQuestions(questions: self.currentOption!.questionSetList[1].questionList)
        copyButtonTwo.isUserInteractionEnabled = true
        let panGestureTwo   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButtonTwo.addGestureRecognizer(panGestureTwo)
        copyButtonTwo.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        // copyButtonTwo.imageView?.image = self.buttonImageTwo
        copyButtonTwo.setImage(self.buttonImageTwo, for: .normal)
        copyButtonTwo.setType(typeInt: 1)
        self.buttonTwos.append(copyButtonTwo)
        self.view.addSubview(copyButtonTwo)
    }
    
    
    func setUpInitialPanGesturesThree() {
        let copyButtonThree = buttonThree.copyButton()
        // copyButtonThree.setQuestions(questions: copyArrayThree)
        copyButtonThree.setQuestions(questions: self.currentOption!.questionSetList[2].questionList)
        copyButtonThree.isUserInteractionEnabled = true
        let panGestureThree = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButtonThree.addGestureRecognizer(panGestureThree)
        copyButtonThree.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        copyButtonThree.setImage(self.buttonImageThree, for: .normal)
        copyButtonThree.setType(typeInt: 2)
        self.buttonThrees.append(copyButtonThree)
        self.view.addSubview(copyButtonThree)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.bigImage
    }
    
    func getQuestionSetFromJSON(withJSON json:[[String: AnyObject]] ) -> [QuestionSet] {
        
        var theQuestions = [QuestionSet]()
        for questionSet in json {
            //guard let optionName = option["OptionName"] as? String else {
            //    print("somethings wrong with the data")
            //     return [AnyObject]()
            //}
            let oneQuestionSet = QuestionSet()
            
            var setCompanyNum = 0
            var setID         = " "
            var setSurveyIconPointer = " "
            var setSurveyName = " "
            var setSurveyType = " "
            
            if let questionSetCompanyNum = questionSet["CompanyNum"] as? Int {
                //print("somethings wrong with the data")
                //return [QuestionSet]()
                setCompanyNum = questionSetCompanyNum
            }
            else {
                setCompanyNum = 0
            }
            if let  questionSetID = questionSet["ID"] as? String   {
                //print("somethings wrong with the data")
                //return [QuestionSet]()
                setID = questionSetID
            }
            
            if let questionSetSurveyIcon = questionSet["SurveyIconPointer"] as? String  {
                //print("somethings wrong with the data")
                //let questionSetSurveyIcon = "  "
                //return [QuestionSet]()
                setSurveyIconPointer = questionSetSurveyIcon
                print("pointer icon \(setSurveyIconPointer) ")
                
                if let  questionSetSurveyName = questionSet["SurveyName"] as? String {
                    setSurveyName = questionSetSurveyName
                    // return [QuestionSet]()
                    
                    if (setSurveyName == "Question Set 1") {
                        print("q one")
                        api.downloadImageForButton (button: self.buttonOne, imgPointer: setSurveyIconPointer)
                    }
                    else if (setSurveyName == "Question Set 2") {
                        print("q two")
                        api.downloadImageForButton (button: self.buttonTwo, imgPointer: setSurveyIconPointer)
                    }
                    else if (setSurveyName == "Question Set 3") {
                        print("q three")
                        api.downloadImageForButton (button: self.buttonThree, imgPointer: setSurveyIconPointer)
                    }
                    
                }
                else {
                    print("somethings wrong with the data")
                    setSurveyName  = "  "
                }
                
            }
            else {
                print("pointer icon not there")
            }
            
            if let  questionSetSurveyType = questionSet["SurveyType"] as? String  {
                //print("somethings wrong with the data")
                //return [QuestionSet]()
                setSurveyType = questionSetSurveyType
            }
            
            oneQuestionSet.companyNum = setCompanyNum
            oneQuestionSet.theID      = setID
            oneQuestionSet.surveyIconPointer = setSurveyIconPointer
            oneQuestionSet.surveyName = setSurveyName
            oneQuestionSet.surveyType = setSurveyType
            
            guard let questionList = questionSet["QuesList"] as? [[String: AnyObject]] else {
                print("somethings wrong with the data")
                return [QuestionSet]()
            }
            
            for oneQuestion in questionList  {
                
                let question = Question()
                var qSetID = " "
                var qText = " "
                
                if let questionSetID = oneQuestion["QuestionSetID"] as? String  {
                    qSetID = questionSetID
                }
                
                if let questionText = oneQuestion["QuestionText"] as? String {
                    qText = questionText
                }
                
                question.questionID = qSetID
                question.questionText = qText
                print("hopefully added \(qText)")
                oneQuestionSet.questionList.append(question)
            }
            theQuestions.append(oneQuestionSet)
        }
        return theQuestions
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

//
//    @IBAction func buttonOnePressed(_ sender: Any) {
//        //self.performSegue(withIdentifier: "toQuestions", sender: self)
//    }
//
//    @IBAction func buttonTwoPressed(_ sender: Any) {
//        //print("button two pressed!!")
//        //self.performSegue(withIdentifier: "toQuestions", sender: self)
//    }
//
//    @IBAction func buttonThreePressed(_ sender: Any) {
//        //print("button three pressed!!")
//        //self.performSegue(withIdentifier: "toQuestions", sender: self)
//
//    }
//
    
    @objc func buttonPressed(_ sender: Any) {
        //print("copy button pressed!!")
        let button = sender as! QuestionButton
        let point = button.center
        let rect = scrollView.frame
        self.answerSetXPosition = Double(button.center.x)
        self.answerSetYPosition = Double(button.center.y)
        if (rect.contains(point)) {
            self.currentButton = button
            self.performSegue(withIdentifier: "toQuestions", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toQuestions") {
            let viewController = segue.destination as! QuestionsViewController
            if let option = currentOption {
                viewController.currentOption = self.currentOption
                viewController.currentSubOption = self.currentSubOption
                viewController.currentButton = self.currentButton
                viewController.currentItem = self.currentItem
                viewController.answerSetXPosition = self.answerSetXPosition
                viewController.answerSetYPosition = self.answerSetXPosition
                
                if (self.currentButton?.tag == 3){
                    // viewController.theQuestions = option.questionSetList[2].questionList
                    //viewController.currentButton?.setQuestions(questions: option.questionSetList[2].questionList)
                }
                else if (self.currentButton?.tag == 2) {
                    // viewController.theQuestions = option.questionSetList[1].questionList
                    //viewController.currentButton?.setQuestions(questions: option.questionSetList[1].questionList)
                }
                else if (self.currentButton?.tag == 1) {
                    // viewController.theQuestions = option.questionSetList[0].questionList
                    //viewController.currentButton?.setQuestions(questions: option.questionSetList[0].questionList)
                }
                
            }
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        //saveOperation()
        self.navigationController?.popViewController(animated: false)
    }
    
    func saveOperation() {
        let editedImage = onDismiss!(self.view);
        thumbnailImageView?.image = editedImage
        currentItem?.editedImage = editedImage
        getIconPositionsAndSaveToCoreData()
        self.currentItem?.buttonOnes = buttonOnes
        self.currentItem?.buttonTwos = buttonTwos
        self.currentItem?.buttonThrees = buttonThrees
    }
    
    func removeButtonOnes() {
        for b in buttonOnes {
            self.view.willRemoveSubview(b)
            b.removeFromSuperview()
        }
        buttonOnes.removeAll()
    }
    
    func removeButtonTwos() {
        for b in buttonTwos {
            self.view.willRemoveSubview(b)
            b.removeFromSuperview()
        }
        buttonTwos.removeAll()
    }
    
    func removeButtonThrees() {
        for b in buttonThrees {
            self.view.willRemoveSubview(b)
            b.removeFromSuperview()
        }
        buttonThrees.removeAll()
    }
    
    @IBAction func eraseIconsButtonPressed(_ sender: Any) {
        
        //printIconPositions()
        print("erase icons button pressed")
        for b in buttonOnes {
            self.view.willRemoveSubview(b)
            b.removeFromSuperview()
        }
        for b in buttonTwos {
            self.view.willRemoveSubview(b)
            b.removeFromSuperview()
        }
        for b in buttonThrees {
            self.view.willRemoveSubview(b)
            b.removeFromSuperview()
        }
        buttonOnes.removeAll()
        buttonTwos.removeAll()
        buttonThrees.removeAll()
        bigImage.image = currentItem?.originalImage
        
    }
    
    
//    func placeButtonsOnImage() {
//        if let buttonList = currentItem?.buttonOnes {
//            for button in buttonList {
//                addButtonOnPosition(button: button)
//            }
//        }
//
//        if let buttonList = currentItem?.buttonTwos {
//            for button in buttonList {
//                addButtonOnPosition(button: button)
//            }
//        }
//
//        if let buttonList = currentItem?.buttonThrees {
//            for button in buttonList {
//                addButtonOnPosition(button: button)
//            }
//        }
//    }
    
    func placeButtonsOnImage() {
        
        var buttonIdSet = Set<String>()
        var buttonPoint = Set<CGFloat>()
        
        if let buttonList = currentItem?.buttonOnes {
            for button in buttonList {
                let pointHash = button.getLocation().x * 1000 + button.getLocation().y
                if (!buttonIdSet.contains(button.buttonInstanceID!) &&
                    !buttonPoint.contains(pointHash)) {
                    buttonIdSet.insert(button.buttonInstanceID!)
                    buttonPoint.insert(pointHash)
                    addButtonOnPosition(button: button)
                }
                else {
                    print("dupe found")
                    continue
                }
            }
        }
        
        if let buttonList = currentItem?.buttonTwos {
            for button in buttonList {
                let pointHash = button.getLocation().x * 1000 + button.getLocation().y
                if (!buttonIdSet.contains(button.buttonInstanceID!) &&
                    !buttonPoint.contains(pointHash)){
                    buttonIdSet.insert(button.buttonInstanceID!)
                    buttonPoint.insert(pointHash)
                    addButtonOnPosition(button: button)
                }
                else {
                    print("dupe found")
                    continue
                }
                // addButtonOnPosition(button: button) //, buttonTypeArray: &buttonTwos)
            }
        }
        
        if let buttonList = currentItem?.buttonThrees {
            for button in buttonList {
                let pointHash = button.getLocation().x * 1000 + button.getLocation().y
                if (!buttonIdSet.contains(button.buttonInstanceID!) &&
                    !buttonPoint.contains(pointHash)){
                    buttonIdSet.insert(button.buttonInstanceID!)
                    buttonPoint.insert(pointHash)
                    addButtonOnPosition(button: button)
                }
                else {
                    print("dupe found")
                    continue
                }
                // addButtonOnPosition(button: button) //, buttonTypeArray: &buttonThrees)
            }
        }
    }
    
    func getThreeButtonPositionOnImage() {
        
        if let positionslist = currentItem?.questionIconPositionsOne {
            for position in  positionslist {
                addButtonOneOnPosition(positionCenter: position, buttonTypeArray: &buttonOnes)
            }
        }
        
        if let positionslist = currentItem?.questionIconPositionsTwo {
            for position in positionslist  {
                addButtonTwoOnPosition(positionCenter: position, buttonTypeArray: &buttonTwos)
            }
        }
        
        if let positionslist = currentItem?.questionIconPositionsThree {
            for position in positionslist  {
                addButtonThreeOnPosition(positionCenter: position, buttonTypeArray: &buttonThrees)
            }
        }
    }
    
    
//    func addButtonOnPosition(positionCenter: CGPoint, buttonTypeArray: inout [QuestionButton]){
//        let buttonView = QuestionButton() // sender.view as! UIButton
//        //let translation = sender.translation(in: self.view)
//        buttonView.center   = positionCenter
//        // CGPoint(x: buttonView.center.x + translation.x , y: buttonView.center.y + translation.y)
//        //sender.setTranslation(CGPoint.zero, in: self.view)
//        buttonTypeArray.append(buttonView)
//        self.bigImage.addSubview(buttonView)
//        //view.addSubview(buttonView)
//    }
    
    // iwth same id. veryy important
    func addButtonOnPosition(button: QuestionButton ){
        let buttonView = buttonOne.copyButton()
        buttonView.clearAnswers()
        let newPanGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        buttonView.isUserInteractionEnabled = true
        buttonView.addGestureRecognizer(newPanGestureOne)
        buttonView.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        buttonView.center   = button.getLocation()
        buttonView.buttonInstanceID = button.buttonInstanceID
        buttonView.setLocation(point: button.getLocation())
        if (button.getType() == 0) {
            buttonView.setType(typeInt: 0)
            buttonView.setQuestions(questions: self.currentOption!.questionSetList[0].questionList)
            buttonView.setImage(self.buttonImageOne, for: .normal)
            self.buttonOnes.append(buttonView)
            // let keyOne = self.currentOption?.questionSetList[0].surveyIconPointer
            //buttonView.imageView?.image = self.imageStore.image(forKey: keyOne!)
        }
        else if (button.getType() == 1) {
            buttonView.setType(typeInt: 1)
            buttonView.setQuestions(questions: self.currentOption!.questionSetList[1].questionList)
            buttonView.setImage(self.buttonImageTwo, for: .normal)
            self.buttonTwos.append(buttonView)
        }
        else if (button.getType() == 2) {
            buttonView.setType(typeInt: 2)
            buttonView.setQuestions(questions: self.currentOption!.questionSetList[2].questionList)
            buttonView.setImage(self.buttonImageThree, for: .normal)
            self.buttonThrees.append(buttonView)
        }
        else {
            return
        }
        // buttonTypeArray.append(buttonView)
        self.bigImage.addSubview(buttonView)
        //view.addSubview(buttonView)
    }
    
    func addButtonOnPosition(button: QuestionButton, buttonTypeArray: inout [QuestionButton]){
        let buttonView = buttonOne.copyButton()
        buttonView.clearAnswers()
        let newPanGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        buttonView.isUserInteractionEnabled = true
        buttonView.addGestureRecognizer(newPanGestureOne)
        buttonView.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        buttonView.center   = button.getLocation()
        buttonView.setLocation(point: button.getLocation())
        if let buttonType = button.getType() {
            if (buttonType == 0) {
                buttonView.setType(typeInt: 0)
                buttonView.setQuestions(questions: self.currentOption!.questionSetList[0].questionList)
                buttonView.setImage(self.buttonImageOne, for: .normal)
                // let keyOne = self.currentOption?.questionSetList[0].surveyIconPointer
                //buttonView.imageView?.image = self.imageStore.image(forKey: keyOne!)
            }
            else if (buttonType == 1) {
                buttonView.setType(typeInt: 1)
                buttonView.setQuestions(questions: self.currentOption!.questionSetList[1].questionList)
                buttonView.setImage(self.buttonImageTwo, for: .normal)
            }
            else if (buttonType == 2) {
                buttonView.setType(typeInt: 2)
                buttonView.setQuestions(questions: self.currentOption!.questionSetList[2].questionList)
                buttonView.setImage(self.buttonImageThree, for: .normal)
            }
        }
        else {
            return
        }
        buttonTypeArray.append(buttonView)
        self.bigImage.addSubview(buttonView)
        //view.addSubview(buttonView)
    }
    
    func addButtonOneOnPosition(positionCenter: CGPoint, buttonTypeArray: inout [QuestionButton]){
        let buttonView = buttonOne.copyButton()
        buttonView.setQuestions(questions: self.currentOption!.questionSetList[0].questionList)
        buttonView.clearAnswers()
        let newPanGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        buttonView.isUserInteractionEnabled = true
        buttonView.addGestureRecognizer(newPanGestureOne)
        buttonView.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        buttonView.center   = positionCenter
        buttonView.setLocation(point: positionCenter)
        buttonView.setType(typeInt: 0)
        // let keyOne = self.currentOption?.questionSetList[0].surveyIconPointer
        // buttonView.imageView?.image = self.imageStore.image(forKey: keyOne!)
        buttonView.setImage(self.buttonImageOne, for: .normal)
        buttonTypeArray.append(buttonView)
        self.bigImage.addSubview(buttonView)
        // view.addSubview(buttonView)
    }
    
    func addButtonOneOnPositionWithAnswers(positionCenter: CGPoint, buttonTypeArray: inout [QuestionButton]){
        let buttonView = buttonOne.copyButton()
        var copyArray = self.currentOption!.questionSetList[0].questionList
        buttonView.setQuestions(questions: copyArray)
        // buttonView.clearAnswers()
        let newPanGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        buttonView.isUserInteractionEnabled = true
        buttonView.addGestureRecognizer(newPanGestureOne)
        buttonView.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        buttonView.center   = positionCenter
        buttonView.setLocation(point: positionCenter)
        buttonView.setType(typeInt: 0)
        // let keyOne = self.currentOption?.questionSetList[0].surveyIconPointer
        // buttonView.imageView?.image = self.imageStore.image(forKey: keyOne!)
        buttonView.setImage(self.buttonImageOne, for: .normal)
        buttonTypeArray.append(buttonView)
        self.bigImage.addSubview(buttonView)
        //view.addSubview(buttonView)
    }
    
    func addButtonTwoOnPosition(positionCenter: CGPoint, buttonTypeArray: inout [QuestionButton]){
        let buttonView = buttonTwo.copyButton()
        var copyArray = self.currentOption!.questionSetList[1].questionList
        buttonView.setQuestions(questions: copyArray)
        buttonView.clearAnswers()
        let newPanGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        buttonView.isUserInteractionEnabled = true
        buttonView.addGestureRecognizer(newPanGestureOne)
        buttonView.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        buttonView.center   = positionCenter
        buttonView.setLocation(point: positionCenter)
        buttonView.setType(typeInt: 1)
        let keyTwo = self.currentOption?.questionSetList[0].surveyIconPointer
        //buttonView.imageView?.image = self.imageStore.image(forKey: keyTwo!)
        buttonView.setImage(self.buttonImageTwo, for: .normal)
        buttonTypeArray.append(buttonView)
        self.bigImage.addSubview(buttonView)
        //view.addSubview(buttonView)
    }
    
    func addButtonThreeOnPosition(positionCenter: CGPoint, buttonTypeArray: inout [QuestionButton]){
        let buttonView = buttonThree.copyButton() // sender.view as! UIButton
        var copyArray = self.currentOption!.questionSetList[2].questionList
        buttonView.setQuestions(questions: copyArray)
        buttonView.clearAnswers()
        let newPanGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        buttonView.isUserInteractionEnabled = true
        buttonView.addGestureRecognizer(newPanGestureOne)
        buttonView.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        buttonView.center   = positionCenter
        buttonView.setLocation(point: positionCenter)
        buttonView.setType(typeInt: 2)
        let keyThree = self.currentOption?.questionSetList[2].surveyIconPointer
        // buttonView.imageView?.image = self.imageStore.image(forKey: keyThree!)
        buttonView.setImage(self.buttonImageThree, for: .normal)
        buttonTypeArray.append(buttonView)
        self.bigImage.addSubview(buttonView)
        //view.addSubview(buttonView)
    }
    
    ///////////////////
    //
    //    drop and drag
    //
    ///////////////////
    
    @objc func draggedButtonEvery(_ sender:UIPanGestureRecognizer) {
       
        let location = sender.location(in: bigImage)
        // print("the location: \(location)")
        
        let locationv = sender.location(in: self.view)
        // print("the location in view: \(locationv)")
        
        let buttonView = sender.view as! QuestionButton
        let point = buttonView.center
        let rect = scrollView.frame
        
        if sender.state == .began || sender.state == .changed {
        
            var translation:CGPoint?
            
            if (buttonView.superview == self.view) {
                translation = sender.translation(in: self.view)
            }
            else if (buttonView.superview == self.bigImage) {
                translation = sender.translation(in: self.bigImage)
            }
            //let translation = sender.translation(in: self.view)
            
            let xDif = location.x - locationv.x
            let yDif = location.y - locationv.y
            
            //buttonView.center   = CGPoint(x: buttonView.center.x + xDif,
            //                              y: buttonView.center.y + yDif)
            
            
            buttonView.center   = CGPoint(x: buttonView.center.x + translation!.x , y: buttonView.center.y + translation!.y)
            
            sender.setTranslation(CGPoint.zero, in: self.bigImage)
            
        }
        else if sender.state == .ended {
            //print("pan ended?")
            if (rect.contains(buttonView.frame)) {
                if (!bigImage.subviews.contains(buttonView)) {
                    //self.bigImage.addSubview(buttonView )
                    
                    // i dont this is the offiial apple way to convert between different coordinate systems but it works
                    let xDif = location.x - locationv.x
                    let yDif = location.y - locationv.y
                    
                    let buttonCenterPoint = CGPoint(x: buttonView.center.x + xDif,
                                                    y: buttonView.center.y + yDif)
                    
                    buttonView.center   = buttonCenterPoint
                   
                    buttonView.setLocation(point: buttonCenterPoint)
                    
                    self.view.willRemoveSubview(buttonView)
                    self.bigImage.addSubview(buttonView )
                    
                    // print("icon added to pic")
                }
            }
            else {
                // self.view.willRemoveSubview(buttonView)
                buttonView.removeFromSuperview()
                // self.view.addSubview(buttonView )
            }
            return
        }
    }
        // if (!self.view.bounds.intersects(copyButton.frame) ){
        //if (self.bigImage.bounds.intersects(buttonView.frame) ){
        //if (self.bigImage.bounds.contains(buttonView.center) ){
        //if (!self.bottomBackgroundView.bounds.contains(buttonView.frame)) {
        /*
        if (!self.bottomBackgroundView.bounds.contains(buttonView.frame)) {
            if (!bigImage.subviews.contains(buttonView)) {
                self.bigImage.addSubview(buttonView )
            }
        }
        else {
            self.view.addSubview(buttonView )
        }
        */
        
        /*
        if (rect.contains(point)) {
            //if (!scrollView.subviews.contains(buttonView)) {
            //    self.scrollView.addSubview(buttonView )
            //}
            if (!bigImage.subviews.contains(buttonView)) {
                self.bigImage.addSubview(buttonView )
            }
        }
        else {
            self.view.addSubview(buttonView )
        }
        */
        
        //self.view.addSubview(buttonView )
        
    //}
    
    @objc func draggedButtonOne(_ sender:UIPanGestureRecognizer) {
        print("the llzololz ")
        let copyButton = buttonOne.copyButton()
        copyButton.setQuestions(questions: self.currentOption!.questionSetList[0].questionList)
        copyButton.clearAnswers()
        let panGesture   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButton.isUserInteractionEnabled = true
        copyButton.addGestureRecognizer(panGesture)
        copyButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        let keyOne = self.currentOption?.questionSetList[1].surveyIconPointer
        copyButton.imageView?.image = self.imageStore.image(forKey: keyOne!)
        copyButton.setImage(self.buttonImageOne, for: .normal)
        buttonOnes.append(copyButton)
        self.view.addSubview(copyButton)
        
        let rect = scrollView.frame
        if sender.state == .ended {
            //print("pan ended?")
            if (rect.contains(copyButton.frame)) {
                // self.view.addSubview(copyButton)
            }
            else {
                self.view.willRemoveSubview(copyButton)
            }
        }
    }
    
    @objc func draggedButtonTwo(_ sender:UIPanGestureRecognizer) {
        let copyButton = buttonTwo.copyButton()
        copyButton.setQuestions(questions: self.currentOption!.questionSetList[1].questionList)
        copyButton.clearAnswers()
        let panGesture   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButton.isUserInteractionEnabled = true
        copyButton.addGestureRecognizer(panGesture)
        copyButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        let keyTwo = self.currentOption?.questionSetList[0].surveyIconPointer
        copyButton.imageView?.image = self.imageStore.image(forKey: keyTwo!)
        copyButton.setImage(self.buttonImageTwo, for: .normal)
        buttonTwos.append(copyButton)
        self.view.addSubview(copyButton)
        
        let rect = scrollView.frame
        if sender.state == .ended {
            //print("pan ended?")
            if (rect.contains(copyButton.frame)) {
                self.view.addSubview(copyButton)
                buttonOnes.append(copyButton)
            }
        }
        
    }
    
    @objc func draggedButtonThree(_ sender:UIPanGestureRecognizer) {
        let copyButton = buttonThree.copyButton()
        copyButton.setQuestions(questions: self.currentOption!.questionSetList[2].questionList)
        copyButton.clearAnswers()
        let newPanGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButton.isUserInteractionEnabled = true
        copyButton.addGestureRecognizer(newPanGestureOne)
        copyButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        let keyThree = self.currentOption?.questionSetList[2].surveyIconPointer
        copyButton.imageView?.image = self.imageStore.image(forKey: keyThree!)
        copyButton.setImage(self.buttonImageThree, for: .normal)
        buttonThrees.append(copyButton)
        self.view.addSubview(copyButton)
    }
    
    
    
    func printIconPositions() {
        
        clearButtonsOutsidePicture()
        
        print("\n\n\n button one locations")
        for button in buttonOnes {
            let origin = button.frame.origin
            let center = button.center
            print("\norigin: \(origin)" )
            print("center: \(center)\n" )
        }
        
        print("\n\n\n button two locations")
        for button in buttonTwos {
            let origin = button.frame.origin
            let center = button.center
            print("\norigin: \(origin)" )
            print("center: \(center)\n" )
        }
        
        print("\n\n\n button three locations")
        for button in buttonThrees {
            let origin = button.frame.origin
            let center = button.center
            print("\norigin: \(origin)" )
            print("center: \(center)\n" )
        }
        
    }
    
    func getIconPositions() {
        
        clearButtonsOutsidePicture()
        
        print("\n\n\n button one locations")
        for button in buttonOnes {
            let origin = button.frame.origin
            let center = button.center
            print("\norigin: \(origin)" )
            print("center: \(center)\n" )
        }
        
        print("\n\n\n button two locations")
        for button in buttonTwos {
            let origin = button.frame.origin
            let center = button.center
            print("\norigin: \(origin)" )
            print("center: \(center)\n" )
        }
        
        print("\n\n\n button three locations")
        for button in buttonThrees {
            let origin = button.frame.origin
            let center = button.center
            print("\norigin: \(origin)" )
            print("center: \(center)\n" )
        }
        
    }
    
    func getIconPositionsAndSaveToCoreData() {
    
        clearButtonsOutsidePicture()
        
        var buttonOneCenters = [CGPoint]()
        for button in buttonOnes {
            let center = button.center
            buttonOneCenters.append(center)
        }
        
        var buttonTwoCenters = [CGPoint]()
        for button in buttonTwos {
            let center = button.center
            buttonTwoCenters.append(center)
        }
        
        var buttonThreeCenters = [CGPoint]()
        for button in buttonThrees {
            let center = button.center
            buttonThreeCenters.append(center)
        }
        
        self.currentItem?.questionIconPositionsOne = buttonOneCenters
        self.currentItem?.questionIconPositionsTwo = buttonTwoCenters
        self.currentItem?.questionIconPositionsThree = buttonThreeCenters
        
//        saveButtonPositionsToCoreData(buttonOneCenters: buttonOneCenters,
//                                      buttonTwoCenters: buttonTwoCenters,
//                                      buttonThreeCenters: buttonThreeCenters)
//
//
        saveButtonPositionsToCoreData(buttonOnes: buttonOnes,
                                      buttonTwos: buttonTwos,
                                      buttonThrees: buttonThrees)
        
    }

    // new
    func saveButtonPositionsToCoreData(buttonOnes:[QuestionButton], buttonTwos:[QuestionButton], buttonThrees:[QuestionButton] ) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let currentItemId = currentItem?.itemID
        
        do {
            
            let itemfetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDItem")
            
            itemfetchRequest.predicate = NSPredicate(format: "itemID == %@", currentItemId!)
            
            let themanaged_Items = try managedContext.fetch(itemfetchRequest)
            
            let onemanaged_Item = themanaged_Items[0]
            
            // not sure if right yet
            //
            //
            //
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
                let parentItemID = self.currentItem?.itemID
                let center = button.getLocation()
                let centerData = NSKeyedArchiver.archivedData(withRootObject: center)
                let qsetID = button.questionSetID
                let type = 0 //button.getType()
                
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
                let parentItemID = self.currentItem?.itemID
                let center = button.getLocation()
                let centerData = NSKeyedArchiver.archivedData(withRootObject: center)
                let qsetID = button.questionSetID
                let type = 1 // button.getType()
                
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
                let parentItemID = self.currentItem?.itemID
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
                //people.append(person)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            // }
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    func saveOneButton(){
        
    }
    
    func saveButtonPositionsToCoreData(buttonOneCenters:[CGPoint], buttonTwoCenters:[CGPoint], buttonThreeCenters:[CGPoint]) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let currentItemId = currentItem?.itemID
        
        let dataOne = NSKeyedArchiver.archivedData(withRootObject: buttonOneCenters)
        let dataTwo = NSKeyedArchiver.archivedData(withRootObject: buttonTwoCenters)
        let dataThree = NSKeyedArchiver.archivedData(withRootObject: buttonThreeCenters)
        
        do {
            
            let itemfetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDItem")
            
            itemfetchRequest.predicate = NSPredicate(format: "itemID == %@", currentItemId!)
            
            let themanaged_Items = try managedContext.fetch(itemfetchRequest)
            
            // if  themanaged_Items.count > 0 {
            
                let onemanaged_Item = themanaged_Items[0]
                
                onemanaged_Item.setNilValueForKey("questionIconPositionsOne")
                onemanaged_Item.setNilValueForKey("questionIconPositionsTwo")
                onemanaged_Item.setNilValueForKey("questionIconPositionsThree")
                
                onemanaged_Item.setValue(currentItemId!, forKeyPath: "itemID")
                onemanaged_Item.setValue(dataOne,        forKeyPath: "questionIconPositionsOne")
                onemanaged_Item.setValue(dataTwo,        forKeyPath: "questionIconPositionsTwo")
                onemanaged_Item.setValue(dataThree,      forKeyPath: "questionIconPositionsThree")
            
                //optionToUpdate.setValue(NSSet(object: cdQuestionList), forKey: "questionList")
            
                // new stuff
//                let itemfetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDQuestionAnswer")
//
//                for (b in buttonOnes) {
//                    
//                }
            
                do {
                    try managedContext.save()
                    //people.append(person)
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            // }
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
    }
    
    func clearButtonsOutsidePicture(){
        
        var indexesToRemove = [Int]()
        var i = 0
        for (button) in buttonOnes {
            if (!self.scrollView.frame.contains(button.frame)) {// is outside picture scroll view
                self.view.willRemoveSubview(button)
                button.removeFromSuperview()
                indexesToRemove.append(i)
            }
            i += 1
        }
        buttonOnes = removedIndicesFromButtonArray(indices: indexesToRemove, array: buttonOnes)
        
        indexesToRemove.removeAll()
        i = 0
        for button in buttonTwos {
            if (!self.scrollView.frame.contains(button.frame)) {// is outside picture scroll view
                self.view.willRemoveSubview(button)
                button.removeFromSuperview()
                indexesToRemove.append(i)
            }
            i += 1
        }
        buttonTwos = removedIndicesFromButtonArray(indices: indexesToRemove, array: buttonTwos)
        
        indexesToRemove.removeAll()
        i = 0
        for button in buttonThrees {
            if (!self.scrollView.frame.contains(button.frame)) {// is outside picture scroll view
                self.view.willRemoveSubview(button)
                button.removeFromSuperview()
                indexesToRemove.append(i)
            }
            i += 1
        }
        buttonThrees = removedIndicesFromButtonArray(indices: indexesToRemove, array: buttonThrees)
    }
    
    func removedIndicesFromButtonArray(indices:[Int], array: [QuestionButton]) -> [QuestionButton] {
        var newArray = array
        for i in indices.reversed() {
            newArray.remove(at: i)
        }
        return newArray
    }
    
    @IBAction func uploadButtonPressed(_ sender: Any) {
        
        // important!!
        clearButtonsOutsidePicture()
        
        let dispatchGroup = DispatchGroup()
        // let pointer = UUID().uuidString
        let pointer = currentItem?.imgPointer
        SVProgressHUD.show()
        // let editedImage = onDismiss!(self.view);
        let editedImage = self.bigImage.image!
        //dispatchGroup.enter()
        api.uploadImage(theImage: editedImage ,imgPointer: pointer!, completion: {
            success, response in
            if (success) {
                print("lololz")
                print(response)
                self.uploadSuccessPopup()
            }
            else {
                self.errorPopup()
            }
            //dispatchGroup.leave()
            SVProgressHUD.dismiss()
        })
        
        let questionSetCount = self.currentOption?.questionSetList.count
        
        if (questionSetCount! >= 3 ) {
            let qOne = self.currentOption?.questionSetList[0].questionList
            let qTwo = self.currentOption?.questionSetList[1].questionList
            let qThree = self.currentOption?.questionSetList[2].questionList
            
//            questionsUploadOld(questionList: qOne!, button: buttonOnes[0], dispatchGroup: dispatchGroup)
//            questionsUploadOld(questionList: qTwo!, button: buttonTwos[0], dispatchGroup: dispatchGroup)
//            questionsUploadOld(questionList: qThree!, button: buttonThrees[0], dispatchGroup: dispatchGroup)
            for oneButtonOne in buttonOnes {
                questionsUpload(questionList: qOne!, button: oneButtonOne, dispatchGroup: dispatchGroup)
            }
            for oneButtonTwo in buttonTwos {
                questionsUpload(questionList: qTwo!, button: oneButtonTwo, dispatchGroup: dispatchGroup)
            }
            for oneButtonThree in buttonTwos {
                questionsUpload(questionList: qThree!, button: oneButtonThree, dispatchGroup: dispatchGroup)
            }
        }
        else if (questionSetCount! == 2) {
            let qOne = self.currentOption?.questionSetList[0].questionList
            let qTwo = self.currentOption?.questionSetList[1].questionList
            
//            questionsUploadOld(questionList: qOne!, button: buttonOnes[0], dispatchGroup: dispatchGroup)
//            questionsUploadOld(questionList: qTwo!, button: buttonTwos[0], dispatchGroup: dispatchGroup)
//            
            for oneButtonOne in buttonOnes {
                questionsUpload(questionList: qOne!, button: oneButtonOne, dispatchGroup: dispatchGroup)
            }
            for oneButtonTwo in buttonTwos {
                questionsUpload(questionList: qTwo!, button: oneButtonTwo, dispatchGroup: dispatchGroup)
            }
        }
        else if (questionSetCount! == 1) {
            let qOne = self.currentOption?.questionSetList[0].questionList
            
//            questionsUploadOld(questionList: qOne!, button: buttonOnes[0], dispatchGroup: dispatchGroup)
            for oneButtonOne in buttonOnes {
                questionsUpload(questionList: qOne!, button: oneButtonOne, dispatchGroup: dispatchGroup)
            }
        }
        
    }
    
    func questionsUploadOld(questionList: [Question], button: QuestionButton, dispatchGroup:DispatchGroup) {
        
        var successCount = 0
        var failCount = 0
        
        SVProgressHUD.show()
        let oneAnswerSetInstanceId = UUID().uuidString // change this. this is temporary. we dont want a different answer set instance id each time we upload. create a new one each time a button is created and persist it once answered or something lke that
        
        //if let questions = questionList {
            for oneQuestion in questionList {
                //for oneQuestion in questionList {
                
                if (oneQuestion.questionType == .next) {
                    continue
                }
                let questionText = oneQuestion.questionText!
                let answer = oneQuestion.questionAnswer!
                let questionNum  = oneQuestion.questionNumber!
                let guid  = self.currentOption!.optionID!
                let projectID  = self.currentOption!.optionID! //oneQuestion.parentQuestionSetID!
                let questionSetID  = oneQuestion.parentQuestionSetID! //
                let answerSetInstanceID  = oneAnswerSetInstanceId //oneQuestion.parentQuestionSetID!
                let backgroundID  =  self.currentItem!.imgPointer!
                let answerSetXPosition  = Int(button.center.x)
                let answerSetYPosition  = Int(button.center.y)
                var answerType = oneQuestion.questionTypeNumber! //theQuestions[0].questionTypeNumber!
                
//                if (oneQuestion.questionType == .photo) {
//                    answerType = 5
//                    dispatchGroup.enter()
//                    for (key, value)  in button.photoCache {
//                        let image = value
//                        let pointer = UUID().uuidString
//                        self.api.uploadImage(theImage: image ,imgPointer: pointer, completion: {
//                            success, response in
//                            print(response)
//                            //                            if (success) {
//                            //                                print("lololz")
//                            //                                print(response)
//                            //                                //self.uploadSuccessPopup()
//                            //                            }
//                            //                            else {
//                            //                                //self.errorPopup()
//                            //                            }
//                            //SVProgressHUD.dismiss()
//                            dispatchGroup.leave()
//                        })
//                    }
//
//                }
//                else if (answer == "") {
//                    continue
//                }
                
                
//                if (answer == "") {
//                    continue
//                }
                let imgPointer = self.currentItem!.imgPointer
                
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                let dateTime = formatter.date(from: "2016/10/08 22:31")
                let dateString = dateTime?.description
                
                let device_id = UIDevice.current.identifierForVendor?.uuidString
                
                
                let api = AlchemieAPI()
 
                dispatchGroup.enter()
                api.uploadAnswers(guid: guid,
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
        // }
        
    }
    
    /// beta who knows how the questions will be put there
    func questionsUpload(questionList: [Question], button: QuestionButton, dispatchGroup:DispatchGroup) {
        
        var successCount = 0
        var failCount = 0
        
        SVProgressHUD.show()
        
        let oneAnswerSetInstanceId = UUID().uuidString
        
        
        
        if let questions = button.getQuestions() {
            for oneQuestion in questions {
            //for oneQuestion in questionList {
                
                if (oneQuestion.questionType == .next) {
                    continue
                }
                
                
                let questionText = oneQuestion.questionText!
                // var answer = oneQuestion.questionAnswer!
                let questionNum  = oneQuestion.questionNumber!
                let guid  = self.currentOption!.optionID!
                let projectID  = self.currentOption!.optionID! //oneQuestion.parentQuestionSetID!
                let questionSetID  = oneQuestion.parentQuestionSetID! //
                let answerSetInstanceID  = oneAnswerSetInstanceId //.parentQuestionSetID!
                let backgroundID  =  self.currentItem!.imgPointer!
                let answerSetXPosition  = Int(button.center.x)
                let answerSetYPosition  = Int(button.center.y)
                var answerType = oneQuestion.questionTypeNumber! //theQuestions[0].questionTypeNumber!
                
                
                
                let answer = button.getFromAnswersMap(key: questionNum)
                
                
                if (answer == ""  && oneQuestion.questionType != .photo) {
                    continue
                }
                
                
                let imgPointer = button.getFromAnswersMap(key: questionNum)
//                
                
                if (oneQuestion.questionType == .photo) {
                    answerType = 5
                    
                    let imgPointer = answer // oneQuestion.questionAnswer!
                    
                    
                    if let picForThisQuestion = ImageStore.sharedInstance.image(forKey: imgPointer) {
//                        dispatchGroup.enter()
                        self.api.uploadImage(theImage: picForThisQuestion, imgPointer: imgPointer, completion: {
                            success, response in
                            print("    question pic response!!!    ")
                            print(response)
//                            if (success) {
//                                print("lololz")
//                                print(response)
//                                //self.uploadSuccessPopup()
//                            }
//                            else {
//                                //self.errorPopup()
//                            }
//                            dispatchGroup.leave()
                        })
                    }
                    
//                    for (key, value)  in button.photoCache {
//                        let image = value
//
//                        //dispatchGroup.enter()
//                        self.api.uploadImage(theImage: value ,imgPointer: imgPointer, completion: {
//                            success, response in
//                            print("    question pic response!!!    ")
//                            print(response)
////                            if (success) {
////                                print("lololz")
////                                print(response)
////                                self.uploadSuccessPopup()
////                            }
////                            else {
////                                self.errorPopup()
////                            }
//
//                            //dispatchGroup.leave()
//                        })
//
//                    }
                    continue
                }
                
//                else if (answer == "") {
//                    continue
//                }
                
                // let imgPointer = self.currentItem!.imgPointer
                
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                let dateTime = formatter.date(from: "2016/10/08 22:31")
                let dateString = dateTime?.description
                
                let device_id = UIDevice.current.identifierForVendor?.uuidString
                
                
                let api = AlchemieAPI()
                
                dispatchGroup.enter()
                api.uploadAnswers(guid: guid,
                                  projectID: projectID,
                                  questionSetID: questionSetID,
                                  answerSetInstanceID: answerSetInstanceID,
                                  backgroundID: backgroundID,
                                  answerSetXPosition: answerSetXPosition,
                                  answerSetYPosition: answerSetYPosition,
                                  questionNum: questionNum,
                                  answerType: answerType,
                                  imgPointer: imgPointer,
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
                
                dispatchGroup.notify(queue: DispatchQueue.main) {
                    self.uploadSuccessPopup()
                    SVProgressHUD.dismiss()
                }
            }
        }
        
    }
}
