//
//  AlchemieAPI.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/20/17.
//  Copyright © 2017 steve. All rights reserved.
//

import UIKit
import Alamofire

class AlchemieAPI: NSObject {
    
    let baseURL = "http://ec2-54-84-28-14.compute-1.amazonaws.com/alchemie"
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
    
}
