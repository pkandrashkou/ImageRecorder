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
        let loadingOperation = BlockOperation { [weak self] in
            if self?._imageCollection[id] == nil {
                self?._imageCollection[id] = self?.loadImages(for: id)
            }
        }
        
        let appendOperation = BlockOperation { [weak self] in 
            self?._imageCollection[id]?.append(image)
        }
        
        let saveOpeation = BlockOperation { [weak self] in
            self?.saveImage(for: id)
        }
        
        appendOperation.addDependency(loadingOperation)
        saveOpeation.addDependency(appendOperation)
        _workingQueue.addOperation(saveOpeation)
        _workingQueue.addOperation(appendOperation)
        _workingQueue.addOperation(loadingOperation)
    }
    
    func images(for id: ImageCollectionId, completion: @escaping ([UIImage]) -> Void) {        
        let loadingOperation = BlockOperation { [weak self] in
            if self?._imageCollection[id] == nil {
                self?._imageCollection[id] = self?.loadImages(for: id)
                self?._imageCollectionInfo[id] = self?.countImages(for: id)
                
            }
        }
        loadingOperation.completionBlock = { [weak self] in
            completion(self?._imageCollection[id] ?? [])
        }
        _workingQueue.addOperation(loadingOperation)
    }
    
    func clearCollection(for id: ImageCollectionId) {
        removeCollectionFolder(id: id)
        _imageCollection[id] = nil
    }
    
    func clearAllColections() {
        removeImageCollectorCache()
        _imageCollection.removeAll()
    }
    
    func imageFetcher(for id: ImageCollectionId) -> (() -> [UIImage]) {
        var offset = 1;
        
        return { [weak self] in
            guard let strongSelf = self else { return [] }
            
            let imagesCount = strongSelf.imagesURL(directoryURL: strongSelf.imagesDirectoryURL(collectionId: id)).count
            var images: [UIImage] = []
            
            guard offset <= imagesCount else { return [] }
            
            for imagePosition in offset...imagesCount {
                let url = strongSelf.imageURL(collectionId: id, position: imagePosition)
                guard let image = UIImage(contentsOfFile: url.path) else {
                    continue
                }
                images.append(image)
            }
            offset += 20
            return images
        }
    }
    
}


fileprivate typealias ImageCollector_Private = ImageCollector
fileprivate extension ImageCollector_Private {
    
    func loadImages(for id: ImageCollectionId) -> [UIImage] {
        let urls = imagesURL(directoryURL: imagesDirectoryURL(collectionId: id))
        var images: [UIImage] = []
        
        for url in urls {
            guard let image = UIImage(contentsOfFile: url.path) else {
                continue
            }
            images.append(image)
        }
        
        return images
    }
    
    func countImages(for id: ImageCollectionId) -> Int {
        let urls = imagesURL(directoryURL: imagesDirectoryURL(collectionId: id))
        let count = urls.filter {
            $0.pathExtension == "png"
        }.count
        
        return count
    }
    
    func saveImage(for id: ImageCollectionId) {
        guard let selectedImage = _imageCollection[id]?.last, let imagePosition = _imageCollection[id]?.count else {
            return
        }
        let imageData = UIImagePNGRepresentation(selectedImage)
        let imageURL = self.imageURL(collectionId: id, position: imagePosition)
        
        try? FileManager.default.createDirectory(atPath: imageURL.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
        
        do {
            try imageData?.write(to: imageURL, options: .atomic)
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
    
    func imagesURL(directoryURL: URL) -> [URL] {
        guard let urls = try? FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles) else {
            return []
        }
        return urls
    }
    
    func removeCollectionFolder(id: ImageCollectionId) {
        try? FileManager.default.removeItem(at: imagesDirectoryURL(collectionId: id))
    }
    
    func removeImageCollectorCache() {
        try? FileManager.default.removeItem(at: cacheURL())
    }
}





