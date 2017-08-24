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
    
    private let videoURLs: () -> [URL]
    private let outputURL: URL
    
    var videos: [AVAsset] {
        return videoURLs().map {
            AVAsset(url: $0)
        }
    }
    
    init(videoURLs: @escaping () -> [URL], outputURL: URL) {
        self.videoURLs = videoURLs
        self.outputURL = outputURL
    }
    
    func mergeVideos() {
        let composition = AVMutableComposition()
        let videoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        
        var insertTime = kCMTimeZero
        for video in videos {
            guard let assetTrack = video.tracks(withMediaType: AVMediaTypeVideo).first else {
                continue
            }
            try? videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, video.duration), of: assetTrack, at: insertTime)
            insertTime = insertTime + video.duration
        }
        
        removeMergedVideo()
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = outputURL
        exporter?.outputFileType = AVFileTypeMPEG4
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.exportAsynchronously {
            print("exported success")
        }
    }
    
    func removeMergedVideo() {
        try? FileManager.default.removeItem(at: outputURL)
    }
    
    func removeVideoSegmengs() {
        for url in videoURLs() {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
