//
//  Filters.swift
//  picfeed
//
//  Created by Christina Lee on 3/28/17.
//  Copyright © 2017 Christina Lee. All rights reserved.
//

import UIKit

enum FilterName : String {
    case vintage = "CIPhotoEffectTransfer"
    case blackAndWhite = "CIPhotoEffectMono"
    case invert = "CIColorInvert"
    case sepia = "CISepiaTone"
    case instant = "CIPhotoEffectInstant"
}

typealias FilterCompletion = (UIImage?) -> ()

class Filters {
    static let shared = Filters()
    
    var context : CIContext
    
    private init() {
        let options = [kCIContextWorkingColorSpace: NSNull()] //NSNull object that represents nil
        guard let eaglContext = EAGLContext(api: .openGLES2) else { fatalError("Failed to creat EAGLContext.") }
        self.context = CIContext(eaglContext: eaglContext, options: options)
    }
    
    static var originalImage : UIImage?
    
    func filter(name: FilterName, image: UIImage, completion: @escaping FilterCompletion){
        OperationQueue().addOperation {
            guard let filter = CIFilter(name: name.rawValue) else { fatalError("Failed to create CIFilter") }
            
            let coreImage = CIImage(image: image)
            filter.setValue(coreImage, forKey: kCIInputImageKey)
            
//            //GPU context
//            let options = [kCIContextWorkingColorSpace: NSNull()] //NSNull object that represents nil
//            guard let eaglContext = EAGLContext(api: .openGLES2) else { fatalError("Failed to creat EAGLContext.") }
//            let ciContext = CIContext(eaglContext: eaglContext, options: options)
//            
            //Get final image using GPU
            guard let outputImage = filter.outputImage else { fatalError("Failed to get output image from Filter.") }
            
//            guard let cgImage = self.context.createCGImage(outputImage, from: outputImage.extent) else { fatalError("Failed to get image from context") }
//            
//            guard let finalImage = UIImage(cgImage: cgImage) else { fatalError("Failed to convert CI image to UI image") }
//            
//            OperationQueue.main.addOperation {
//                completion(finalImage)
//            }
            
            if let cgImage = self.context.createCGImage(outputImage, from: outputImage.extent) {
                let finalImage = UIImage(cgImage: cgImage)
                OperationQueue.main.addOperation {
                    completion(finalImage)
                }
            } else {
                OperationQueue.main.addOperation {
                    completion(nil)
                }
            }
        }
    }
    
}

