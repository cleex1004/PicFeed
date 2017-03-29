//
//  GalleryCell.swift
//  picfeed
//
//  Created by Christina Lee on 3/29/17.
//  Copyright © 2017 Christina Lee. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {
    
    @IBOutlet weak var ImageView: UIImageView!
    
    var post : Post! {
        didSet {
            self.ImageView.image = post.image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.ImageView.image = nil
    }
}
