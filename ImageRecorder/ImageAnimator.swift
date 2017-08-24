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
    
    private let settings: ImageAnimatorRenderSettings
    private let imageVideoWriter: ImageVideoWriter
    
    private var diskFetcher: ImageDiskFetcher
    
    private var frameCounter = 0
    
    //temporary function to check progress
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
        try? FileManager.default.removeItem(atPath: fileURL.path)
    }
    
    init(renderSettings: ImageAnimatorRenderSettings, diskFetcher: ImageDiskFetcher) {
        settings = renderSettings
        imageVideoWriter = ImageVideoWriter(renderSettings: settings)
        self.diskFetcher = diskFetcher
    }

    func render(completion: (() -> Void)?) {
        guard let segmentOutputURL = settings.segmentOutputURL else {
            return
        }
        // The VideoWriter will fail if a file exists at the URL, so clear it out first.
        ImageAnimator.removeFileAtURL(fileURL: segmentOutputURL)
        
        imageVideoWriter.start()
        imageVideoWriter.render(appendPixelBuffers: appendPixelBuffers) {
            ImageAnimator.saveToLibrary(videoURL: segmentOutputURL)
            completion?()
        }
    }
        
    func appendPixelBuffers(writer: ImageVideoWriter) -> Bool {
        let frameDuration = CMTimeMake(Int64(ImageAnimator.kTimescale / settings.fps), ImageAnimator.kTimescale)
        
        var images: [UIImage] = []
        while true {
            // fetch additional images after images is empty in inner while loop
            if images.isEmpty {
                images = diskFetcher.fetch()
                if images.isEmpty {
                    break   
                }    
            }
            while !images.isEmpty {
                
                if !writer.isReadyForData {
                    // Inform writer we have more buffers to write.
                    return false
                }
                
                let image = images.removeFirst()
                let presentationTime = CMTimeMultiply(frameDuration, Int32(frameCounter))
                let success = imageVideoWriter.addImage(image: image, withPresentationTime: presentationTime)
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
