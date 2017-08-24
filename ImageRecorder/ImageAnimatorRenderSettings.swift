//
//  ImageAnimatorRenderSettings.swift
//  ImageRecorder
//
//  Created by Pavel Kondrashkov on 8/17/17.
//  Copyright © 2017 Pavel Kondrashkov. All rights reserved.
//

import UIKit
import AVFoundation


struct ImageAnimatorRenderSettings {
    
    typealias RenderId = String
    static let animatorCacheDirectory = "ImageAnimator"

    
    var size: CGSize = CGSize(width: 400, height: 400)
    var fps: Int32 = 6
    var avCodecKey = AVVideoCodecH264
    var videoDirectory = "ImageAnimator"
    var videoExtension = "mp4"
    let renderId: RenderId
    
    init(renderId: RenderId) {
        self.renderId = renderId
    }
    
    var outputDirectoryURL: URL? {
        // Use the CachesDirectory so the rendered video file sticks around as long as we need it to.
        // Using the CachesDirectory ensures the file won't be included in a backup of the app.
        let fileManager = FileManager.default
        guard let cacheDirectory = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else  {
            return nil
        }
        let videoDirectoryURL = cacheDirectory.appendingPathComponent(ImageAnimatorRenderSettings.animatorCacheDirectory).appendingPathComponent(renderId)
        try? FileManager.default.createDirectory(at: videoDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        
        return videoDirectoryURL
    }
    
    var segmentOutputURL: URL? {
        guard let outputURL = outputDirectoryURL else {
            return nil
        }
        guard let lastURL = segmentURLs().last else {
            return outputURL.appendingPathComponent("/\(0).\(videoExtension)")
        }
        guard let lastVideoIndex = Int(lastURL.deletingPathExtension().lastPathComponent) else {
            return nil
        }
        
        return outputURL.appendingPathComponent("/\(lastVideoIndex + 1).\(videoExtension)")
    }
    
    var renderOutputURL: URL? {
        guard let outputURL = outputDirectoryURL else {
            return nil
        }
        let segmentURL = outputURL.appendingPathComponent("/\(renderId).\(videoExtension)")
        return segmentURL
    }
    
    var countSegments: Int {
        let urls = segmentURLs()
        let count = urls.filter {
            $0.pathExtension == videoExtension
            }.count
        
        return count
    }
    
    func segmentURLs() -> [URL] {
        guard let outputDirectoryURL = outputDirectoryURL, let urls = try? FileManager.default.contentsOfDirectory(at: outputDirectoryURL, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles) else {
            return []
        }
        let numberURLs = urls.filter { (url) -> Bool in
            let numberNameRepresentation = Int(url.deletingPathExtension().lastPathComponent)
            return numberNameRepresentation != nil 
        }
        
        return numberURLs.sorted { (first, second) -> Bool in
            guard let firstInt = Int(first.deletingPathExtension().lastPathComponent),
                let secondInt = Int(second.deletingPathExtension().lastPathComponent) else {
                    return false
            }
            return firstInt < secondInt 
        }
    }
}
