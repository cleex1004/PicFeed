//
//  FilterCell.swift
//  picfeed
//
//  Created by Christina Lee on 3/30/17.
//  Copyright © 2017 Christina Lee. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
}
