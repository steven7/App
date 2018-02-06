//
//  BigImageViewController.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/27/17.
//  Copyright © 2017 steve. All rights reserved.
//

import UIKit

class BigImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var eraseIconsButton: UIButton!
    
    @IBOutlet weak var bigImage: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var theImage:UIImage?
    
    var touchedLocation = CGPoint(x: 0.0, y: 0.0)
    
    var currentOption:Option?
    var currentSubOption:SubOption?// not used yet
    
    var questions = [QuestionSet]()
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    
    var onDismiss: ( (UIView)  -> (UIImage) )?
    
    var thumbnailImageView: UIImageView?
    
    
    var buttonOnes = [UIButton]()
    var buttonTwos = [UIButton]()
    var buttonThrees = [UIButton]()
    
    var panGestureOne   = UIPanGestureRecognizer()
    var panGestureTwo   = UIPanGestureRecognizer()
    var panGestureThree = UIPanGestureRecognizer()
    
    var currentItem:Item?
    
    let api = AlchemieAPI()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        bigImage.image = theImage
        
        // Do any additional setup after loading the view.
        self.scrollView.minimumZoomScale = 0.2;
        self.scrollView.maximumZoomScale = 5.0;
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
        
        DispatchQueue.main.async {
            self.setUpInitialPanGestures()
        }
        //setUpInitialPanGestures()
        
       // self.buttonThree.sendActions(for: <#T##UIControlEvents#>)
        //self.buttonThree.sendActions(for: .touchDragInside)
        //panGestureThree()
        //self.draggedButtonThree(<#T##sender: UIPanGestureRecognizer##UIPanGestureRecognizer#>)
        
        self.view.bringSubview(toFront: eraseIconsButton)
        
        
        
        
        api.fetchQuestionSet(completion: { success, response in
            if (success) {
                print(response)
                self.questions = self.getQuestionSetFromJSON(withJSON: response)
            }
            else {
                self.errorPopup()
            }
        })
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
            oneQuestionSet.surveyIcon = setSurveyIconPointer
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
        self.performSegue(withIdentifier: "toQuestions", sender: self)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        let editedImage = onDismiss!(self.view);
        thumbnailImageView?.image = editedImage
        currentItem?.editedImage = editedImage
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func eraseIconsButtonPressed(_ sender: Any) {
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
        bigImage.image = currentItem?.image
    }
    
    ///////////////////
    //
    //    drop and drag
    //
    ///////////////////
    
    @objc func draggedButtonEvery(_ sender:UIPanGestureRecognizer) {
        //print(" one !!dupe!! dragged")
        
        let location = sender.location(in: bigImage)
        print("the location: \(location)")
        let locationsv = sender.location(in: scrollView)
        print("the location sv: \(locationsv)")
        
        let buttonView = sender.view as! UIButton
        let translation = sender.translation(in: self.view)
        buttonView.center   = CGPoint(x: buttonView.center.x + translation.x , y: buttonView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @objc func draggedButtonOne(_ sender:UIPanGestureRecognizer) {
        let copyButton = buttonOne.copyButton()
        let panGesture   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButton.isUserInteractionEnabled = true
        copyButton.addGestureRecognizer(panGesture)
        copyButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(copyButton)
    }
    
    @objc func draggedButtonTwo(_ sender:UIPanGestureRecognizer) {
        let copyButton = buttonTwo.copyButton()
        let panGesture   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButton.isUserInteractionEnabled = true
        copyButton.addGestureRecognizer(panGesture)
        copyButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(copyButton)
    }
    
    @objc func draggedButtonThree(_ sender:UIPanGestureRecognizer) {
        let copyButton = buttonThree.copyButton()
        let newPanGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButton.isUserInteractionEnabled = true
        copyButton.addGestureRecognizer(newPanGestureOne)
        copyButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(copyButton)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toQuestions") {
            let viewController = segue.destination as! QuestionsViewController
            if let option = currentOption {
                viewController.theQuestions = option.questionList
            }
        }
    }
    
}
