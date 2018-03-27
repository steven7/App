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
    
    @IBOutlet weak var bigImage: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var bottomBackgroundView: UIView!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    var theImage:UIImage?
    
    let imageStore = ImageStore.sharedInstance
    
    var touchedLocation = CGPoint(x: 0.0, y: 0.0)
    
    var currentOption:Option?
    var currentSubOption:SubOption?
    var currentItem:Item?
    
    // var questions = [QuestionSet]()
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    
    var buttonImageOne: UIImage?
    var buttonImageTwo: UIImage?
    var buttonImageThree: UIImage?
    
    var onDismiss: ( (UIView)  -> (UIImage) )?
    
    var thumbnailImageView: UIImageView?
    
    
    var buttonOnes = [UIButton]()
    var buttonTwos = [UIButton]()
    var buttonThrees = [UIButton]()
    
    var panGestureOne   = UIPanGestureRecognizer()
    var panGestureTwo   = UIPanGestureRecognizer()
    var panGestureThree = UIPanGestureRecognizer()
    
    
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
            let keyOne = self.currentOption?.questionSetList[1].surveyIconPointer
            self.buttonImageOne = self.imageStore.image(forKey: keyOne!)
            let keyTwo = self.currentOption?.questionSetList[0].surveyIconPointer
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
            let keyOne = self.currentOption?.questionSetList[1].surveyIconPointer
            self.buttonImageOne = self.imageStore.image(forKey: keyOne!)
            let keyTwo = self.currentOption?.questionSetList[0].surveyIconPointer
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
            let keyTwo = self.currentOption?.questionSetList[0].surveyIconPointer
            self.buttonImageTwo = self.imageStore.image(forKey: keyTwo!)
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
        
        
        getThreeButtonPositionOnImage()
        
        
        
        printIconPositions()
        
    }
    

    func setUpInitialPanGestures() {
        
        let copyButtonOne = buttonOne.copyButton()
        copyButtonOne.isUserInteractionEnabled = true
        let panGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButtonOne.addGestureRecognizer(panGestureOne)
        copyButtonOne.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        self.buttonOnes.append(copyButtonOne)
        self.view.addSubview(copyButtonOne)
        
        let copyButtonTwo = buttonTwo.copyButton()
        copyButtonTwo.isUserInteractionEnabled = true
        let panGestureTwo   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButtonTwo.addGestureRecognizer(panGestureTwo)
        copyButtonTwo.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        self.buttonTwos.append(copyButtonTwo)
        self.view.addSubview(copyButtonTwo)
        
        let copyButtonThree = buttonThree.copyButton()
        copyButtonThree.isUserInteractionEnabled = true
        let panGestureThree = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButtonThree.addGestureRecognizer(panGestureThree)
        copyButtonThree.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        self.buttonThrees.append(copyButtonThree)
        self.view.addSubview(copyButtonThree)
        
    }
    
    func setUpInitialPanGesturesOne() {
        let copyButtonOne = buttonOne.copyButton()
        copyButtonOne.isUserInteractionEnabled = true
        let panGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButtonOne.addGestureRecognizer(panGestureOne)
        copyButtonOne.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        self.buttonOnes.append(copyButtonOne)
        self.view.addSubview(copyButtonOne)
    }
    
    func setUpInitialPanGesturesTwo() {
        let copyButtonTwo = buttonTwo.copyButton()
        copyButtonTwo.isUserInteractionEnabled = true
        let panGestureTwo   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButtonTwo.addGestureRecognizer(panGestureTwo)
        copyButtonTwo.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        // copyButtonTwo.imageView?.image = self.buttonImageTwo
        copyButtonTwo.setImage(self.buttonImageTwo, for: .normal)
        self.buttonTwos.append(copyButtonTwo)
        self.view.addSubview(copyButtonTwo)
    }
    
    
    func setUpInitialPanGesturesThree() {
        let copyButtonThree = buttonThree.copyButton()
        copyButtonThree.isUserInteractionEnabled = true
        let panGestureThree = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButtonThree.addGestureRecognizer(panGestureThree)
        copyButtonThree.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
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
                
                question.questionSetID = qSetID
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

  
    @IBAction func buttonOnePressed(_ sender: Any) {
        //self.performSegue(withIdentifier: "toQuestions", sender: self)
    }
    
    @IBAction func buttonTwoPressed(_ sender: Any) {
        //print("button two pressed!!")
        //self.performSegue(withIdentifier: "toQuestions", sender: self)
    }
    
    @IBAction func buttonThreePressed(_ sender: Any) {
        //print("button three pressed!!")
        //self.performSegue(withIdentifier: "toQuestions", sender: self)
        
    }
    
    @objc func buttonPressed(_ sender: Any) {
        //print("copy button pressed!!")
        let button = sender as! UIButton
        let point = button.center
        let rect = scrollView.frame
        
        if (rect.contains(point)) {
            self.performSegue(withIdentifier: "toQuestions", sender: self)
        }
        
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        let editedImage = onDismiss!(self.view);
        thumbnailImageView?.image = editedImage
        currentItem?.editedImage = editedImage
        getIconPositionsAndSaveToCoreData() 
        self.navigationController?.popViewController(animated: false)
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
    
    // for future use - this should work
    // may also need to handle images
    /*
    func getButtonPositionOnImage (){
        // each 'question' current has three associated icon sets this could change in the future
        var questionlist = [Question()]
        if let option = currentOption {
            questionlist = option.questionList
        }
        
        for question in questionlist {
            for position in question.questionIconPositions!  {
                addButtonOnPosition(positionCenter: position)
            }
        }
        
    }
    */
    
    func addButtonOnPosition(positionCenter: CGPoint, buttonTypeArray: inout [UIButton]){
        let buttonView = UIButton() // sender.view as! UIButton
        //let translation = sender.translation(in: self.view)
        buttonView.center   = positionCenter
        // CGPoint(x: buttonView.center.x + translation.x , y: buttonView.center.y + translation.y)
        //sender.setTranslation(CGPoint.zero, in: self.view)
        buttonTypeArray.append(buttonView)
        self.bigImage.addSubview(buttonView)
        //view.addSubview(buttonView)
    }
    
    func addButtonOneOnPosition(positionCenter: CGPoint, buttonTypeArray: inout [UIButton]){
        let buttonView = buttonOne.copyButton()
        let newPanGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        buttonView.isUserInteractionEnabled = true
        buttonView.addGestureRecognizer(newPanGestureOne)
        buttonView.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        buttonView.center   = positionCenter
        let keyOne = self.currentOption?.questionSetList[0].surveyIconPointer
        //buttonView.imageView?.image = self.imageStore.image(forKey: keyOne!)
        buttonView.setImage(self.buttonImageOne, for: .normal)
        buttonTypeArray.append(buttonView)
        self.bigImage.addSubview(buttonView)
        //view.addSubview(buttonView)
    }
    
    func addButtonTwoOnPosition(positionCenter: CGPoint, buttonTypeArray: inout [UIButton]){
        let buttonView = buttonTwo.copyButton()
        let newPanGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        buttonView.isUserInteractionEnabled = true
        buttonView.addGestureRecognizer(newPanGestureOne)
        buttonView.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        buttonView.center   = positionCenter
        let keyTwo = self.currentOption?.questionSetList[0].surveyIconPointer
        //buttonView.imageView?.image = self.imageStore.image(forKey: keyTwo!)
        buttonView.setImage(self.buttonImageTwo, for: .normal)
        buttonTypeArray.append(buttonView)
        self.bigImage.addSubview(buttonView)
        //view.addSubview(buttonView)
    }
    
    func addButtonThreeOnPosition(positionCenter: CGPoint, buttonTypeArray: inout [UIButton]){
        let buttonView = buttonThree.copyButton() // sender.view as! UIButton
        let newPanGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        buttonView.isUserInteractionEnabled = true
        buttonView.addGestureRecognizer(newPanGestureOne)
        buttonView.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        buttonView.center   = positionCenter
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
        
        let buttonView = sender.view as! UIButton
        let point = buttonView.center
        let rect = scrollView.frame
        
        /*
        if sender.state == .began {
            
            //let translation = sender.translation(in: self.bigImage)
            
            
            let xDif = location.x - locationv.x
            let yDif = location.y - locationv.y
            
            buttonView.center   = CGPoint(x: buttonView.center.x - xDif,
                                          y: buttonView.center.y - yDif)
            
            
            //buttonView.center   = CGPoint(x: buttonView.center.x + translation.x , y: buttonView.center.y + translation.y)
            
        }
        else if sender.state == .changed {
            let translation = sender.translation(in: self.bigImage)
            
            let xDif = location.x - locationv.x
            let yDif = location.y - locationv.y
            
            //buttonView.center   = CGPoint(x: buttonView.center.x + xDif,
            //                              y: buttonView.center.y + yDif)
            
            
            buttonView.center   = CGPoint(x: buttonView.center.x + translation.x , y: buttonView.center.y + translation.y)
            
            sender.setTranslation(CGPoint.zero, in: self.bigImage)
        }
        */
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
            if (rect.contains(point)) {
                if (!bigImage.subviews.contains(buttonView)) {
                    //self.bigImage.addSubview(buttonView )
                    
                    // i dont this is the offiial apple way to convert between different coordinate systems but it works
                    let xDif = location.x - locationv.x
                    let yDif = location.y - locationv.y
                    
                    buttonView.center   = CGPoint(x: buttonView.center.x + xDif,
                                                  y: buttonView.center.y + yDif)
                   
                    self.view.willRemoveSubview(buttonView)
                    self.bigImage.addSubview(buttonView )
                    
                    // print("icon added to pic")
                }
            }
            else {
                self.view.addSubview(buttonView )
            }
            return
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
        
    }
    
    @objc func draggedButtonOne(_ sender:UIPanGestureRecognizer) {
        print("the llzololz ")
        let copyButton = buttonOne.copyButton()
        let panGesture   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButton.isUserInteractionEnabled = true
        copyButton.addGestureRecognizer(panGesture)
        copyButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        let keyOne = self.currentOption?.questionSetList[1].surveyIconPointer
        copyButton.imageView?.image = self.imageStore.image(forKey: keyOne!)
        copyButton.setImage(self.buttonImageOne, for: .normal)
        buttonOnes.append(copyButton)
        self.view.addSubview(copyButton)
        /*
        //if (self.scrollView.bounds.intersects(copyButton.frame) ){
        // if (self.bigImage.bounds.intersects(copyButton.frame) ){
        if (!self.view.bounds.contains(copyButton.frame) ){
        //if (!self.bottomBackgroundView.bounds.intersects(copyButton.frame)) {
        //if (self.bigImage.bounds.contains(copyButton.center) ){
            self.bigImage.addSubview(copyButton)
            //self.scrollView.addSubview(copyButton)
        }
        else {
            self.view.addSubview(copyButton)
        }*/
    }
    
    @objc func draggedButtonTwo(_ sender:UIPanGestureRecognizer) {
        let copyButton = buttonTwo.copyButton()
        let panGesture   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButton.isUserInteractionEnabled = true
        copyButton.addGestureRecognizer(panGesture)
        copyButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        let keyTwo = self.currentOption?.questionSetList[0].surveyIconPointer
        copyButton.imageView?.image = self.imageStore.image(forKey: keyTwo!)
        copyButton.setImage(self.buttonImageTwo, for: .normal)
        buttonTwos.append(copyButton)
        self.view.addSubview(copyButton)
        /*
        if (!self.view.bounds.contains(copyButton.frame) ){
            self.bigImage.addSubview(copyButton)
        }
        /*
        if (self.scrollView.bounds.contains(copyButton.frame) ){
            self.bigImage.addSubview(copyButton)
        }*/
        else {
            self.view.addSubview(copyButton)
        }
        */
    }
    
    @objc func draggedButtonThree(_ sender:UIPanGestureRecognizer) {
        let copyButton = buttonThree.copyButton()
        let newPanGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButton.isUserInteractionEnabled = true
        copyButton.addGestureRecognizer(newPanGestureOne)
        copyButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        let keyThree = self.currentOption?.questionSetList[2].surveyIconPointer
        copyButton.imageView?.image = self.imageStore.image(forKey: keyThree!)
        copyButton.setImage(self.buttonImageThree, for: .normal)
        buttonThrees.append(copyButton)
        self.view.addSubview(copyButton)
        /*
        if (self.scrollView.bounds.intersects(copyButton.frame) ){
            self.bigImage.addSubview(copyButton)
        }
        else {
            self.view.addSubview(copyButton)
        }*/
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toQuestions") {
            let viewController = segue.destination as! QuestionsViewController
            if let option = currentOption {
                viewController.currentOption = self.currentOption
                viewController.currentSubOption = self.currentSubOption
                viewController.currentItem = self.currentItem
                viewController.theQuestions = option.questionSetList[0].questionList
            }
        }
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
        
        saveButtonPositionsToCoreData(buttonOneCenters: buttonOneCenters,
                                      buttonTwoCenters: buttonTwoCenters,
                                      buttonThreeCenters: buttonThreeCenters)
        
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
    
    /*
    func saveButtonPositionsToCoreDataOther(buttonOneCenters:[CGPoint], buttonTwoCenters:[CGPoint], buttonThreeCenters:[CGPoint]) {
        
        // currentOption
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let parentOptionID = currentOption?.optionID
        let parentSubOptionID = currentSubOption?.subOptionID
        let subOptionfetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDSubOption")
        
        subOptionfetchRequest.predicate = NSPredicate(format: "subOptionID == %@", parentOptionID!)
        
        let dataOne = NSKeyedArchiver.archivedData(withRootObject: buttonOneCenters)
        let dataTwo = NSKeyedArchiver.archivedData(withRootObject: buttonTwoCenters)
        let dataThree = NSKeyedArchiver.archivedData(withRootObject: buttonThreeCenters)
        
        do {
            let subOptionsToUpdate = try managedContext.fetch(subOptionfetchRequest)
            let subOoptionToUpdate = subOptionsToUpdate[0]
            
            let entity = NSEntityDescription.entity(forEntityName: "CDItem",
                                                               in: managedContext)!
            // let cdItem = NSManagedObject(entity: entity,
            //                                      insertInto: managedContext)
            
            let itemfetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "CDItem")
            
            itemfetchRequest.predicate = NSPredicate(format: "parentSubOptionID == %@", parentSubOptionID!)
            
            let cdItem = try managedContext.fetch(itemfetchRequest)
            
            /*
            // get questions
            let questionfetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "CDQuestionList")
            
            questionfetchRequest.predicate = NSPredicate(format: "parentOptionID == %@", parentOptionID!)
            
            let theManaged_Questions = try managedContext.fetch(questionfetchRequest)
            for oneQuestion in theManaged_Questions {
                oneQuestion.setValue(dataOne,     forKeyPath: "questionIconPositionsOne")
                oneQuestion.setValue(dataTwo,     forKeyPath: "questionIconPositionsTwo")
                oneQuestion.setValue(dataThree,   forKeyPath: "questionIconPositionsThree")
                
                
                optionToUpdate.setValue(NSSet(object: oneQuestion), forKey: "questionList")
                
                do {
                    try managedContext.save()
                    //people.append(person)
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
            */
            /*
             cdItem.setValue(dataOne,     forKeyPath: "questionIconPositionsOne")
             cdItem.setValue(dataTwo,     forKeyPath: "questionIconPositionsTwo")
             cdItem.setValue(dataThree,   forKeyPath: "questionIconPositionsThree")
 
             /*
             cdQuestionList.setValue(question.questionText,     forKeyPath: "questionText")
             cdQuestionList.setValue(question.questionSetID,    forKeyPath: "questionSetID")
             cdQuestionList.setValue(option.optionID,           forKeyPath: "parentOptionID")
             cdQuestionList.setValue(question.questionTypeNumber,   forKeyPath: "questionTypeNumber")
             */
 
             optionToUpdate.setValue(NSSet(object: cdQuestionList), forKey: "questionList")
            */
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
    
    func removedIndicesFromButtonArray(indices:[Int], array: [UIButton]) -> [UIButton] {
        var newArray = array
        for i in indices.reversed() {
            newArray.remove(at: i)
        }
        return newArray
    }
    
    @IBAction func uploadButtonPressed(_ sender: Any) {
        let api = AlchemieAPI()
        let pointer = currentItem?.imgPointer
        SVProgressHUD.show()
        let editedImage = onDismiss!(self.view);
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
            SVProgressHUD.dismiss()
        })
        //self.comingSoonPopup()
    }
    
}
