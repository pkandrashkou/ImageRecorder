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
    
    fileprivate let _workingQueue = OperationQueue()
    fileprivate var _imageCollection: [ImageCollectionId: [UIImage]] = [:]
    
    fileprivate var _imageCollectionInfo: [ImageCollectionId: Int] = [:]
    
    init() {
        _workingQueue.qualityOfService = .background
        _workingQueue.maxConcurrentOperationCount = 1
    }

    
    func addImage(_ image: UIImage, for id: ImageCollectionId) {
        let saveOpeation = BlockOperation { [weak self] in
            self?.saveImage(image, for: id)
        }
        _workingQueue.addOperation(saveOpeation)

    }
    
    func undoImage(_ image: UIImage, for id: ImageCollectionId) {
        let removeOperation = BlockOperation { [weak self] in
            self?.removeImage(image, for: id)
        }
        _workingQueue.addOperation(removeOperation)
    }
    
    func clearCollection(for id: ImageCollectionId) {
        removeCollectionFolder(id: id)
        _imageCollection[id] = nil
    }
    
    func clearAllColections() {
        removeImageCollectorCache()
        _imageCollection.removeAll()
    }
    
    func imageFetcher(for id: ImageCollectionId, fetchLimit: Int) -> (() -> [UIImage]) {
        var fetchCount = 0
        
        return { [weak self] in
            guard let strongSelf = self else { 
                return []
            }

            var images: [UIImage] = []
            
            for index in (fetchLimit * fetchCount)..<fetchLimit * (fetchCount + 1)  {
                let urls = strongSelf.imageURLs(collectionId: id)
                guard urls.indices.contains(index), let image = UIImage(contentsOfFile: urls[index].path) else {
                    print("does not exist index: \(index)")
                    continue
                }
                print("index: \(index)")
                images.append(image)
            }
            
            fetchCount += 1
            return images
        }
    }
}


fileprivate typealias ImageCollector_Private = ImageCollector
fileprivate extension ImageCollector_Private {
    
    func loadImages(for id: ImageCollectionId) -> [UIImage] {
        let urls = imageURLs(collectionId: id)
        var images: [UIImage] = []
        
        for url in urls {
            guard let image = UIImage(contentsOfFile: url.path) else {
                continue
            }
            images.append(image)
        }
        
        return images
    }

    func saveImage(_ image: UIImage, for id: ImageCollectionId) {
        let imagePosition = countImages(for: id)
        let imageData = UIImagePNGRepresentation(image)
        let imageURL = self.imageURL(collectionId: id, position: imagePosition)
        
        try? FileManager.default.createDirectory(atPath: imageURL.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
        
        do {
            try imageData?.write(to: imageURL, options: .atomic)
        } catch {
            print(error)
        }   
    }
    
    func removeImage(_ image: UIImage, for id: ImageCollectionId) {
        let imagePosition = countImages(for: id) - 1
        let imageURL = self.imageURL(collectionId: id, position: imagePosition)
        do {
            try FileManager.default.removeItem(at: imageURL)
        } catch {
            print(error)
        }   

    }
}

fileprivate typealias ImageCollector_FileManager = ImageCollector
fileprivate extension ImageCollector_FileManager {
    
    func cacheURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in:.userDomainMask)[0].appendingPathComponent(ImageCollector.collectorCacheDirectory)
    }
    
    func imageURL(collectionId: ImageCollectionId, position: Int) -> URL {
        let imageURL = cacheURL().appendingPathComponent("\(collectionId)/\(position).png")
        return imageURL
    }
    
    func imagesDirectoryURL(collectionId: ImageCollectionId) -> URL {
        let directoryURL = cacheURL().appendingPathComponent("\(collectionId)")
        return directoryURL
    }
    
    func imageURLs(collectionId: ImageCollectionId) -> [URL] {
        guard let urls = try? FileManager.default.contentsOfDirectory(at: imagesDirectoryURL(collectionId: collectionId), includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles) else {
            return []
        }
        return urls.sorted { (first, second) -> Bool in
            guard let firstInt = Int(first.deletingPathExtension().lastPathComponent), let secondInt = Int(second.deletingPathExtension().lastPathComponent) else {
                return false
            }
            return firstInt < secondInt 
        }
    }
    
    func countImages(for id: ImageCollectionId) -> Int {
        let urls = imageURLs(collectionId: id)
        let count = urls.filter {
            $0.pathExtension == "png"
            }.count
        
        return count
    }
    
    func removeCollectionFolder(id: ImageCollectionId) {
        try? FileManager.default.removeItem(at: imagesDirectoryURL(collectionId: id))
    }
    
    func removeImageCollectorCache() {
        try? FileManager.default.removeItem(at: cacheURL())
    }
}





