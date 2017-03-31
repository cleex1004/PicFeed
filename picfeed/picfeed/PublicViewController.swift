//
//  PublicViewController.swift
//  picfeed
//
//  Created by Christina Lee on 3/30/17.
//  Copyright © 2017 Christina Lee. All rights reserved.
//

import UIKit

protocol PublicViewControllerDelegate : class {
    func publicController(didSelect image: UIImage)
}

class PublicViewController: UIViewController {

    weak var delegate : PublicViewControllerDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var allPosts = [Post]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.collectionViewLayout = GalleryCollectionViewLayout(columns: 2)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updatePublic()
    }
    
    func updatePublic() {
        CloudKit.shared.getPostsPublic { (posts) in
            if let posts = posts {
                self.allPosts = posts
            }
        }
    }
    @IBAction func userPinched(_ sender: UIPinchGestureRecognizer) {
        guard let layout = collectionView.collectionViewLayout as? GalleryCollectionViewLayout else { return }
        
        switch sender.state {
        case .began:
            print("User Pinched!")
        case .changed:
            print("<-------------- User pinch changed -------------->")
        case .ended:
            print("Pinch ended.")
            
            let columns = sender.velocity > 0 ? layout.columns - 1 : layout.columns + 1 //ternary operator
            if columns < 1 || columns > 10 { return }
            
            collectionView.setCollectionViewLayout(GalleryCollectionViewLayout(columns: columns), animated: true)
        default:
            print("Unknown sender state.")
        }
    }
}

//MARK: UICollectionView DataSource Delegate Extension
extension PublicViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCell.identifier, for: indexPath) as! GalleryCell
        
        cell.post = self.allPosts[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let delegate = self.delegate else { return }
        
        let selectedPost = self.allPosts[indexPath.row]
        
        delegate.publicController(didSelect: selectedPost.image)
    }
}


