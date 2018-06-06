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
    
    let baseLoginURL = "http://ec2-54-84-28-14.compute-1.amazonaws.com/alchemie"
    let baseURL = "http://Alchemiewebservice20171213043804.azurewebsites.net/service1.svc"
    let baseDownloadImageURL = "http://alchemiewebservice20171213043804.azurewebsites.net/service1.svc/downloadimage/"
    
    //for test
    // let baseURL = "localhost/alchemie"
    
    func loginUser(email:String, company:String, password:String, completion: @escaping (Bool)->()){
        let url = URL(string: "\(baseLoginURL)/loginUser.php")!
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
            
            // print(response)
            
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
    
    func downloadAnswers (guid: String,
                        completion: @escaping (Bool, [[String: AnyObject]])->()) {
        
        print ("begin fetch question set")
        
        //let url = URL(string: "\(baseURL)/UploadAnswers/\(imgPointer)")!
        
        //let url = URL(string: "\(baseURL)/UploadAnswers")!
        
        //let url = URL(string: "http://alchemiewebservice20171213043804.azurewebsites.net/service1.svc/uploadanswers")!
        
        //let url = URL(string: "http://alchemiewebservice20171213043804.azurewebsites.net/service1.svc/downloadanswers/\(guid)")!
        
        //let url = URL(string: "http://alchemiewebservice20171213043804.azurewebsites.net/service1.svc/downloadanswers")!
        
        let url = URL(string: "http://alchemiewebservice20171213043804.azurewebsites.net/service1.svc/GetAllAnswers")!
        
//        let parameters:[String : Any] = [
//
//            "AnswerSetInstanceID": answerSetInstanceID,
//            "AnswerSetXPosition": answerSetXPosition,
//            "AnswerSetYPosition": answerSetYPosition,
//            "AnswerText":"FIRST ANSWER",
//            "AnswerType":0,
//            "BackgroundID": backgroundID,
//            "ID" : id,
//            "ProjectID": projectID,
//            "QuestionNum": 1, // questionNum,
//            "QuestionSetID": questionSetID,
//            "SubmitTime":"/Date(1521838656020-0400)/",
//            "TabletID":"dfc7be2b-6d08-49a2-b855-9e7fbbf7c0de"
//
//            //"AnswerType": answerType,
//            //"Answer": answer
//        ]
     
        let parameters:[String : Any] = [
          
                    "BackgroundID": guid,
                    "ID" : guid,
                    "ProjectID": guid,
                    "imageguid": guid
            
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
        // Alamofire.req
        Alamofire.request(url, method:.get, parameters:parameters).validate(contentType: ["application/json", "text/html", "text/plain", "application/xml"]).responseString { response in
            
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
        
        // let json = String(data: jsonData!)
        let json = String(data: jsonData!, encoding:  String.Encoding.init(rawValue: 0x0000) )
        
        
        let jsonTest = String(describing:  "[{\"AnswerSetInstanceID\":\"\(answerSetInstanceID)\",\"AnswerSetXPosition\":\(answerSetXPosition),\"AnswerSetYPosition\":\(answerSetYPosition),\"AnswerText\":\"\(answer)\",\"AnswerType\":\(answerType),\"BackgroundID\":\"\(backgroundID)\",\"ID\":\"\(projectID)\",\"ProjectID\":\"\(projectID)\",\"QuestionNum\":\(questionNum),\"QuestionSetID\":\"\(questionSetID)\",\"SubmitTime\":\"\(time)\",\"TabletID\":\"\(tabletID)\"}]" )
        
        let data = json?.data(using: .init(rawValue: 0x0000))
        
        
        print(jsonData)
//        print(json)
//
        print(jsonTest)
        print(data)
        
        
        
        var request = URLRequest(url: url)
     
        Alamofire.request(url, method: .post, parameters: [:], encoding: jsonTest, headers: [:]).validate(contentType: ["application/json", "text/html", "text/plain", "application/xml", "raw"]).responseString { response in
            
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
//            response
            
            
            if (response.result.isSuccess) {
                completion(true, [[String: AnyObject]]())
                print("asnwers uploaded?  ")
            }
            else {
                completion(false, [[String: AnyObject]]())
            }
            
        }
       
        ////
        // Create the URLSession on the default configuration
        let defaultSessionConfiguration = URLSessionConfiguration.default
        let defaultSession = URLSession(configuration: defaultSessionConfiguration)

        // Setup the request with URL
        //let url = URL(string: "yourURL")
//        var urlRequest = URLRequest(url: url)  // Note: This is a demo, that's why I use implicitly unwrapped optional
//
//        // Convert POST string parameters to data using UTF8 Encoding
//        let postParams = jsonTest // "api_key=APIKEY&email=example@example.com&password=password"
//        let postData = postParams.data(using: .utf8)
//
//        // Set the httpMethod and assign httpBody
//        urlRequest.httpMethod = "POST"
//        urlRequest.httpBody = postData
//        urlRequest.addValue("raw", forHTTPHeaderField: "Content-Type")
        //urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
   
        
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
        
        //let url = URL(string: "\(baseURL)/UploadAnswers/\(imgPointer)")!
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
        
        //let url = URL(string: "\(baseURL)/UploadImage/\(imgPointer)")!
        let url = URL(string: "\(baseURL)/UploadImageMPF/\(imgPointer)")!
        
        let headers: HTTPHeaders = [
            /* "Authorization": "your_access_token",  in case you need authorization header */
            "Content-type": "text/plain"
        ]
        //"Content-type": "multipart/form-data"
        
        let parameters = ["ID" : imgPointer,
                          "ProjectID": imgPointer,
                          "guid" : imgPointer,
                          "image" : imgPointer,
                          "imageguid" : imgPointer
        ]
        
        //let imgData = UIImageJPEGRepresentation(theImage, 0.1)
        let imgData = UIImagePNGRepresentation(theImage)
        
//        let jpegimgData = UIImageJPEGRepresentation(theImage, 0.1)
//        
//        let jpegImg = UIImage(data: jpegimgData!)
//        
        //let imgData = UIImagePNGRepresentation(jpegImg!)
        
        let name = imgPointer //url.absoluteString
        //let fileName = "\(name)"
        let fileName = "\(name).png" //"\(name).jpg"
        
        let fileURL = ImageStore.sharedInstance.imageURL(forKey: fileName)
            //Bundle.main.url(forResource:  imgPointer, withExtension: "jpg")
        
//        Alamofire.upload(fileURL, to: url).responseJSON { // (data, response, error) in
//            ( response ) in
//            print(response)
////            guard let data = data, error == nil else {
////                print("error=(error)")
////                completion(false, [[String: AnyObject]]())
////                return
////            }
////            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
////                print("statusCode should be 200, but is (httpStatus.statusCode)")
////                print("response = (response)")
////                completion(false, [[String: AnyObject]]())
////                return
////            }
////            let responseString = String(data: data, encoding: .utf8)
////            print("responseString = \(responseString)")
//             completion(true, [[String: AnyObject]]())
//            print("----- the picture upload response -----")
//            print(response)
//            debugPrint(response)
//        }
        
//        Alamofire.upload(multipartFormData: { (data: MultipartFormData) in
//            data.append(imgData!, withName: name)
//        }, to: url.absoluteString) { [weak self] (encodingResult) in
//            switch encodingResult {
//            case .success(let upload, _, _):
//                upload.responseJSON { response in
//
//                    if     let dataDict = response.result.value as? NSDictionary {
//                        print(dataDict)
////                        if    let data = dataDict["data"] as? NSDictionary {
////                            print(data)
////                        }
////
////                        if let imgUrl = data["img_url"] as? String else {
////                            print(imgUrl)
////
////                        }
//                    }
//
//
//                    if (response.result.isSuccess) {
//                        completion(true, [[String: AnyObject]]())
//                    }
//                    else {
//                        completion(false, [[String: AnyObject]]())
//                    }
//
////                    self?.loadingSpinner.isHidden = true
////                    self?.loadingSpinner.stopAnimation(self?.view)
//                }
//            case .failure(let encodingError):
//                print(encodingError)
//                completion(false, [[String: AnyObject]]())
//            }
//        }

        Alamofire.upload(multipartFormData: { (multipartFormData) in

//            for (key, value) in parameters {
//                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
//            }

            if let data = imgData {
                multipartFormData.append(data,
                                         withName: name,
                                         fileName: fileName,
                                         mimeType: "image/png") // "image/jpeg")
                //multipartFormData.append(data, withName: name, fileName: fileName, mimeType: "image/png")
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
        //request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")

        //request.setValue("multipart/form-data; boundary=\(imgPointer)", forHTTPHeaderField: "Content-Type")

        //let imageData = UIImageJPEGRepresentation(imageView.image!, 1)

        //if(imageData==nil)  { return; }

        // request.HTTPBody = createBodyWithParameters(parameters, filePathKey: "file", imageDataKey: imgData!, boundary: nil)
//        request.httpBody = createBody(parameters: parameters,
//                                   boundary: imgPointer,
//                                   data: imgData!,
//                                   mimeType: "image/jpeg",
//                                   filename: fileName)

//        let boundary = generateBoundaryString()
//
//        request.httpBody = createBodyWithParameters(parameters: parameters, filePathKey: name, imageDataKey: imgData!, boundary: boundary)
//
//
//        //"image/jpeg"
//
//        let task = URLSession.shared.dataTask(with: request ) { (data, response, error) in
//            print(response)
//            guard let data = data, error == nil else {
//                print("error=(error)")
//                completion(false, [[String: AnyObject]]())
//                return
//            }
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//                print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                print("response = \(response)")
//            }
//            let responseString = String(data: data, encoding: .utf8)
//            print("responseString = \(responseString)")
//            completion(true, [[String: AnyObject]]())
//        }
//        task.resume()
        
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
    
//    func uploadImage (theImage:UIImage, imgPointer:String, completion: @escaping (Bool, [[String: AnyObject]])->() ) {
//
//        print ("begin image upload")
//
//        //let url = URL(string: "\(baseURL)/UploadImage/\(imgPointer)")!
//
//       // let downloadURL = baseDownloadImageURL + "\(imgPointer)"
//
//        let url = URL(string: "http://alchemiewebservice20171213043804.azurewebsites.net/service1.svc/uploadImage/\(imgPointer)")
//
//        let imgData = UIImageJPEGRepresentation(theImage, 0.2)!
//
//        if let data = UIImageJPEGRepresentation(theImage,1) {
//            //let parameters: Parameters = [
//            //    "access_token" : "YourToken"
//            //]
//            // You can change your image name here, i use NSURL image and convert into string
//            let imageURL = url // info[UIImagePickerControllerReferenceURL] as! NSURL
//            let fileName = url?.absoluteString
//            //absouluteString
//            // Start Alamofire
//
//            let imageToUploadURL =  Bundle.main.url(forResource: "tree", withExtension: "png")
//
//            // Server address (replace this with the address of your own server):
//            let theurl = url //"http://localhost:8888/upload_image.php"
//
//            let theCompressedImage = UIImageJPEGRepresentation(theImage, 0.3)
//
//            //UIImagePNGRepresentation
//            // Use Alamofire to upload the image
//            Alamofire.upload(
//                    multipartFormData: { multipartFormData in
//                                 // On the PHP side you can retrive the image using $_FILES["image"]["tmp_name"]
//                                 //multipartFormData.append(imageToUploadURL!, withName: "image")
//                                    multipartFormData.append(theCompressedImage!,
//                                                          // UIImagePNGRepresentation(theImage)!,
//                                                          withName: fileName!,
//                                                          mimeType: "image/jpeg")
//                                 //for (key, val) in parameters {
//                                 //   multipartFormData.append((val as! String).data(using: .utf8)!, withName: key)
//                                    /*//    multipartFormData.append(val.data(using: String.Encoding.utf8)!, withName: key)*/
//                                // }
//                         },
//                    to: url!,
//                    encodingCompletion: { encodingResult in
//
//                             switch encodingResult {
//
//                             case .success(let upload, _, _):
//
//                                print("upload response")
//                                print(upload)
//                                // completion(true, [[String: AnyObject]]())
//                                // upload.responseJSON { response in
//                                upload.responseString { response in
//
//                                     //if let jsonResponse = response.result.value as? [String: Any] {
//                                         print(response)
//
//                                        print(response.request)
//                                        print(" * ")
//                                        print(response.response)
//                                        print(" * ")
//                                        print(response.error)
//                                        print(" * ")
//                                        print(response.description)
//                                        print(" * ")
//                                        debugPrint(response.result)
//
//                                        if (response.result.isSuccess) {
//                                            completion(true, [[String: AnyObject]]())
//
//                                        }
//                                     //}
//                                 }
//
//                             case .failure(let encodingError):
//                                 completion(false, [[String: AnyObject]]())
//                                 print(encodingError)
//                             }
//                }
//            )
//
//        }
//
//    }
    
    
    func downloadImageTest (  imgPointer:String, completion: @escaping (Bool, [[String: AnyObject]])->() ) {
        
        print ("begin image upload")
        
        //let url = URL(string: "\(baseURL)/UploadImage/\(imgPointer)")!
        
        // let downloadURL = baseDownloadImageURL + "\(imgPointer)"
        
        let url = URL(string: "\(baseURL)/\(imgPointer)")!
        
        
        Alamofire.request(url, method:.get, parameters:nil).validate(contentType: ["application/json", "text/html", "text/plain", "application/xml"]).responseString { response in
            
            print(response)
            
        }
        
//        if let data = UIImageJPEGRepresentation(theImage,1) {
//            //let parameters: Parameters = [
//            //    "access_token" : "YourToken"
//            //]
//            // You can change your image name here, i use NSURL image and convert into string
//            let imageURL = url // info[UIImagePickerControllerReferenceURL] as! NSURL
//            let fileName = url?.absoluteString
//            //absouluteString
//            // Start Alamofire
//
//            let imageToUploadURL =  Bundle.main.url(forResource: "tree", withExtension: "png")
//
//            // Server address (replace this with the address of your own server):
//            let theurl = url //"http://localhost:8888/upload_image.php"
//
//            let theCompressedImage = UIImageJPEGRepresentation(theImage, 0.3)
//
//            //UIImagePNGRepresentation
//            // Use Alamofire to upload the image
////            Alamofire.upload(
////                multipartFormData: { multipartFormData in
////                    // On the PHP side you can retrive the image using $_FILES["image"]["tmp_name"]
////                    //multipartFormData.append(imageToUploadURL!, withName: "image")
////                    multipartFormData.append(theCompressedImage!,
////                                             // UIImagePNGRepresentation(theImage)!,
////                        withName: fileName!,
////                        mimeType: "image/jpeg")
////                    //for (key, val) in parameters {
////                    //   multipartFormData.append((val as! String).data(using: .utf8)!, withName: key)
////                    /*//    multipartFormData.append(val.data(using: String.Encoding.utf8)!, withName: key)*/
////                    // }
////            },
////                to: url!,
////                encodingCompletion: { encodingResult in
////
////                    switch encodingResult {
////
////                    case .success(let upload, _, _):
////
////                        print("upload response")
////                        print(upload)
////                        // completion(true, [[String: AnyObject]]())
////                        // upload.responseJSON { response in
////                        upload.responseString { response in
////
////                            //if let jsonResponse = response.result.value as? [String: Any] {
////                            print(response)
////                            
////                            print(response.request)
////                            print(" * ")
////                            print(response.response)
////                            print(" * ")
////                            print(response.error)
////                            print(" * ")
////                            print(response.description)
////                            print(" * ")
////                            debugPrint(response.result)
////                            
////                            if (response.result.isSuccess) {
////                                completion(true, [[String: AnyObject]]())
////
////                            }
////                            //}
////                        }
////
////                    case .failure(let encodingError):
////                        completion(false, [[String: AnyObject]]())
////                        print(encodingError)
////                    }
////            }
////            )
//            
//        }
        
    }
}

extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}
