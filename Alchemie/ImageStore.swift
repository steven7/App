//
//  ImageStore.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 12/23/17.
//  Copyright © 2017 steve. All rights reserved.
//

import Foundation
import UIKit


class ImageStore {
    
    static let sharedInstance: ImageStore = ImageStore()
    
    let cache = NSCache<NSString, UIImage>()
    
    func setImagePNG( _ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
        
        // Create full URL for image
        let url = imageURL(forKey: key)
        
        // Turn image into jpeg data
//        if let data = UIImageJPEGRepresentation(image, 0.5) {
//            // Write it to full URL
//            let _ = try? data.write(to: url, options: [.atomic])
//        }
        
        // Turn image into png data
        if let data = UIImagePNGRepresentation(image) {
            // Write it to full URL
            let _ = try? data.write(to: url, options: [.atomic])
        }
        
    }
    
    func setImage( _ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
        
        // Create full URL for image
        let url = imageURL(forKey: key)
        
        // Turn image into jpeg data
        if let data = UIImageJPEGRepresentation(image, 0.5) {
            // Write it to full URL
            let _ = try? data.write(to: url, options: [.atomic])
        }
        
    }
    
    //
    func image(forKey key: String) -> UIImage? {
        
        if let existingImage = cache.object(forKey:  key as NSString) {
            return existingImage
        }
        
        let url = imageURL(forKey: key)
        guard let imageFromDisk = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        
        cache.setObject(imageFromDisk, forKey: key as NSString)
        return imageFromDisk
    }
 
    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        
        let url = imageURL(forKey: key)
        do {
            try FileManager.default.removeItem(at: url)
        } catch let deleteError {
            print("Error removing the image from disk: \(deleteError)")
        }
    }
    
    func imageURL(forKey key: String) -> URL {
        
        let documentDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentDirectories.first!
        
        return documentDirectory.appendingPathComponent(key)
    }
    
}

