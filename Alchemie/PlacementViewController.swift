//
//  PlacementViewController.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/20/17.
//  Copyright © 2017 steve. All rights reserved.
//

import UIKit

class PlacementViewController: UIViewController {

    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var subOptionOneLabel: UILabel!
    @IBOutlet weak var subOptionTwoLabel: UILabel!
    
    @IBOutlet weak var collectionViewOne: UICollectionView!
    @IBOutlet weak var collectionViewTwo: UICollectionView!
    
    
    var optionTitle:String?
    var subOptionOneTitle:String?
    var subOptionTwoTitle:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let iNib = UINib(nibName: "ItemCollectionViewCell", bundle: nil)
        let cNib = UINib(nibName: "CreateItemCollectionViewCell", bundle: nil)
        
        collectionViewOne.register(iNib, forCellWithReuseIdentifier: "itemCell")
        collectionViewOne.register(cNib, forCellWithReuseIdentifier: "createItemCell")
        
        collectionViewTwo.register(iNib, forCellWithReuseIdentifier: "itemCell")
        collectionViewTwo.register(cNib, forCellWithReuseIdentifier: "createItemCell")
        
        
        if let optiont = optionTitle {
            self.optionLabel.text = optiont
        }
        if let suboptiononet = subOptionOneTitle {
            self.subOptionOneLabel.text = suboptiononet
        }
        if let suboptiontwot = subOptionTwoTitle {
            self.subOptionTwoLabel.text = suboptiontwot
        }
        self.subOptionTwoLabel.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
