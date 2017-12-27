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

class OptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var syncButton: UIButton!
    
    var options = [AnyObject]()
    //NSMutableArray()
    //[Option]()
    //var options = [NSManagedObject]()
    
    var currentUserName:String?
    var currentSubOption:SubOption?
    var currentOptionTitle:String?
    var currentSubOptionTitle:String?
    
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
        
        // self.currentUserName = "e@e.com" //appDelegate.currentUserName
        
        self.currentUserName = KeychainWrapper.standard.string(forKey: "userName")
            //appDelegate.currentUserName
        
        // fetchOptionsFromCoreData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        options = fetchOptionsFromCoreData()
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
            //let cell = UITableViewCell()
            //cell.textLabel?.text = o.title
            //cell.textLabel?.text = options[indexPath.row].value(forKey: "optionDescription") as? String
            //cell.textLabel?.textAlignment = .left
            //cell.textLabel?.font.withSize(36.0)
            let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell") as! OptionTableViewCell
            cell.OptionCellLabel.text = o.title
            
            return cell
        }
        else if (option is SubOption) {
            let s = option as! SubOption
            let cell = UITableViewCell()
            cell.textLabel?.text = s.name
            //cell.textLabel?.text = options[indexPath.row].value(forKey: "optionDescription") as? String
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
    
    func createOptionPopup(){
        let alert = UIAlertController(title: "Create New Option", message: "Enter the title for the new option", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let cancelAction = UIAlertAction(title: "Canel", style: .cancel, handler: nil)
        let createAction = UIAlertAction(title: "Create", style: .default, handler: { action in
            let createdOption = Option()
            createdOption.title = alert.textFields![0].text
            createdOption.user = self.currentUserName
            self.options.removeLast()
            self.options.append(createdOption)
            self.options.append(CreateSubOption(withParent: createdOption))
            self.options.append(CreateOption())
            self.createOptionWithCoreData(with: createdOption)
            self.tableView.reloadData()
        })
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func createSubOptionPopup(withParent option:Option, atRow row:Int ){
        let alert = UIAlertController(title: "Create New Sub Option", message: "Enter the title for the new sub option", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let cancelAction = UIAlertAction(title: "Canel", style: .cancel, handler: nil)
        let createAction = UIAlertAction(title: "Create", style: .default, handler: { action in
            let createdSubOption = SubOption()
            createdSubOption.name = alert.textFields![0].text
            createdSubOption.parentOption = option
            createdSubOption.parentOptionID = option.optionID
            self.options.insert(createdSubOption, at: row)
            self.createSubOptionWithCoreData(with: createdSubOption)
            self.tableView.reloadData()
        })
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    ///////////////////////////////
    //
    //    Core data
    //
    ///////////////////////////////
    
    func createOptionWithCoreData(with option:Option){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "CDOption",
                                       in: managedContext)!
        let cdOption = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        cdOption.setValue(option.title, forKeyPath: "title")
        cdOption.setValue(option.optionID, forKeyPath: "optionID")
        cdOption.setValue(option.status, forKeyPath: "status")
        cdOption.setValue(option.optionDescription, forKeyPath: "optionDescription")
        cdOption.setValue(option.type, forKeyPath: "type")
        cdOption.setValue(option.user, forKeyPath: "user")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func createSubOptionWithCoreData(with subOption:SubOption){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let parentOptionID = subOption.parentOption?.optionID
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "CDOption")
        
        fetchRequest.predicate = NSPredicate(format: "optionID == %@", parentOptionID!)
        
        do {
            let optionsToUpdate = try managedContext.fetch(fetchRequest)
            let optionToUpdate = optionsToUpdate[0]
            
            let entity =
                NSEntityDescription.entity(forEntityName: "CDSubOption",
                                           in: managedContext)!
            let cdSubOption = NSManagedObject(entity: entity,
                                              insertInto: managedContext)
            
            // optionToUpdate.setValue(NSSet(object: newAddress), forKey: "addresses")
            
            cdSubOption.setValue(subOption.name,            forKeyPath: "name")
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
            cdSubOption.setValue(subOption.parentOptionID,  forKeyPath: "parentOptionID")
            
            optionToUpdate.setValue(NSSet(object: cdSubOption), forKey: "subOptions")
            
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
    
    func fetchOptionsFromCoreData() -> [AnyObject] {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return []
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "CDOption")
        
        fetchRequest.predicate = NSPredicate(format: "user == %@", self.currentUserName!)
        
        var theOptions = [AnyObject]()
        var theManagedOptions = [NSManagedObject]()
        do {
            theManagedOptions = try managedContext.fetch(fetchRequest)
            for oneManagedOption in theManagedOptions {
                let oneOption = Option()
                oneOption.title = oneManagedOption.value(forKeyPath: "title") as? String
                oneOption.user = oneManagedOption.value(forKeyPath: "user") as? String
                oneOption.optionID = oneManagedOption.value(forKeyPath: "optionID") as? String
                oneOption.status = oneManagedOption.value(forKeyPath: "status") as? String
                oneOption.optionDescription = oneManagedOption.value(forKeyPath: "optionDescription") as? String
                oneOption.type = oneManagedOption.value(forKeyPath: "type") as? String
                
                theOptions.append(oneOption)
                
                let subfetchRequest =
                    NSFetchRequest<NSManagedObject>(entityName: "CDSubOption")
                let userToSearch = "e@e.com"
                subfetchRequest.predicate = NSPredicate(format: "parentOptionID == %@", oneOption.optionID!)
                do {
                    let theManaged_SubOptions = try managedContext.fetch(subfetchRequest)
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
                        theOptions.append(oneSubOption)
                    }
                }/*
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
                cdSubOption.setValue(subOption.parentOptionID*/
                catch  let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
                
                //let theSubOptions = oneManagedOption.value(forKey: "subOptions")
                //for sub in theSubOptions {
                //    print(sub)
                //}
                
                theOptions.append(CreateSubOption(withParent: oneOption))
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        theOptions.append(CreateOption())
        
        return theOptions
    }
    
    func eraseOptionsFromCoreDataWithCurrentUser() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "CDOption")
        
        fetchRequest.predicate = NSPredicate(format: "user == %@", self.currentUserName!)
        
        do {
            let theManagedOptions = try managedContext.fetch(fetchRequest)
            
            for oneManagedOption in theManagedOptions {
                
                managedContext.delete(oneManagedOption)
            }
            
            appDelegate.saveContext()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "optionsToPlacement") {
            let placementViewController = segue.destination as! PlacementViewController
            placementViewController.optionTitle = currentOptionTitle
            placementViewController.subOptionOneTitle = currentSubOptionTitle
            placementViewController.currentSubOption = currentSubOption
        }
    }
    
    @IBAction func syncButtonPressed(_ sender: Any) {
        
        if ( !Reachability.isConnectedToNetwork() ) {
            notConnectedToInternetPopup()
            return
        }
        
        overwriteWarningPopup(completion: {
            self.syncOperation()
        })
        
    }
    
    func syncOperation() {
        SVProgressHUD.show()
        let api = AlchemieAPI()
        api.fetchOptions(completion: {   success, response in
            if (success) {
                print("lololz")
                self.eraseOptionsFromCoreDataWithCurrentUser()
                let downloadedOptions = self.getOptionsFromJSON(withJSON: response)
                self.options.removeAll()
                self.options = downloadedOptions
                self.tableView.reloadData()
            }
            else {
                self.errorPopup()
            }
            SVProgressHUD.dismiss()
        })
    }
    
    func getOptionsFromJSON(withJSON json:[[String: AnyObject]] ) -> [AnyObject] {
        
        var theOptions = [AnyObject]()
        for option in json {
            guard let optionName = option["OptionName"] as? String else {
                print("somethings wrong with the data")
                return [AnyObject]()
            }
            let newOption = Option()
            newOption.title = optionName
            newOption.user = self.currentUserName
            theOptions.append(newOption)
            createOptionWithCoreData(with: newOption)
            guard let subOptions = option["Suboptions"] as? [[String: AnyObject]]else {
                print("somethings wrong with the data")
                return [AnyObject]()
            }
            
            // sub options
            for suboption in subOptions  {
                guard let suboptionName = suboption["Suboption"] as? String else {
                    print("somethings wrong with the data")
                    return [AnyObject]()
                }
                let newSubOption = SubOption()
                newSubOption.name = suboptionName
                newSubOption.parentOption = newOption
                newSubOption.parentOptionID = newOption.optionID
                guard let imageList = suboption["ImagesList"] as? [[String: AnyObject]] else {
                    print("somethings wrong with the data")
                    return [AnyObject]()
                }
                
                // sub option images
                for image in imageList {
                    /*
                    guard let imgPointer = image["ImgPointer"] as? String else {
                        print("somethings wrong with the data")
                        return [AnyObject]()
                    }
                    */
                    
                    let imgPointer = image["ImgPointer"] as? String
                    
                    guard let title = image["Title"] as? String else {
                        print("somethings wrong with the data")
                        return [AnyObject]()
                    }
                }
                theOptions.append(newSubOption)
                createSubOptionWithCoreData(with: newSubOption)
            }
            theOptions.append(CreateSubOption(withParent: newOption))
        }
        theOptions.append(CreateOption()) ///  - dont do this its put there automatically
        return theOptions
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        logoutPopup {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
