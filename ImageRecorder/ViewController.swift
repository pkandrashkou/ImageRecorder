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

    let imageCollector = ImageCollector()
    let imageId = "adadawa2132"
    
    var imageCounter = 0
    @IBOutlet weak var labelCounter: UILabel!
    

    let settings = ImageAnimatorRenderSettings()
    
    var images: [UIImage] = []    
    let playerViewController = AVPlayerViewController()
    
    @IBAction func saveImage(_ sender: Any) {
        
        imageCounter %= 46
        imageCounter += 1
        labelCounter.text = "frames: \(imageCounter)"
        
        let image = UIImage(named: "Layer \(imageCounter)")!
        imageCollector.addImage(image, for: imageId)
        
    }
    
    @IBAction func processVideoPressed(_ sender: Any) {
        imageCollector.images(for: imageId) { [weak self] (images) in
            guard let `self` = self else {
                return
            }
            let imageAnimator = ImageAnimator(renderSettings: self.settings, images: images)
            imageAnimator.render() {
                
                let tempPlayer = AVPlayer(url: self.settings.outputURL) 
                tempPlayer.actionAtItemEnd = .none
                
                self.playerViewController.player = tempPlayer
                
                
                self.present(self.playerViewController, animated: true) {
                    self.playerViewController.player!.play()
                }
            }
        }
    }
    @IBAction func clearCachePressed(_ sender: Any) {
        imageCollector.clearCollection(for: imageId)
        imageCounter = 0
        labelCounter.text = "frames: \(imageCounter)"
        try? FileManager.default.removeItem(at: settings.outputURL)
    }
    @IBAction func createBigVideo(_ sender: Any) {
        
        var images = (1...46).map {
            UIImage(named: "Layer \($0)")!
        }
        
        images.append(contentsOf: images)
        
        for image in images {
            imageCollector.addImage(image, for: imageId)
        }
        
        
        
    }
}

