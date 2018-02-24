//
//  AlchemieAPI.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/20/17.
//  Copyright © 2017 steve. All rights reserved.
//

import UIKit
import Alamofire
// import AlamofireImage

class AlchemieAPI: NSObject {
    
    let baseURL = "http://ec2-54-84-28-14.compute-1.amazonaws.com/alchemie"
    let baseDownloadImageURL = "http://alchemiewebservice20171213043804.azurewebsites.net/service1.svc/downloadimage/"
    
    //for test
    // let baseURL = "localhost/alchemie"
    
    func loginUser(email:String, company:String, password:String, completion: @escaping (Bool)->()){
        let url = URL(string: "\(baseURL)/loginUser.php")!
        let parameters = ["email"    : email,
                          "company"  : company,
                          "password" : password]
        Alamofire.request(url, method: .post, parameters: parameters ).responseJSON { (response) in
            
            print(response)
            
            guard let responseJSON = response.result.value as? [String: Any] else {
                print("Invalid tag information received from the service")
                //completion(false)
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
        let url = URL(string: "\(baseURL)/createUser.php")!
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
        let url = URL(string: "\(baseURL)/logoutUser.php")!
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
        let url = URL(string: "http://Alchemiewebservice20171213043804.azurewebsites.net/service1.svc/GetOptions")!
        Alamofire.request(url, method: .get, parameters: nil ).responseJSON { (response) in
            
            // print(response)
            
            guard let responseJSON = response.result.value as? [String: AnyObject] else {
                print("Invalid tag information received from the service")
                completion(false, [[String: AnyObject]]())
                return
            }
            
            print(responseJSON)
            
            
            guard let options = responseJSON["GetOptionsResult"] as? [[String: AnyObject]] else {
                print("somethings wrong with the data")
                completion(false, [[String: AnyObject]]())
                return
            }
            
            
            completion(true, options)
        }
    }
    
    func fetchOptionsBetter(completion: @escaping (Bool, [[String: AnyObject]])->()) {
        let url = URL(string: "http://Alchemiewebservice20171213043804.azurewebsites.net/service1.svc/GetOptionsExp")!
        Alamofire.request(url, method: .get, parameters: nil ).responseJSON { (response) in
            
            // print(response)
            
            guard let responseJSON = response.result.value as? [String: AnyObject] else {
                print("Invalid tag information received from the service")
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
        
        let url = URL(string: "http://Alchemiewebservice20171213043804.azurewebsites.net/service1.svc/GetQuestionSet")!
        Alamofire.request(url, method: .get, parameters: nil ).responseJSON { (response) in
        
            print(" ------ the first response ------ ")
            print(response)
            
            guard let responseJSON = response.result.value as? [String: AnyObject] else {
                print("Invalid tag information received from the service")
                completion(false, [[String: AnyObject]]())
                return
            }
            
            //print(responseJSON)
            
            
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
        let url = URL(string: "http://alchemiewebservice20171213043804.azurewebsites.net/service1.svc/downloadimage/\(imgPointer)")!
        /*
        Alamofire.request(url).responseImage { response in
            debugPrint(response)
            
            print(response.request)
            print(response.response)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
            }
            DispatchQueue.main.async {
                button.setBackgroundImage(image, for: .normal)
                // button.titleLabel?.text = ""
                button.setTitle("", for: .normal)
            }
        }*/
    }
    
    
    func downloadImage ( imgPointer:String, completion: @escaping (Bool, [[String: AnyObject]])->()) {
        
        print ("begin fetch question set")
        
        let url = URL(string: "http://alchemiewebservice20171213043804.azurewebsites.net/service1.svc/downloadimage/\(imgPointer)")!
        
        let downloadURL = baseDownloadImageURL + "\(imgPointer)"
        
        Alamofire.request(downloadURL).responseImage { response in
            debugPrint(response)
            
            print(response.request)
            print(response.response)
            debugPrint(response.result)
            
            if let theimage = response.result.value {
                print("image downloaded: \(theimage)")
                /*
                // should probably do this in queue after images download
                let item = Item()
                /// <-----  fix this ---->
                item.image = theimage // UIImage(named: "questionSetIcon2") // this is temporary image. change it soon
                item.imgUUID = imgPointer
                item.imgPointer = imgPointer
                item.parentSubOptionID = newSubOption.subOptionID
                item.caption = title
                
                print("one download complete   \(title) on subOtion \(newSubOption.name) and option \(newOption.title) ")
                self.addItemToCurrentSubOptionCoreData(subOption: newSubOption,  item: item )
                */
            }
        }
        /*
        Alamofire.request(url).responseImage { response in
            debugPrint(response)
            
            print(response.request)
            print(response.response)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
            }
        } */
    }
}
