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
    
    @IBOutlet weak var bigImage: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var theImage:UIImage?
    
    var touchedLocation = CGPoint(x: 0.0, y: 0.0)
    
    var currentOption:Option?
    var currentSubOption:SubOption?// not used yet
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    
    
    var buttonOnes = [UIButton]()
    var buttonTwos = [UIButton]()
    var buttonThrees = [UIButton]()
    
    var panGestureOne   = UIPanGestureRecognizer()
    var panGestureTwo   = UIPanGestureRecognizer()
    var panGestureThree = UIPanGestureRecognizer()
    
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
    }
    

    func setUpInitialPanGestures() {
        
        let copyButtonOne = buttonOne.copyButton()
        copyButtonOne.isUserInteractionEnabled = true
        let panGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButtonOne.addGestureRecognizer(panGestureOne)
        copyButtonOne.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(copyButtonOne)
        
        let copyButtonTwo = buttonTwo.copyButton()
        copyButtonTwo.isUserInteractionEnabled = true
        let panGestureTwo   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButtonTwo.addGestureRecognizer(panGestureTwo)
        copyButtonTwo.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(copyButtonTwo)
        
        let copyButtonThree = buttonThree.copyButton()
        copyButtonThree.isUserInteractionEnabled = true
        let panGestureThree = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonEvery(_:) ) )
        copyButtonThree.addGestureRecognizer(panGestureThree)
        copyButtonThree.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(copyButtonThree)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.bigImage
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
        self.navigationController?.popViewController(animated: false)
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
