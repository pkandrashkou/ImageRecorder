//
//  ViewController.swift
//  ImageRecorder
//
//  Created by Pavel Kondrashkov on 8/17/17.
//  Copyright © 2017 Pavel Kondrashkov. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SnapKit

class ViewController: UIViewController {

//    let imageCollector = ImageCollector()
    let imageId = "ImageCollection"
    
    var imageCounter = 0
    @IBOutlet weak var labelCounter: UILabel!
    

    let settings = ImageAnimatorRenderSettings(renderId: "RenderGUID")    
    
    let playerViewController = AVPlayerViewController()
    
    @IBAction func saveImage(_ sender: Any) {
    }
    
    lazy var imageCollector: ImageCollector = {
        return ImageCollector(collectionId: self.imageId) 
    }()
    
    @IBAction func processVideoPressed(_ sender: Any) {
        
        let diskFetcher = ImageDiskFetcher(imageURLs: imageCollector.imageURLs, fetchLimit: 5)
        let imageAnimator = ImageAnimator(renderSettings: self.settings, diskFetcher: diskFetcher)
        imageAnimator.render(completion: { 

            
//            let tempPlayer = AVPlayer(url: self.settings.outputURL!) 
//            tempPlayer.actionAtItemEnd = .none
//            
//            self.playerViewController.player = tempPlayer
//            
//            self.present(self.playerViewController, animated: true) {
//                self.playerViewController.player!.play()
//            }
        })        
    }
    
    @IBAction func mergeVideosPressed(_ sender: Any) {
        guard let renderOutputURL = settings.renderOutputURL else {
            return
        }
        let videoComposer = VideoComposer(videoURLs: settings.segmentURLs, outputURL: renderOutputURL)
        videoComposer.mergeVideos()
    }
    
    @IBAction func clearCachePressed(_ sender: Any) {
        ImageCollector(collectionId: imageId).clearCollection()
        imageCounter = 0
        labelCounter.text = "frames: \(imageCounter)"
        try? FileManager.default.removeItem(at: settings.outputDirectoryURL!)
    }
    

    lazy var localImageCollector: ImageCollector = {
        return ImageCollector(collectionId: self.imageId) 
    }()
    
    @IBAction func createBigVideo(_ sender: Any) {
        
        for index in 1...157 {
            print("populating image at \(index)")
            let image = UIImage(named: "\(index)")!
            localImageCollector.addImage(image)
        }   
    }
}
