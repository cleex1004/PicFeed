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
    
    @IBOutlet weak var DateLabel: UILabel!
    
    var post : Post! {
        didSet {
            self.ImageView.image = post.image
            self.DateLabel.text = String(describing: post.date!)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.ImageView.image = nil
        self.DateLabel.text = nil
    }
}
