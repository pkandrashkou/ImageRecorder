//
//  ImageDiskFetcher.swift
//  ImageRecorder
//
//  Created by Pavel Kondrashkov on 8/24/17.
//  Copyright © 2017 Pavel Kondrashkov. All rights reserved.
//

import Foundation
import UIKit

class ImageDiskFetcher {
    
    private let imageURLs: [URL]
    private var fetchCounter = 0
    private let fetchLimit: Int
    
    init(imageURLs: [URL], fetchLimit: Int) {
        self.imageURLs = imageURLs
        self.fetchLimit = fetchLimit
    }
    
    func fetch() -> [UIImage] {
        var images: [UIImage] = []
        for index in (fetchLimit * fetchCounter)..<fetchLimit * (fetchCounter + 1)  {
            let urls = self.imageURLs
            guard urls.indices.contains(index), let image = UIImage(contentsOfFile: urls[index].path) else {
                print("does not exist index: \(index)")
                continue
            }
            print("index: \(index)")
            images.append(image)
        }
        
        fetchCounter += 1
        return images
    }
}
