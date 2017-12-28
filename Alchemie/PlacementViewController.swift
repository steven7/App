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
    
    var collectionViewOneContents = [AnyObject]()
    var collectionViewTwoContents = [AnyObject]()
    
    var currentSubOption:SubOption?
    
    var optionTitle:String?
    var subOptionOneTitle:String?
    var subOptionTwoTitle:String?
    
    let imageStore = ImageStore.sharedInstance
    
    var highlightedIndex:Int?
    
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
        
        collectionViewOneContents = fetchItemsFromCoreData()
        
        collectionViewOne.delegate = self
        collectionViewOne.dataSource = self
        
        self.bigImageButton.isHidden = true
        self.bigImageButton.isEnabled = false
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //collectionViewOneContents = fetchItemsFromCoreData()
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
                
                /*
                if (item.highlightedBackground)! {
                    cell.theBackgroundView.backgroundColor = UIColor(displayP3Red: 0.4, green: 0.6667, blue: 1.0, alpha: 1.0)
                }
                else {
                    cell.theBackgroundView.backgroundColor = UIColor.clear
                }
                */
                // let imageView = UIImageView(image: item.image)
                // cell.contentView.addSubview()
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
            let cell = collectionView.cellForItem(at: indexPath) as! ItemCollectionViewCell
            // clearAllCellBackgroundColors()
            //clearBackgroundColors()
            clearAllCellBackgroundColors()
            cell.theBackgroundView.backgroundColor = UIColor(displayP3Red: 0.4, green: 0.6667, blue: 1.0, alpha: 1.0)
            //cell.highlightedBackground = true
            //item.highlightedBackground = true
            self.highlightedIndex = indexPath.row
            bigImageView.image = item.image
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
                oneItem.caption    = oneManagedItem .value(forKeyPath: "caption") as? String
                oneItem.imgUUID    = oneManagedItem .value(forKeyPath: "imgUUID") as? String
                oneItem.imgPointer = oneManagedItem .value(forKeyPath: "imgPointer") as? String
                
                
                oneItem.image = imageStore.image(forKey: oneItem.imgUUID!)
                
                
                print("one item!!")
                print("  -  \(oneItem.caption)")
                print("  -  \(oneItem.imgUUID)")
                print("  -  \(oneItem.image)")
                
                /*
                get image
 
                */
                
                theItems.append(oneItem)
                /*
                let itemfetchRequest =
                    NSFetchRequest<NSManagedObject>(entityName: "CDItem")
                let userToSearch = "e@e.com"
                itemfetchRequest.predicate = NSPredicate(format: "parentOptionID == %@", (currentSubOption?.subOptionID!)!)
                do {
                    let theManaged_SubOptions = try managedContext.fetch(itemfetchRequest)
                    for oneManaged_SubOption in theManaged_SubOptions {
                        let oneSubOption = SubOption()
                 
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
                        oneSubOption.subOptionID = oneManaged_SubOption.value(forKeyPath: "subOptionID") as? String
                        oneSubOption.parentOptionID = oneManaged_SubOption.value(forKeyPath: "parentOptionID") as? String
                 
                        theItems.append(oneSubOption)
                    }
                }
                     subOption.name,            forKeyPath: "name")
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
                     cdSubOption.setValue(subOption.parentOptionID
                catch  let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
                
                //let theSubOptions = oneManagedOption.value(forKey: "subOptions")
                //for sub in theSubOptions {
                //    print(sub)
                //}
                */
                
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        theItems.append(CreateItem())
        
        return theItems
    }
    
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
                oneItem.caption    = oneManagedItem .value(forKeyPath: "caption") as? String
                oneItem.imgUUID    = oneManagedItem .value(forKeyPath: "imgUUID") as? String
                oneItem.imgPointer = oneManagedItem .value(forKeyPath: "imgPointer") as? String
                
                oneItem.image = imageStore.image(forKey: oneItem.imgUUID!)
                
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
            cdItem.setValue(item.imgUUID,            forKeyPath: "imgUUID")
            cdItem.setValue(item.imgPointer,         forKeyPath: "imgPointer")
            cdItem.setValue(item.parentSubOptionID,  forKeyPath: "parentSubOptionID")
 
            imageStore.setImage(item.image!, forKey: item.imgUUID!)
            
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
        item.image = image
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCreateItem" ) {
            let createItem = segue.destination as! CreateItemViewController
            createItem.createItemCompletion = createItemCompletion
            collectionViewOneContents.removeLast()
            collectionViewOneContents.append(CreateItem())
            collectionViewOne.reloadData()
        }
        if (segue.identifier == "toBigImage" ) {
            let viewController = segue.destination as! BigImageViewController
            viewController.theImage = bigImageView.image
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
    
}
