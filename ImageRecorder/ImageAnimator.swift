//
//  ImageAnimator.swift
//  ImageRecorder
//
//  Created by Pavel Kondrashkov on 8/17/17.
//  Copyright © 2017 Pavel Kondrashkov. All rights reserved.
//

import UIKit
import Photos


class ImageAnimator {
    
    // Apple suggests a timescale of 600 because it's a multiple of standard video rates 24, 25, 30, 60 fps etc.
    static let kTimescale: Int32 = 600
    
    fileprivate let _settings: ImageAnimatorRenderSettings
    fileprivate let _imageVideoWriter: ImageVideoWriter
    fileprivate var _images: [UIImage] 
    
    var diskFetcher: (() -> [UIImage])?
    
    var frameCounter = 0
    
    static func saveToLibrary(videoURL: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            }) { success, error in
                if !success {
                    print("Could not save video to photo library:", error ?? "")
                }
            }
        }
    }
    
    static func removeFileAtURL(fileURL: URL) {
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
        } catch _ as NSError {
            // Assume file doesn't exist.
        }
    }
    
    init(renderSettings: ImageAnimatorRenderSettings, images: [UIImage]) {
        _settings = renderSettings
        _imageVideoWriter = ImageVideoWriter(renderSettings: _settings)
        _images = images
    }
    
    func render(completion: (() -> Void)?) {
        
        // The VideoWriter will fail if a file exists at the URL, so clear it out first.
        ImageAnimator.removeFileAtURL(fileURL: _settings.outputURL)
        
        _imageVideoWriter.start()
        _imageVideoWriter.render(appendPixelBuffers: appendPixelBuffers) {
            ImageAnimator.saveToLibrary(videoURL: self._settings.outputURL)
            completion?()
        }
        
    }
    
    // This is the callback function for ImageVideoWriter.render()
    func appendPixelBuffers(writer: ImageVideoWriter) -> Bool {
        
        let frameDuration = CMTimeMake(Int64(ImageAnimator.kTimescale / _settings.fps), ImageAnimator.kTimescale)
        
        while !_images.isEmpty {
            
            if !writer.isReadyForData {
                // Inform writer we have more buffers to write.
                return false
            }
            
            let image = _images.removeFirst()
            let presentationTime = CMTimeMultiply(frameDuration, Int32(frameCounter))
            let success = _imageVideoWriter.addImage(image: image, withPresentationTime: presentationTime)
            if !success {
                fatalError("addImage() failed")
            }
            
            frameCounter += 1
        }
        
        // Inform writer all buffers have been written.
        return true
    }
    
    func appendPixelBuffersFromDisk(writer: ImageVideoWriter) -> Bool {
        
        let frameDuration = CMTimeMake(Int64(ImageAnimator.kTimescale / _settings.fps), ImageAnimator.kTimescale)
        
        
        while true {
            
            // fetch additional images after images is empty in inner while loop
            _images = diskFetcher?() ?? []
            if _images.isEmpty {
                break
                
            }
            
            while !_images.isEmpty {
                
                if !writer.isReadyForData {
                    // Inform writer we have more buffers to write.
                    return false
                }
                
                let image = _images.removeFirst()
                let presentationTime = CMTimeMultiply(frameDuration, Int32(frameCounter))
                let success = _imageVideoWriter.addImage(image: image, withPresentationTime: presentationTime)
                if !success {
                    fatalError("addImage() failed")
                }
                
                frameCounter += 1
            }
            
        }
        // Inform writer all buffers have been written.
        return true
    }
    
}
