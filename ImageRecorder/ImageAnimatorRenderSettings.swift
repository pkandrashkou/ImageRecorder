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
    
    var size: CGSize = CGSize(width: 400, height: 400)
    var fps: Int32 = 6
    var avCodecKey = AVVideoCodecH264
    var videoFilename = "render3"
    var videoFilenameExt = "mp4"
    
    
    var outputURL: URL {
        // Use the CachesDirectory so the rendered video file sticks around as long as we need it to.
        // Using the CachesDirectory ensures the file won't be included in a backup of the app.
        let fileManager = FileManager.default
        if let tmpDirURL = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            return tmpDirURL.appendingPathComponent(videoFilename).appendingPathExtension(videoFilenameExt)
        }
        fatalError("URLForDirectory() failed")
    }
}
