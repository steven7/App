//
//  AlchemieAPI.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/20/17.
//  Copyright © 2017 steve. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import UIKit 

class AlchemieAPI: NSObject {
    
//    let baseLoginURL = "http://ec2-54-84-28-14.compute-1.amazonaws.com/alchemie"
//    let baseURL = "http://Alchemiewebservice20171213043804.azurewebsites.net/service1.svc"
//    let baseDownloadImageURL = "http://alchemiewebservice20171213043804.azurewebsites.net/service1.svc/downloadimage/"
    
    var baseLoginURL:String // = "http://ec2-54-84-28-14.compute-1.amazonaws.com/alchemie"
    var baseURL:String // = "http://Alchemiewebservice20171213043804.azurewebsites.net/service1.svc"
    var baseDownloadImageURL:String // = "http://alchemiewebservice20171213043804.azurewebsites.net/service1.svc/downloadimage/"
    
    //for test
    // let baseURL = "localhost/alchemie"
    
    static let shared = AlchemieAPI( )

    private override init( ) {
        self.baseLoginURL = "http://ec2-54-84-28-14.compute-1.amazonaws.com/alchemie"
        self.baseURL = "http://Alchemiewebservice20171213043804.azurewebsites.net/service1.svc"
        self.baseDownloadImageURL = "http://alchemiewebservice20171213043804.azurewebsites.net/service1.svc/downloadimage/"
    }
    
    func loginUser(email:String, company:String, password:String, completion: @escaping (Bool)->()){
        let url = URL(string: "\(baseLoginURL)/loginUser.php")!
        let parameters = ["email"    : email,
                          "company"  : company,
                          "password" : password]
        Alamofire.request(url, method: .post, parameters: parameters ).responseJSON { (response) in
            
            print(response)
            
            guard let responseJSON = response.result.value as? [String: Any] else {
                print("Invalid tag information received from the service")
                return
            }
            
            print(responseJSON)
            
            let success = responseJSON["success"] as! Bool
            
            if (success) {
                completion(true)
            }
            else {
                completion(false)
            }
             
        }
    }
    
    func createUser(email:String, company:String, password:String, completion: @escaping (Bool)->()){
        let url = URL(string: "\(baseLoginURL)/createUser.php")!
        let parameters = ["email"    : email,
                          "company"  : company,
                          "password" : password]
        Alamofire.request(url, method: .post, parameters: parameters ).responseJSON { (response) in
            
            print(response)
            
            guard let responseJSON = response.result.value as? [String: Any] else {
                print("Invalid tag information received from the service")
                completion(false)
                return
            }
            
            print(responseJSON)
            
            let success = responseJSON["success"] as! Bool
            
            if (success) {
                completion(true)
            }
            else {
                completion(false)
            }
            
        }
    }
    
    func logoutUser(completion: @escaping (Bool)->()){
        let url = URL(string: "\(baseLoginURL)/logoutUser.php")!
        Alamofire.request(url, method: .post, parameters: nil ).responseJSON { (response) in
            guard let responseJSON = response.result.value as? [String: Any] else {
                print("Invalid tag information received from the service")
                completion(false)
                return
            }
            print(responseJSON)
        }
    }
    
    func fetchOptions(completion: @escaping (Bool, [[String: AnyObject]])->()) {
        let url = URL(string: "\(baseURL)/GetOptions")!
        Alamofire.request(url, method: .get, parameters: nil ).responseJSON { (response) in
            
            guard let responseJSON = response.result.value as? [String: AnyObject] else {
                print("ERROR - \(response)")
                print("Invalid json information received from the service")
                
                completion(false, [[String: AnyObject]]())
                return
            }
            
            print(responseJSON)
            
            guard let options = responseJSON["GetOptionsResult"] as? [[String: AnyObject]] else {
                print("ERROR - \(response)")
                print("somethings wrong with the options data")
                completion(false, [[String: AnyObject]]())
                return
            }
            
            
            completion(true, options)
        }
    }
    
    func fetchOptionsBetter(completion: @escaping (Bool, [[String: AnyObject]])->()) {
        let url = URL(string: "\(baseURL)/GetOptionsExp")!
        Alamofire.request(url, method: .get, parameters: nil ).responseJSON { (response) in
            
            print(url)
            // print(response)
            
            guard let responseJSON = response.result.value as? [String: AnyObject] else {
                print("ERROR - \(response)")
                print("ERROR - \(response.result)")
                print("ERROR - \(response.value)")
                print("Invalid json information received from the service")
                completion(false, [[String: AnyObject]]())
                return
            }
            
            print(responseJSON)
            
            
            guard let options = responseJSON["GetOptionsExpResult"] as? [[String: AnyObject]] else {
                print("somethings wrong with the data")
                completion(false, [[String: AnyObject]]())
                return
            }
            
            
            completion(true, options)
        }
    }
    
    func fetchQuestionSet (completion: @escaping (Bool, [[String: AnyObject]])->()) {
    
        print ("begin fetch question set")
        
        let url = URL(string: "\(baseURL)/GetQuestionSet")!
        Alamofire.request(url, method: .get, parameters: nil ).responseJSON { (response) in
        
            print(" ------ the first response ------ ")
            print(response)
            
            guard let responseJSON = response.result.value as? [String: AnyObject] else {
                print("ERROR - \(response)")
                print("Invalid json information received from the service")
                completion(false, [[String: AnyObject]]())
                return
            }
            
            guard let questionSet = responseJSON["GetQuestionSetResult"] as? [[String: AnyObject]] else {
                print("somethings wrong with the data for get question set")
                completion(false, [[String: AnyObject]]())
                return
            }
            
            print(" ------ parsed as  GetQuestionSetResult ------ ")
            print(questionSet)
            
            completion(true, questionSet)
            
        }
    }
    
    func downloadImageForButton (button:UIButton, imgPointer:String ) {
        let url = URL(string: "\(baseURL)/\(imgPointer)")!
        
    }
    
    
    func downloadImage ( imgPointer:String, completion: @escaping (Bool, [[String: AnyObject]])->()) {
        
        print ("begin fetch question set")
        
        let url = URL(string: "\(baseURL)/\(imgPointer)")!
        
        let downloadURL = baseDownloadImageURL + "\(imgPointer)"
        
        Alamofire.request(downloadURL).responseImage { response in
            debugPrint(response)
            
            print(response.request)
            print(response.response)
            debugPrint(response.result)
            
            if let theimage = response.result.value {
                print("image downloaded: \(theimage)")
               
            }
        }
        
    }
    
    func downloadAnswers (guid: String,
                        completion: @escaping (Bool, [[String: AnyObject]])->()) {
        
        print ("begin fetch question set")
        
        
        let url = URL(string: "http://alchemiewebservice20171213043804.azurewebsites.net/service1.svc/GetAllAnswers")!
        
     
        let parameters:[String : Any] = [
          
                    "BackgroundID": guid,
                    "ID" : guid,
                    "ProjectID": guid,
                    "imageguid": guid
            
                ]
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
      
        Alamofire.request(url, method:.get, parameters:parameters).validate(contentType: ["application/json", "text/html", "text/plain", "application/xml"]).responseString { response in
            
            
            debugPrint(response)
            print(" - req")
            print(response.request)
            print(" - response")
            print(response.response)
            print(" - desc")
            print(response.description)
            print(" - resul")
            print()
            debugPrint()
            
            
            if (response.result.isSuccess) {
                completion(true, [[String: AnyObject]]())
                print("asnwers uploaded?  ")
            }
            else {
                completion(false, [[String: AnyObject]]())
            }
            
            
        }
    }
    
    func uploadAnswers (guid: String,
                        projectID: String,
                        questionSetID: String,
                        answerSetInstanceID: String,
                        backgroundID: String,
                        answerSetXPosition: Int,
                        answerSetYPosition: Int,
                        questionNum: Int,
                        answerType: Int,
                        imgPointer: String,
                        answer: String,
                        time: String,
                        tabletID: String,
                        completion: @escaping (Bool, [[String: AnyObject]])->()) {
        
        print ("begin fetch question set")
        
        let url = URL(string: "\(baseURL)/uploadanswers")!
        
        
        let parameters  = [
            
                          "AnswerSetInstanceID": answerSetInstanceID,
                          "AnswerSetXPosition": answerSetXPosition,
                          "AnswerSetYPosition": answerSetYPosition,
                          "AnswerText": answer,
                          "AnswerType": answerType,
                          "BackgroundID": backgroundID,
                          "ID" : projectID,
                          "ProjectID": projectID,
                          "QuestionNum": questionNum,
                          "QuestionSetID": questionSetID,
                          "SubmitTime": time,
                          "TabletID": tabletID
                           
        ] as Parameters
        
  
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        
        let json = String(data: jsonData!, encoding:  String.Encoding.init(rawValue: 0x0000) )
        
        
        let jsonTest = String(describing:  "[{\"AnswerSetInstanceID\":\"\(answerSetInstanceID)\",\"AnswerSetXPosition\":\(answerSetXPosition),\"AnswerSetYPosition\":\(answerSetYPosition),\"AnswerText\":\"\(answer)\",\"AnswerType\":\(answerType),\"BackgroundID\":\"\(backgroundID)\",\"ID\":\"\(projectID)\",\"ProjectID\":\"\(projectID)\",\"QuestionNum\":\(questionNum),\"QuestionSetID\":\"\(questionSetID)\",\"SubmitTime\":\"\(time)\",\"TabletID\":\"\(tabletID)\"}]" )
        
        let data = json?.data(using: .init(rawValue: 0x0000))
        
        
        print(jsonData)

        print(jsonTest)
        print(data)
        
        
        
        var request = URLRequest(url: url)
     
        Alamofire.request(url, method: .post, parameters: [:], encoding: jsonTest, headers: [:]).validate(contentType: ["application/json", "text/html", "text/plain", "application/xml", "raw"]).responseString { response in
            
            debugPrint(response)
            print(" - req")
            print(response.request)
            print(" - response")
            print(response.response)
            print(" - desc")
            print(response.description)
            print(" - resul")
            print()
            debugPrint()
            
            if (response.result.isSuccess) {
                completion(true, [[String: AnyObject]]())
                print("asnwers uploaded?  ")
            }
            else {
                completion(false, [[String: AnyObject]]())
            }
            
        }
       
        ////
        let defaultSessionConfiguration = URLSessionConfiguration.default
        let defaultSession = URLSession(configuration: defaultSessionConfiguration)
 
    }
    
    func uploadAnswersOld (guid: String,
                        projectID: String,
                        questionSetID: String,
                        answerSetInstanceID: String,
                        backgroundID: String,
                        answerSetXPosition: String,
                        answerSetYPosition: String,
                        questionNum: String,
                        answerType: String,
                        imgPointer: String,
                        answer: String,
                        completion: @escaping (Bool, [[String: AnyObject]])->()) {
        
        print ("begin fetch question set")
        
        
        let url = URL(string: "\(baseURL)/UploadAnswers")!
        
        let downloadURL = baseDownloadImageURL + "\(imgPointer)"
        
        
        let parameters = ["ID" : guid,
                          "ProjectID": projectID,
                          "QuestionSetID": questionSetID,
                          "AnswerSetInstanceID": answerSetInstanceID,
                          "BackgroundID": backgroundID,
                          "AnswerSetXPosition": answerSetXPosition,
                          "AnswerSetYPosition": answerSetYPosition,
                          "QuestionNum": questionNum,
                          "AnswerType": answerType,
                          "Answer": answer
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(url, method:.post, parameters:parameters,encoding: JSONEncoding.default).responseJSON { response in
            
            completion(true, [[String: AnyObject]]())
            
            debugPrint(response)
            print(response.request)
            print(response.response)
            debugPrint(response.result)
            
            if let theanswers = response.result.value {
                print("asnwers uploaded?: \(theanswers)")
            }
        }
    }
    
    
    
    func uploadImage (theImage:UIImage, imgPointer:String, completion: @escaping (Bool, [[String: AnyObject]])->() ) {
        
        
        let url = URL(string: "\(baseURL)/UploadImageMPF/\(imgPointer)")!
        
        let headers: HTTPHeaders = [
            "Content-type": "text/plain"
        ]
        
        
        let parameters = ["ID" : imgPointer,
                          "ProjectID": imgPointer,
                          "guid" : imgPointer,
                          "image" : imgPointer,
                          "imageguid" : imgPointer
        ]
        
        
        let imgData = UIImagePNGRepresentation(theImage)
      
        
        let name = imgPointer
        
        let fileName = "\(name).png"
        
        let fileURL = ImageStore.sharedInstance.imageURL(forKey: fileName)
    
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
 
            if let data = imgData {
                multipartFormData.append(data,
                                         withName: name,
                                         fileName: fileName,
                                         mimeType: "image/png")
                
            }

        }, usingThreshold: UInt64.init(), to: url.absoluteString, method: .post, headers: headers)  { (result) in

            switch result{
            case .success(let upload, _, _):
                upload.responseString { response in

                    print("Succesful reached !!")

                    if let error = response.error{
                        print("Error : \(error)")
                        print("Error in upload description: \(error.localizedDescription)")
                        completion(false, [[String: AnyObject]]())
                        print(error)
                        return
                    }

                    print(response)
                    print(" * ")
                    print(response.request)
                    print(" * ")
                    print(response.response)
                    print(" * ")
                    print(response.error)
                    print(" * ")
                    print(response.description)
                    print(" * ")
                    debugPrint(response.result)

                    if (response.result.isSuccess) {
                        completion(true, [[String: AnyObject]]())
                    }
                    else {
                        completion(false, [[String: AnyObject]]())
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(false, [[String: AnyObject]]())
                print(error)
            }

        }

        var request = URLRequest(url:url)
        request.httpMethod = "POST"

        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "test-picture.jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        return body as Data
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createBody(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
  
    func downloadImageTest (  imgPointer:String, completion: @escaping (Bool, [[String: AnyObject]])->() ) {
        
        print ("begin image upload")
        
        let url = URL(string: "\(baseURL)/\(imgPointer)")!
        
        
        Alamofire.request(url, method:.get, parameters:nil).validate(contentType: ["application/json", "text/html", "text/plain", "application/xml"]).responseString { response in
            
            print(response)
            
        }
 
    }
    
    /////////
    ///
    /// placement
    ///
    /////////
    
//    func fetchItemsFromCoreData(currentSubOption: SubOption) -> [AnyObject] {
//
//        guard let appDelegate =
//            UIApplication.shared.delegate as? AppDelegate else {
//                return []
//        }
//
//        let managedContext =
//            appDelegate.persistentContainer.viewContext
//
//        let fetchRequest =
//            NSFetchRequest<NSManagedObject>(entityName: "CDItem")
//
//        let subOptionID = currentSubOption.subOptionID
//
//        fetchRequest.predicate = NSPredicate(format: "parentSubOptionID == %@", subOptionID!)
//
//        var theItems = [AnyObject]()
//        var theManagedItems = [NSManagedObject]()
//
//        do {
//
//            theManagedItems = try managedContext.fetch(fetchRequest)
//            print("begin fetch")
//
//            var itemIdSet = Set<String>()
//
//            for oneManagedItem in theManagedItems {
//                let oneItem = Item()
//                oneItem.itemID   = oneManagedItem.value(forKeyPath: "itemID")   as? String
//                if (itemIdSet.contains(oneItem.itemID!)){
//                    print("dupe found")
//                    continue
//                }
//                else {
//                    itemIdSet.insert(oneItem.itemID!)
//                }
//                oneItem.caption    = oneManagedItem .value(forKeyPath: "caption") as? String
//                oneItem.imgUUID    = oneManagedItem .value(forKeyPath: "imgUUID") as? String
//                oneItem.imgPointer = oneManagedItem .value(forKeyPath: "imgPointer") as? String
//                oneItem.editedimgUUID = oneManagedItem.value(forKeyPath: "editedimgPointer") as? String
//                //oneItem.questionIconPositionsThree = oneManagedItem.value( forKeyPath: "questionIconPositionsThree") as? String
//
//                if let dataOne = oneManagedItem.value(forKey: "questionIconPositionsOne") as? Data {
//                    let unarchiveObjectOne = NSKeyedUnarchiver.unarchiveObject(with: dataOne)
//                    let arrayObjectOne = unarchiveObjectOne as AnyObject! as! [CGPoint]
//                    oneItem.questionIconPositionsOne = arrayObjectOne
//                }
//                else {
//                    oneItem.questionIconPositionsOne = [CGPoint]()
//                }
//
//                if let dataTwo = oneManagedItem.value(forKey: "questionIconPositionsTwo") as? Data {
//                    let unarchiveObjectTwo = NSKeyedUnarchiver.unarchiveObject(with: dataTwo)
//                    let arrayObjectTwo = unarchiveObjectTwo as AnyObject! as! [CGPoint]
//                    oneItem.questionIconPositionsTwo = arrayObjectTwo
//                }
//                else {
//                    oneItem.questionIconPositionsTwo = [CGPoint]()
//                }
//
//                if let dataThree = oneManagedItem.value(forKey: "questionIconPositionsThree") as? Data {
//                    let unarchiveObjectThree = NSKeyedUnarchiver.unarchiveObject(with: dataThree)
//                    let arrayObjectThree = unarchiveObjectThree as AnyObject! as! [CGPoint]
//                    oneItem.questionIconPositionsThree = arrayObjectThree
//                }
//                else {
//                    oneItem.questionIconPositionsThree = [CGPoint]()
//                }
//
//                ///
//                ///
//                ///
//                let questionInstancefetchRequest =
//                    NSFetchRequest<NSManagedObject>(entityName: "CDQuestionListInstance")
//
//                questionInstancefetchRequest.predicate = NSPredicate(format: "parentItemID == %@", oneItem.itemID!)
//
//                var theManagedInstances = try managedContext.fetch(questionInstancefetchRequest)
//
//                var buttonIdSet = Set<String>()
//
//                for instance in theManagedInstances {
//
//                    let oneButton = QuestionButton()
//
//                    oneButton.buttonInstanceID = instance.value(forKeyPath: "questionInstanceID") as? String
//
//                    if (buttonIdSet.contains(oneButton.buttonInstanceID!)){
//                        print("dupe found")
//                        continue
//                    }
//                    else {
//                        buttonIdSet.insert(oneButton.buttonInstanceID!)
//                    }
//
//                    oneButton.questionSetID    = instance.value(forKeyPath: "questionSetID") as? String
//                    oneButton.buttonTypeNumber = instance.value(forKeyPath: "questionInstanceType") as? Int
//                    oneButton.timeAnswered     = instance.value(forKeyPath: "timeAnswered") as? String
//
//                    if let dataPoint = instance.value(forKey: "buttonCenterPoint") as? Data {
//                        let unarchiveObjectThree = NSKeyedUnarchiver.unarchiveObject(with: dataPoint)
//                        let point = unarchiveObjectThree as AnyObject? as! CGPoint
//                        oneButton.setLocation(point: point)
//                    }
//                    else {
//                        oneButton.setLocation(point: CGPoint())
//                    }
//
//                    if (oneButton.buttonTypeNumber == 0) {
//                        oneItem.buttonOnes?.append(oneButton)
//                    }
//                    else if (oneButton.buttonTypeNumber == 1) {
//                        oneItem.buttonTwos?.append(oneButton)
//                    }
//                    else if (oneButton.buttonTypeNumber == 2) {
//                        oneItem.buttonThrees?.append(oneButton)
//                    }
//
//                    let questionInstanceAnswerfetchRequest =
//                        NSFetchRequest<NSManagedObject>(entityName: "CDQuestionAnswer")
//
//                    questionInstancefetchRequest.predicate = NSPredicate(format: "parentButtonID == %@", oneButton.buttonInstanceID!)
//
//                    let theAnswers = try managedContext.fetch(questionInstanceAnswerfetchRequest)
//
//
//                    for oneAnswer in theAnswers {
//
//
//                        let text = oneAnswer.value(forKeyPath: "questionAnswerText") as? String
//                        let number = oneAnswer.value(forKeyPath: "questionNumber") as? Int
//
//                        print("loading \(text) with \(number) from \(oneButton.buttonInstanceID!)")
//
//                        oneButton.addToAnswerMap(answer: text!, key: number!)
//
//                    }
//
//                }
//
//                oneItem.originalImage = ImageStore.sharedInstance.image(forKey: oneItem.imgUUID!)
//                if let editedImageID = oneItem.editedimgUUID {
//                    oneItem.editedImage = ImageStore.sharedInstance.image(forKey: editedImageID)
//                }
//                else {
//                    oneItem.editedImage = nil
//                }
//
//                print("one item!!")
//                print("  -  \(oneItem.caption)")
//                print("  -  \(oneItem.imgUUID)")
//                print("  -  \(oneItem.originalImage)")
//
//                theItems.append(oneItem)
//
//            }
//
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
//
//        theItems.append(CreateItem())
//
//        return theItems
//    }
    
    
    
//    func addItemToCurrentSubOptionCoreData(item: Item, currentSubOption: SubOption ){
//
//        guard let appDelegate =
//            UIApplication.shared.delegate as? AppDelegate else {
//                return
//        }
//        let managedContext =
//            appDelegate.persistentContainer.viewContext
//
//
//        let subOptionID = currentSubOption.subOptionID
//        let fetchRequest =
//            NSFetchRequest<NSManagedObject>(entityName: "CDSubOption")
//
//        fetchRequest.predicate = NSPredicate(format: "subOptionID == %@", subOptionID!)
//
//        do {
//
//            let subOptionsToUpdate = try managedContext.fetch(fetchRequest)
//            let subOptionToUpdate = subOptionsToUpdate[0]
//
//            let entity =
//                NSEntityDescription.entity(forEntityName: "CDItem",
//                                           in: managedContext)!
//            let cdItem = NSManagedObject(entity: entity,
//                                         insertInto: managedContext)
//
//
//            cdItem.setValue(item.caption,            forKeyPath: "caption")
//            cdItem.setValue(item.itemID,             forKeyPath: "itemID")
//            cdItem.setValue(item.imgUUID,            forKeyPath: "imgUUID")
//            cdItem.setValue(item.imgPointer,         forKeyPath: "imgPointer")
//            cdItem.setValue(subOptionID,             forKeyPath: "parentSubOptionID")
//            //cdItem.setValue(item.parentSubOptionID,  forKeyPath: "parentSubOptionID")
//
//            imageStore.setImage(item.originalImage!, forKey: item.imgUUID!)
//
//            let set = NSSet(object: cdItem)
//
//            subOptionToUpdate.setValue(set, forKey: "items")
//
//            do {
//                try managedContext.save()
//                //people.append(person)
//            } catch let error as NSError {
//                print("Could not save. \(error), \(error.userInfo)")
//            }
//
//        }
//        catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
//
//
//    }
    
//    func saveCroppedImage(currentItem: Item){
//
//        guard let appDelegate =
//            UIApplication.shared.delegate as? AppDelegate else {
//                return
//        }
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//
//        let currentItemId = currentItem.itemID
//
//
//        do {
//
//            let itemfetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDItem")
//
//            itemfetchRequest.predicate = NSPredicate(format: "itemID == %@", currentItemId!)
//
//            let themanaged_Items = try managedContext.fetch(itemfetchRequest)
//
//            if  themanaged_Items.count > 0 {
//
//                let onemanaged_Item = themanaged_Items[0]
//
//                onemanaged_Item.setValue(currentItem.editedimgUUID,  forKeyPath: "editedimgPointer")
//
//                ImageStore.sharedInstance.setImage(currentItem.editedImage!, forKey: currentItem.editedimgUUID!)
//
//                do {
//                    try managedContext.save()
//                    //people.append(person)
//                } catch let error as NSError {
//                    print("Could not save. \(error), \(error.userInfo)")
//                }
//            }
//        }
//        catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
//    }
    
    /////////
    ///
    ///   Big image 
    ///
    /////////
    
    func saveButtonPositionsToCoreData(buttonOnes:[QuestionButton], buttonTwos:[QuestionButton], buttonThrees:[QuestionButton],  currentItem: Item) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let currentItemId = currentItem.itemID
        
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
                let parentItemID = currentItem.itemID
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
                let parentItemID = currentItem.itemID
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
                let parentItemID = currentItem.itemID
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
}

extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}
