//
//  ImageStore.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/23/17.
//  Copyright © 2017 steve. All rights reserved.
//

import Foundation
import UIKit

/*
class ImageStore {
    
    static let sharedInstance: ImageStore = ImageStore()
    
    let cache = NSCache()
    
    func setImage(image: UIImage, forKey key: String){
        print(image)
        print(key)
        print("this work?")
        
        // Ceate full URL for image
        let imageURL = imageURLForKey(key: key)
        print("image \(image) should be inserted at \(imageURL)")
        
        // Turn image into JPEG data
        if let data = UIImageJPEGRepresentation(image, 0.5){
            // Write it to full URL
            data.write(to: imageURL as URL, options: [])
            // ToURL(imageURL, atomically: true)
            print("now wrote to url")
        }
        
    }
    
    func imageForKey(key: String) -> UIImage?{
        
        print("image for key start")
        
        if let existingImage = cache.objectForKey(key) as? UIImage{
            print("is there an existing image?")
            return existingImage
        }
        
        let imageURL = imageURLForKey(key: key)
        
        print("image should be found at \(imageURL)")
        
        guard let imageFromDisk = UIImage(contentsOfFile: imageURL.path!) else{
            print("we got a nil")
            return nil
        }
        print("before cache")
        cache.setObject(imageFromDisk, forKey: key)
        print("after cache")
        return imageFromDisk
    }
    
    func deleteImageForKey(key:String){
        cache.removeObjectForKey(key)
        
        let imageURL = imageURLForKey(key: key)
        do{
            try FileManager.defaultManager.removeItem(at: imageURL as URL)
        }catch let deleteError{
            print("Error removing the image from disk \(deleteError)")
        }
    }
    
    func imageURLForKey(key: String) -> NSURL {
        
        print("image URL for key start")
        
        let documentsDirectories = FileManager.default.urls(for: .documentDirectorydocumentDirectory,
                                                            in: .userDomainMask)
        
        
        let documentDirectory = documentsDirectories.first!
        
        //if let docDir = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first,
        //    let filePath = docDir.URLByAppendingPathComponent("savedObject.data").filePathURL?.path{
        //}
        
        return documentDirectory.absoluteURL.appendingPathComponent(key) as NSURL
        // ByAppendingPathComponent(key)!//.filePathURL?
    }
    
}
*/
