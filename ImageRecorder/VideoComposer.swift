//
//  VideoComposer.swift
//  ImageRecorder
//
//  Created by Pavel Kondrashkov on 8/23/17.
//  Copyright © 2017 Pavel Kondrashkov. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

class VideoComposer {
    
    private let videoURLs: [URL]
    private let outputURL: URL
    
    var totalTime : CMTime = CMTimeMake(0, 0)
    
    var atTimeM: CMTime = CMTimeMake(0, 0)
    //var lastAsset: AVAsset!
    var layerInstructionsArray = [AVVideoCompositionLayerInstruction]()
    var completeTrackDuration: CMTime = CMTimeMake(0, 1)
    
    
    var videos: [AVAsset] {
        return videoURLs.map {
            AVAsset(url: $0)
        }
    }
    
    init(videoURLs: [URL], outputURL: URL) {
        self.videoURLs = videoURLs
        self.outputURL = outputURL
    }
    
    func mergeVideos() {
        let composition = AVMutableComposition()
        let videoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        
        var insertTime = kCMTimeZero
        for video in videos {
            try? videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, video.duration), of: video.tracks(withMediaType: AVMediaTypeVideo)[0], at: insertTime)
            insertTime = insertTime + video.duration
        }
        
        
        try? FileManager.default.removeItem(at: outputURL)
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = outputURL
        exporter?.outputFileType = AVFileTypeMPEG4
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.exportAsynchronously {
            print("exported success")
        }
    }
//    
//    func mergeVideos() {
//        
//        let mixComposition = AVMutableComposition()
//        
//        let videoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
//        
//        for videoAsset in videos {
//            
//            do {
//                if videoAsset == videos.first {
//                    atTimeM = kCMTimeZero
//                } else{
//                    atTimeM = totalTime
//                }
//                try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: atTimeM)
//            } catch let error as NSError {
//                print("error: \(error)")
//            }
//            totalTime = totalTime + videoAsset.duration
//            completeTrackDuration = CMTimeAdd(completeTrackDuration, videoAsset.duration)
//            let videoInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
//            if videoAsset != videos.last {
//                videoInstruction.setOpacity(0.0, at: completeTrackDuration)
//            }
//            layerInstructionsArray.append(videoInstruction)
//      
//        }
//        
//        let mainInstruction = AVMutableVideoCompositionInstruction()
//        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, completeTrackDuration)
//        mainInstruction.layerInstructions = layerInstructionsArray        
//        
//        let mainComposition = AVMutableVideoComposition()
//        mainComposition.instructions = [mainInstruction]
//        mainComposition.frameDuration = CMTimeMake(1, 30)
//        mainComposition.renderSize = CGSize(width: settings.size.width, height: settings.size.height)
//        
//        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        dateFormatter.timeStyle = .short
//        let date = dateFormatter.string(from: NSDate() as Date)
//        let savePath = (documentDirectory as NSString).appendingPathComponent("mergeVideo-\(date).mov")
//        let url = NSURL(fileURLWithPath: savePath)
//        
//        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
//            return
//        }
//        exporter.outputURL = url as URL
//        exporter.outputFileType = AVFileTypeQuickTimeMovie
//        exporter.shouldOptimizeForNetworkUse = true
//        exporter.videoComposition = mainComposition
//        exporter.exportAsynchronously {            
//            PHPhotoLibrary.shared().performChanges({
//                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exporter.outputURL!)
//            }) { saved, error in
//                
//            }
//        }
//    }
    
    
}
