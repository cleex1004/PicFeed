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
}

typealias FilterCompletion = (UIImage?) -> ()

class Filters {
    static var originalImage = UIImage()
    
}
