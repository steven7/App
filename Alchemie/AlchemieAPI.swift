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
    
    func uploadAnswers (id: String,
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
                        completion: @escaping (Bool, [[String: AnyObject]])->()) {
        
        print ("begin fetch question set")
        
        //let url = URL(string: "\(baseURL)/UploadAnswers/\(imgPointer)")!
        
        //let url = URL(string: "\(baseURL)/UploadAnswers")!
        
        let url = URL(string: "http://alchemiewebservice20171213043804.azurewebsites.net/service1.svc/uploadanswers")!
        
        
        let parameters:[String : Any] = [
                          "ID" : id,
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
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        //request.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        //request.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        //request
        //request.httpBody
        //Alamofire.request(url, method: .post, parameters: parameters, encoding: nil, headers: nil) {
        //Alamofire.request(request).responseJSON { (response) in
        Alamofire.request(url, method:.post, parameters:parameters).validate(contentType: ["application/json", "text/html", "text/plain", "application/xml"]).responseString { response in
            
            //response in
            
            
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
            response
            // let result = response.result
            if (response.result.isSuccess) {
                completion(true, [[String: AnyObject]]())
                print("asnwers uploaded?  ")
            }
            else {
                completion(false, [[String: AnyObject]]())
            }
            
            
        }
    }
    
    func uploadAnswersOld (id: String,
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
        
        //let url = URL(string: "\(baseURL)/UploadAnswers/\(imgPointer)")!
        let url = URL(string: "\(baseURL)/UploadAnswers")!
        
        let downloadURL = baseDownloadImageURL + "\(imgPointer)"
        
        
        let parameters = ["ID" : id,
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
        //request.httpBody
        //Alamofire.request(url, method: .post, parameters: parameters, encoding: nil, headers: nil) {
        //Alamofire.request(request).responseJSON { (response) in
        Alamofire.request(url, method:.post, parameters:parameters,encoding: JSONEncoding.default).responseJSON { response in
             
            //response in
            
            completion(true, [[String: AnyObject]]())
            
            debugPrint(response)
            print(response.request)
            print(response.response)
            debugPrint(response.result)
            
            if let theanswers = response.result.value {
                print("asnwers uploaded?: \(theanswers)")
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
    }
    
    func uploadImage (theImage:UIImage, imgPointer:String, completion: @escaping (Bool, [[String: AnyObject]])->() ) {
        
        print ("begin image upload")
        
        //let url = URL(string: "\(baseURL)/UploadImage/\(imgPointer)")!
        
       // let downloadURL = baseDownloadImageURL + "\(imgPointer)"
        
        let url = URL(string: "http://alchemiewebservice20171213043804.azurewebsites.net/service1.svc/uploadImage/\(imgPointer)")
        
        let imgData = UIImageJPEGRepresentation(theImage, 0.2)!
        
        if let data = UIImageJPEGRepresentation(theImage,1) {
            //let parameters: Parameters = [
            //    "access_token" : "YourToken"
            //]
            // You can change your image name here, i use NSURL image and convert into string
            let imageURL = url // info[UIImagePickerControllerReferenceURL] as! NSURL
            let fileName = url?.absoluteString
            //absouluteString
            // Start Alamofire
            
            let imageToUploadURL =  Bundle.main.url(forResource: "tree", withExtension: "png")
        
            // Server address (replace this with the address of your own server):
            let theurl = url //"http://localhost:8888/upload_image.php"
            
            let theCompressedImage = UIImageJPEGRepresentation(theImage, 0.3)
            
            //UIImagePNGRepresentation
            // Use Alamofire to upload the image
            Alamofire.upload(
                    multipartFormData: { multipartFormData in
                                 // On the PHP side you can retrive the image using $_FILES["image"]["tmp_name"]
                                 //multipartFormData.append(imageToUploadURL!, withName: "image")
                                    multipartFormData.append(theCompressedImage!,
                                                          // UIImagePNGRepresentation(theImage)!,
                                                          withName: fileName!,
                                                          mimeType: "image/png")
                                 //for (key, val) in parameters {
                                 //   multipartFormData.append((val as! String).data(using: .utf8)!, withName: key)
                                    /*//    multipartFormData.append(val.data(using: String.Encoding.utf8)!, withName: key)*/
                                // }
                         },
                    to: url!,
                    encodingCompletion: { encodingResult in
                        
                             switch encodingResult {
                                
                             case .success(let upload, _, _):
                                
                                print("upload response")
                                print(upload)
                                // completion(true, [[String: AnyObject]]())
                                // upload.responseJSON { response in
                                upload.responseString { response in
                                    
                                     //if let jsonResponse = response.result.value as? [String: Any] {
                                         print(response)
                                    
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
                                     //}
                                 }
                                
                             case .failure(let encodingError):
                                 completion(false, [[String: AnyObject]]())
                                 print(encodingError)
                             }
                }
            )
            
        }
            /*
            Alamofire.upload(multipartFormData: { multipartFormData in
                for (key,value) in parameters {
                    multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                }
                multipartFormData.append(data, withName: "avatar", fileName: fileName!,mimeType: "image/jpeg")
            },
                             usingTreshold: UInt64.init(),
                             to: url,
                             method: .put,
                             encodingCompletion: { encodingResult in
                                switch encodingResult {
                                case .success(let upload, _, _):
                                    upload.responJSON { response in
                                        debugPrint(response)
                                    }
                                case .failure(let encodingError):
                                    print(encodingError)
                                }
            })
        }
        */
        /*
        Alamofire.upload(multipartFormData: multipartFormData in
                multipartFormData.append(imgData, withName: "fileset",fileName: "file.jpg", mimeType: "image/jpg")
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            },
                         to: url,
                         encodingCompletion: <#T##((SessionManager.MultipartFormDataEncodingResult) -> Void)?##((SessionManager.MultipartFormDataEncodingResult) -> Void)?##(SessionManager.MultipartFormDataEncodingResult) -> Void#>)
        //Alamofire.upload(imgData, to: url) { response in
            debugPrint(response)
        
            completion(true, [[String: AnyObject]]())
        
            print(response.request)
            print(" * ")
            print(response.response)
            print(" - ")
            print(response.error)
            print(" - ")
            print(response.description)
            print(" - ")
            debugPrint(response.result)
        
        }
        */
        /*
        Alamofire.request(downloadURL).responseImage { response in
            debugPrint(response)
            
            completion(true, [[String: AnyObject]]())
            
            print(response.request)
            print(" - ")
            print(response.response)
            print(" - ")
            print(response.error)
            print(" - ")
            print(response.description)
            print(" - ")
            debugPrint(response.result)
            
        }
 */
    }
    
    /*
    func uploadImage ( imgPointer:String, completion: @escaping (Bool, [[String: AnyObject]])->() ) {
        
        print ("begin fetch question set")
        
        let url = URL(string: "\(baseURL)/UploadImage/\(imgPointer)")!
        
        
        let downloadURL = baseDownloadImageURL + "\(imgPointer)"
        
        Alamofire.request(downloadURL).responseImage { response in
            debugPrint(response)
            
            completion(true, [[String: AnyObject]]())
            print(response.request)
            print(response.response)
            print(response.error)
            print(response.description)
            
            debugPrint(response.result)
            
        }
    }
    */
}
