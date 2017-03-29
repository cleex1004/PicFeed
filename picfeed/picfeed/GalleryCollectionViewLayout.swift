//
//  GalleryCollectionViewLayout.swift
//  picfeed
//
//  Created by Christina Lee on 3/29/17.
//  Copyright © 2017 Christina Lee. All rights reserved.
//

import UIKit

class GalleryCollectionViewLayout: UICollectionViewFlowLayout {
    var columns = 2
    let spacing : CGFloat = 1.0
    
    var screenWidth : CGFloat {
        return UIScreen.main.bounds.width //gives width of screen
    }
    
    var itemWidth : CGFloat {
        let availableScreen = screenWidth - (CGFloat(self.columns) * self.spacing)
        return availableScreen / CGFloat(self.columns)
    }
    
    init(columns : Int = 2) {
        self.columns = columns
        
        super.init()
        
        self.minimumLineSpacing = spacing
        self.minimumInteritemSpacing = spacing
        self.itemSize = CGSize(width: itemWidth, height: itemWidth)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
