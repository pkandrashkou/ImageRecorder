//
//  ImageCollector.swift
//  ImageRecorder
//
//  Created by Pavel Kondrashkov on 8/18/17.
//  Copyright © 2017 Pavel Kondrashkov. All rights reserved.
//

import UIKit
import Foundation


class ImageCollector {
    
    typealias ImageCollectionId = String
    
    static let collectorCacheDirectory = "ImageCollector"
    
    fileprivate let collectionId: ImageCollectionId
    

    init(collectionId: ImageCollectionId) {
        self.collectionId = collectionId
    }
    
    func addImage(_ image: UIImage) {
        saveImage(image)
    }
    
    func removeImage(_ image: UIImage) {
        removeCachedImage(image)
    }
    
    func imageURLs() -> [URL] {
        guard let urls = try? FileManager.default.contentsOfDirectory(at: imagesDirectoryURL, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles) else {
            return []
        }
        return urls.sorted { (first, second) -> Bool in
            guard let firstInt = Int(first.deletingPathExtension().lastPathComponent), let secondInt = Int(second.deletingPathExtension().lastPathComponent) else {
                return false
            }
            return firstInt < secondInt 
        }
    }
    
    func clearCollection() {
        removeCollectionFolder()
    }
    
    func clearAllColections() {
        removeImageCollectorCache()
    }
}

fileprivate typealias ImageCollector_Private = ImageCollector
fileprivate extension ImageCollector_Private {

    func saveImage(_ image: UIImage) {
        let imagePosition = countImages
        let resizedImage = resizeImage(image, to: CGSize(width: 200, height: 200))!
        let imageData = UIImageJPEGRepresentation(resizedImage, 0)
        let imageURL = self.imageURL(position: imagePosition)
        
        try? FileManager.default.createDirectory(atPath: imageURL.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
        
        do {
            try imageData?.write(to: imageURL, options: .atomic)
        } catch {
            print(error)
        }   
    }

    func removeCachedImage(_ image: UIImage) {
        let imagePosition = countImages - 1
        let imageURL = self.imageURL(position: imagePosition)
        do {
            try FileManager.default.removeItem(at: imageURL)
        } catch {
            print(error)
        }   
    }
    
    func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: size.width, height: size.height)))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

fileprivate typealias ImageCollector_FileManager = ImageCollector
fileprivate extension ImageCollector_FileManager {
    
    var cacheURL: URL {
        return FileManager.default.urls(for: .cachesDirectory, in:.userDomainMask)[0].appendingPathComponent(ImageCollector.collectorCacheDirectory)
    }

    var imagesDirectoryURL: URL {
        let directoryURL = cacheURL.appendingPathComponent("\(collectionId)")
        return directoryURL
    }
    
    var countImages: Int {
        let count = imageURLs().filter {
            $0.pathExtension == "jpeg"
            }.count
        
        return count
    }
    
    func imageURL(position: Int) -> URL {
        let imageURL = cacheURL.appendingPathComponent("\(collectionId)/\(position).jpeg")
        return imageURL
    }
    
    func removeCollectionFolder() {
        try? FileManager.default.removeItem(at: imagesDirectoryURL)
    }
    
    func removeImageCollectorCache() {
        try? FileManager.default.removeItem(at: cacheURL)
    }
}
