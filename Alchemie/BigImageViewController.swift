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
    
    @IBOutlet weak var buttonOne: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    
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
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.bigImage
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //let touch = event?.allTouches
        
        //let loc = touch
        print("touch lolz")
        let touch : UITouch! =  touches.first! as UITouch
        
        touchedLocation = touch.location(in: self.buttonOne)
        
        buttonOne.center = touchedLocation
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("touch continue")
        
        let touch : UITouch! =  touches.first! as UITouch
        
        touchedLocation = touch.location(in: self.buttonOne)
        
        buttonOne.center = touchedLocation
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

  
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
}
