//
//  ImageRecorder.swift
//  ImageRecorder
//
//  Created by Pavel Kondrashkov on 8/24/17.
//  Copyright © 2017 Pavel Kondrashkov. All rights reserved.
//

import Foundation
import UIKit

class ImageRecorder {
    
    enum ImageRecorderError: Error {
        case invalidVideoComposerOutputDirectory
    }
    
//    private static let workingQueue = DispatchQueue(label: "com.imagerecorder.queue", qos: .background)
    private static var workingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    
    private let imageCollector: ImageCollector
    private let imageAnimator: ImageAnimator
    private let videoComposer: VideoComposer
    
    init(collectionId: ImageCollector.ImageCollectionId) throws {
        let imageRenderSettings = ImageAnimatorRenderSettings(renderId: collectionId)
        guard let renderOutputURL = imageRenderSettings.renderOutputURL else {
            throw ImageRecorderError.invalidVideoComposerOutputDirectory
        }
        videoComposer = VideoComposer(videoURLs: imageRenderSettings.segmentURLs, outputURL: renderOutputURL)
        imageCollector = ImageCollector(collectionId: collectionId)
        let imageDiskFetcher = ImageDiskFetcher(imageURLs: imageCollector.imageURLs , fetchLimit: 5)
        imageAnimator = ImageAnimator(renderSettings: imageRenderSettings, diskFetcher: imageDiskFetcher)
    }
    
    func addImage(_ image: UIImage) {
        ImageRecorder.workingQueue.addOperation({ [weak self] in
            self?.imageCollector.addImage(image)
        })
    }
    
    func removeImage(_ image: UIImage) {
        ImageRecorder.workingQueue.addOperation({ [weak self] in
            self?.imageCollector.removeImage(image)
        })
    }
    
    func renderVideoSegment(completion: (() -> Void)?) {
        ImageRecorder.workingQueue.addOperation({ [weak self] in
            self?.imageAnimator.render(completion: {
                self?.imageCollector.clearCollection()
                completion?()
            })    
        })
    }
    
    func mergeVideo() {
        ImageRecorder.workingQueue.addOperation({ [weak self] in
            self?.videoComposer.mergeVideos()
            self?.videoComposer.removeVideoSegmengs()
        })
    }
    
    func clearVideoSegments() {
        ImageRecorder.workingQueue.addOperation({ [weak self] in
            self?.videoComposer.removeVideoSegmengs()    
        })
    }
    
    func clearRenderedVideo() {
        ImageRecorder.workingQueue.addOperation({ [weak self] in
            self?.videoComposer.removeMergedVideo()
        })
    }
    
    func clearCachedImages() {
        ImageRecorder.workingQueue.addOperation({ [weak self] in
            self?.imageCollector.clearCollection()
        })
    }
}
