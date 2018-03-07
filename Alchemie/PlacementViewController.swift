//
//  PlacementViewController.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/20/17.
//  Copyright © 2017 steve. All rights reserved.
//

import UIKit
import CoreData

class PlacementViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var subOptionOneLabel: UILabel!
    @IBOutlet weak var subOptionTwoLabel: UILabel!
    
    @IBOutlet weak var collectionViewOne: UICollectionView!
    @IBOutlet weak var collectionViewTwo: UICollectionView!
    
    @IBOutlet weak var bigImageView: UIImageView!
    
    @IBOutlet weak var bigImageButton: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    var collectionViewOneContents = [AnyObject]()
    var collectionViewTwoContents = [AnyObject]()
    
    var currentOption:Option?
    var currentSubOption:SubOption?
    
    var optionTitle:String?
    var subOptionOneTitle:String?
    var subOptionTwoTitle:String?
    
    let imageStore = ImageStore.sharedInstance
    
    var highlightedIndex:Int?
    
    var panGestureOne   = UIPanGestureRecognizer()
    var panGestureTwo   = UIPanGestureRecognizer()
    var panGestureThree = UIPanGestureRecognizer()
    
    var touchedLocationOne = CGPoint(x: 0.0, y: 0.0)
    var touchedLocationTwo = CGPoint(x: 0.0, y: 0.0)
    var touchedLocationThree = CGPoint(x: 0.0, y: 0.0)
    
    var currentItem:Item?
    
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
         
        // collectionViewOneContents.append(CreateItem())
        
        collectionViewOne.delegate = self
        collectionViewOne.dataSource = self
        
        self.bigImageButton.isHidden = true
        self.bigImageButton.isEnabled = false
        
        //self.stackView.isUserInteractionEnabled = true
        
        currentOption?.printQuestionList()
        
        if let sub = self.currentSubOption {
            if let option = sub.parentOption {
                option.printQuestionList()
            }
            else {
                print("parent option not availabe")
            }
        }
        else {
            print("current sub option not availabe")
        }
        
        self.uploadButton.layer.cornerRadius = 15
        
        /*
        panGestureOne   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonOne(_:) ) )
        panGestureTwo   = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonTwo(_:) ) )
        panGestureThree = UIPanGestureRecognizer(target: self, action: #selector(draggedButtonThree(_:) ) )
        
         
        self.buttonOne.isUserInteractionEnabled = true
        self.buttonOne.addGestureRecognizer(panGestureOne)
        
        self.buttonTwo.isUserInteractionEnabled = true
        self.buttonTwo.addGestureRecognizer(panGestureTwo)
        
        self.buttonThree.isUserInteractionEnabled = true
        self.buttonThree.addGestureRecognizer(panGestureThree)
        */
        
        collectionViewOneContents = fetchItemsFromCoreData()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true) 
        // collectionViewOneContents = fetchItemsFromCoreData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionViewOneContents = fetchItemsFromCoreData()
        self.collectionViewOne.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //////
    //
    // MARK: - Collection view
    //
    /////
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView.tag == 0) {
            return collectionViewOneContents.count
        }
        //if(collectionView.tag == 1) {
            return collectionViewTwoContents.count
        //}
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView.tag == 0) {
            if ( collectionViewOneContents[indexPath.row] is CreateItem ) {
                let cell = collectionViewOne.dequeueReusableCell(withReuseIdentifier: "createItemCell", for: indexPath) as! CreateItemCollectionViewCell
                return cell
            }
            else if (collectionViewOneContents[indexPath.row] is Item ) {
                let item = collectionViewOneContents[indexPath.row] as! Item
                let cell = collectionViewOne.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! ItemCollectionViewCell
                cell.withItem(item: item)
                if let highlighted = highlightedIndex {
                    if (highlighted == indexPath.row) {
                        cell.theBackgroundView.backgroundColor = UIColor(displayP3Red: 0.4, green: 0.6667, blue: 1.0, alpha: 1.0)
                    }
                    else {
                        cell.theBackgroundView.backgroundColor = UIColor.clear
                    }
                }
                else {
                    cell.theBackgroundView.backgroundColor = UIColor.clear
                }
                return cell
            }
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if ( collectionViewOneContents[indexPath.row] is CreateItem ) {
            
            self.performSegue(withIdentifier: "toCreateItem", sender: self)
            
        }
        else if ( collectionViewOneContents[indexPath.row] is Item ) {
            self.bigImageButton.isHidden = false
            self.bigImageButton.isEnabled = true
            print("pressed item cell at \(indexPath.row)")
            let item = collectionViewOneContents[indexPath.row] as! Item
            self.currentItem = item
            let cell = collectionView.cellForItem(at: indexPath) as! ItemCollectionViewCell
            clearAllCellBackgroundColors()
            cell.theBackgroundView.backgroundColor = UIColor(displayP3Red: 0.4, green: 0.6667, blue: 1.0, alpha: 1.0)
            self.highlightedIndex = indexPath.row
            if (item.editedImage != nil) {
                bigImageView.image = item.editedImage
            }
            else {
                bigImageView.image = item.originalImage
            }
            collectionViewOne.reloadData()
        }
        
    }
    
    func clearBackgroundColors(){
        var i = 0
        for (item) in collectionViewOneContents {
            let theItem = collectionViewOneContents[i]
            if (theItem  is CreateItem)  {
                continue
            }
            guard let imageItem = item as? Item else {
                continue
            }
            imageItem.highlightedBackground = false
            i += 1
        }
    }
    
    func clearAllCellBackgroundColors(){
        var i = 0
        for (item) in collectionViewOneContents {
            let theItem = collectionViewOneContents[i]
            if (theItem  is CreateItem)  {
                continue
            }
            guard let imageItem = item as? Item else {
                continue
            }
            imageItem.highlightedBackground = false 
            i += 1
        }
        //for (col) in collectionViewOneContents {
        for i  in 0 ..< collectionViewOne.numberOfItems(inSection: 0) {
            let item = collectionViewOneContents[i]
            if (item is CreateItem)  {
                continue
            }
            let indexPath = IndexPath(row: i, section: 0)
            guard let cell = collectionViewOne.cellForItem(at: indexPath) as? ItemCollectionViewCell else {
                continue
            }
            cell.theBackgroundView.backgroundColor = UIColor.clear
            cell.highlightedBackground = false
            // i += 1
        }
    }
    
    //////
    //
    // MARK: - Core Data
    //
    /////
    
    func fetchItemsFromCoreData() -> [AnyObject] {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return []
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "CDItem")
        
        let subOptionID = currentSubOption?.subOptionID
        
        fetchRequest.predicate = NSPredicate(format: "parentSubOptionID == %@", subOptionID!)
        
        var theItems = [AnyObject]()
        var theManagedItems = [NSManagedObject]()
        
        do {
            
            theManagedItems = try managedContext.fetch(fetchRequest)
            print("begin fetch")
            
            for oneManagedItem in theManagedItems {
                let oneItem = Item()
                oneItem.itemID     = oneManagedItem.value(forKeyPath: "itemID")   as? String
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
    
    /*
    func fetchItemsFromCoreData(with subOptionID:String) -> [AnyObject] {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return []
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "CDItem")
        
        let subOptionID = currentSubOption?.subOptionID
        print("sub option id  \(currentSubOption?.subOptionID)")
        
        fetchRequest.predicate = NSPredicate(format: "subOptionID == %@", subOptionID!)
        
        var theItems = [AnyObject]()
        var theManagedItems = [NSManagedObject]()
        do {
            theManagedItems = try managedContext.fetch(fetchRequest)
            for oneManagedItem in theManagedItems {
                let oneItem = Item()
                oneItem.caption    = oneManagedItem.value(forKeyPath: "caption")    as? String
                oneItem.imgUUID    = oneManagedItem.value(forKeyPath: "imgUUID")    as? String
                oneItem.imgPointer = oneManagedItem.value(forKeyPath: "imgPointer") as? String
                oneItem.itemID     = oneManagedItem.value(forKeyPath: "itemID")     as? String
                // oneItem.questionIconPositionsOne   = oneManagedItem.value( forKeyPath: "questionIconPositionsOne")   as? String
                // oneItem.questionIconPositionsTwo   = oneManagedItem.value( forKeyPath: "questionIconPositionsTwo")   as? String
                // oneItem.questionIconPositionsThree = oneManagedItem.value( forKeyPath: "questionIconPositionsThree") as? String
                
                oneItem.originalImage = imageStore.image(forKey: oneItem.imgUUID!)
                oneItem.editedImage = imageStore.image(forKey: oneItem.editedimgUUID!)
                
                /*
                 get image
                 
                 */
                
                theItems.append(oneItem)
                
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        theItems.append(CreateItem())
        
        return theItems
    }
    */
    
    func addItemToCurrentSubOptionCoreData(item: Item ){
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        let subOptionID = currentSubOption?.subOptionID
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
                //people.append(person)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
    }
    
    func createItemCompletion(image:UIImage , caption: String ){
        collectionViewOneContents.removeLast()
        // collectionViewOneContents.insert(Item(), at: indexPath.row-1)
        let item = Item()
        item.originalImage = image
        item.parentSubOptionID = currentSubOption?.subOptionID
        item.caption = caption
        collectionViewOneContents.append(item)
        collectionViewOneContents.append(CreateItem())
        collectionViewOne.reloadData()
        addItemToCurrentSubOptionCoreData(item: item)
    }
    
    
    //////
    //
    // MARK: - Image Pciker view
    //
    /////
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func captureImage(theview:UIView ) -> UIImage {
        
        UIGraphicsBeginImageContext(theview.frame.size)
        theview.layer.render(in:UIGraphicsGetCurrentContext()!)
        buttonOne.layer.render(in:UIGraphicsGetCurrentContext()!)
        buttonTwo.layer.render(in:UIGraphicsGetCurrentContext()!)
        buttonThree.layer.render(in:UIGraphicsGetCurrentContext()!)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //let croppedImage = image?.crop(rect: CGRect(x: 0, y: 100, width: 834, height: 800))
        let boundingBox = CGRect(x: 0, y: 330, width: 800, height: 530)
        let croppedCGImage:CGImage = (image!.cgImage?.cropping(to: boundingBox))!
        let croppedImage = UIImage(cgImage: croppedCGImage)
        
        self.currentItem!.editedImage = croppedImage
        self.currentItem?.editedimgUUID = NSUUID().uuidString
        
        saveCroppedImage()
        
        collectionViewOneContents = fetchItemsFromCoreData()
        self.collectionViewOne.reloadData()
        
        return croppedImage
    }

    func saveCroppedImage(){
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let currentItemId = self.currentItem?.itemID
        
        
        do {
            
            let itemfetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDItem")
            
            itemfetchRequest.predicate = NSPredicate(format: "itemID == %@", currentItemId!)
            
            let themanaged_Items = try managedContext.fetch(itemfetchRequest)
            
            if  themanaged_Items.count > 0 {
                
                let onemanaged_Item = themanaged_Items[0]
                
                onemanaged_Item.setValue(self.currentItem?.editedimgUUID,  forKeyPath: "editedimgPointer")
                
                imageStore.setImage(self.currentItem!.editedImage!, forKey: self.currentItem!.editedimgUUID!)
                
                //optionToUpdate.setValue(NSSet(object: cdQuestionList), forKey: "questionList")
                
                do {
                    try managedContext.save()
                    //people.append(person)
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCreateItem" ) {
            let createItem = segue.destination as! CreateItemViewController
            createItem.createItemCompletion = createItemCompletion
            collectionViewOneContents.removeLast()
            collectionViewOneContents.append(CreateItem())
            collectionViewOne.reloadData()
        }
        if (segue.identifier == "toBigImage" ) {
            // collectionViewOneContents = fetchItemsFromCoreData()
            let viewController = segue.destination as! BigImageViewController
            viewController.theImage = currentItem?.originalImage
            if let option = currentOption {
                viewController.currentOption = option
                viewController.thumbnailImageView = bigImageView
                viewController.currentItem = self.currentItem
                viewController.onDismiss = captureImage
            }
        }
        if (segue.identifier == "toQuestions") {
            let viewController = segue.destination as! QuestionsViewController
            if let option = currentOption {
                viewController.theQuestions = option.questionList
            }
        }
    }
    
    @IBAction func bigImageButtonPressed(_ sender: Any) {
        if (bigImageView.image != nil) {
            self.performSegue(withIdentifier: "toBigImage", sender: self)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func uploadToCloudButtonPressed(_ sender: Any) {
        self.comingSoonPopup()
    }
    /*
    @IBAction func buttonOnePressed(_ sender: Any) {
        print(" one pressed")
        //if (bigImageView.image != nil ) { //&&
        //self.buttonOne.bounds.int ersects(bigImageView.bounds) ) {
            self.performSegue(withIdentifier: "toQuestions", sender: self)
        //}
    }
    
    @IBAction func buttonTwoPressed(_ sender: Any) {
        //if (bigImageView.image != nil &&
        //    self.buttonTwo.bounds.intersects(bigImageView.bounds) ) {
            self.performSegue(withIdentifier: "toQuestions", sender: self)
        //}
    }
    
    @IBAction func buttonThreePressed(_ sender: Any) {
        //if (bigImageView.image != nil &&
        //    self.buttonThree.bounds.intersects(bigImageView.bounds) ) {
            self.performSegue(withIdentifier: "toQuestions", sender: self)
        //}
        
    }
    */
    
    ///////////////////
    //
    //    drop and drag
    //
    ///////////////////
    /*
    @objc func draggedButtonOne(_ sender:UIPanGestureRecognizer) {
        print(" one dragged")
        //self.view.bringSubview(toFront: self.buttonOne)
        let translation = sender.translation(in: self.view)
        buttonOne.center   = CGPoint(x: buttonOne.center.x + translation.x , y: buttonOne.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @objc func draggedButtonTwo(_ sender:UIPanGestureRecognizer) {
        print(" two dragged")
        // self.view.bringSubview(toFront: self.buttonTwo)
        let translation = sender.translation(in: self.view)
        buttonTwo.center   = CGPoint(x: buttonTwo.center.x + translation.x , y: buttonTwo.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @objc func draggedButtonThree(_ sender:UIPanGestureRecognizer) {
        print(" three dragged")
        // self.view.bringSubview(toFront: self.buttonThree)
        let translation = sender.translation(in: self.view)
        buttonThree.center = CGPoint(x: buttonThree.center.x + translation.x, y: buttonThree.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    */
    
    /*
    func draggedView(_ send:UIPanGestureRecognizer) {
            self.view.bringSubview(toFront: <#T##UIView#>)
    }
    */
    
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //let touch = event?.allTouches
        
        //let loc = touch
        print("touch lolz")
        let touch : UITouch! =  touches.first! as UITouch
        
        touchedLocationOne = touch.location(in: self.bigImageView)
        touchedLocationTwo = touch.location(in: self.buttonTwo)
        touchedLocationThree = touch.location(in: self.buttonThree)
        
        bigImageView.center = touchedLocationOne
        
      //      buttonTwo.center = touchedLocationTwo
        
      //      buttonThree.center  = touchedLocationThree
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("touch continue")
        
        let touch : UITouch! =  touches.first! as UITouch
        
        touchedLocationOne = touch.location(in: self.buttonOne)
        touchedLocationTwo = touch.location(in: self.buttonTwo)
        touchedLocationThree = touch.location(in: self.buttonThree)
        
        touchedLocationOne = touch.location(in: self.bigImageView)
        bigImageView.center = touchedLocationOne
        
       //  buttonOne.center = touchedLocationOne
        //buttonTwo.center = touchedLocationTwo
        //buttonThree.center  = touchedLocationThree
    }
    */
    
    
}
