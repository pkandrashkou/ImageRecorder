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

    let imageId = "0109b40e-db86-43a7-b544-ebfa9c8b8df5"
    
    var imageCounter = 0
    @IBOutlet weak var labelCounter: UILabel!
    
    let playerViewController = AVPlayerViewController()
    
    @IBAction func saveImage(_ sender: Any) {
    }
    
    lazy var imageRecorder: ImageRecorder? = {
        return try? ImageRecorder(collectionId: self.imageId) 
    }()
    
    @IBAction func processVideoPressed(_ sender: Any) {
        imageRecorder?.renderVideoSegment(completion: {
            print("finished rendering")
        })
    }
    
    @IBAction func mergeVideosPressed(_ sender: Any) {
        imageRecorder?.mergeVideo()
    }
    
    @IBAction func clearCachePressed(_ sender: Any) {
        imageRecorder?.clearVideoSegments()
        imageRecorder?.clearCachedImages()
        imageRecorder?.clearRenderedVideo()
    }
    
    @IBAction func createBigVideo(_ sender: Any) {
        
        for index in 1...157 {
            print("populating image at \(index)")
            let image = UIImage(named: "\(index)")!
            imageRecorder?.addImage(image)
        }   
    }
}
