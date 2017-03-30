//
//  HomeViewController.swift
//  picfeed
//
//  Created by Christina Lee on 3/27/17.
//  Copyright © 2017 Christina Lee. All rights reserved.
//

import UIKit
import Social

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    let filterNames = [FilterName.blackAndWhite, FilterName.instant, FilterName.invert, FilterName.sepia, FilterName.vintage]

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var filterButtonTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var postButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Filters.originalImage = imageView.image
        self.collectionView.dataSource = self
        setupGalleryDelegate()
    }
    
    func setupGalleryDelegate() {
        if let tabBarController = self.tabBarController {
            guard let viewControllers = tabBarController.viewControllers else { return }
            guard let galleryController = viewControllers[1] as? GalleryViewController else { return }
            
            galleryController.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        filterButtonTopConstraint.constant = 8
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        postButtonBottomConstraint.constant = 8
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }

    }

    func presentImagePickerWith(sourceType: UIImagePickerControllerSourceType) {
        
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = sourceType
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = originalImage
            Filters.originalImage = originalImage
            self.collectionView.reloadData()
        }
        //print("Info:\(info)")
        self.dismiss(animated: true, completion: nil)
        //can call imagePickerControllerDidCancel
    }
    
    @IBAction func imageTapped(_ sender: Any) {
        print("User Tapped Image!")
        self.presentActionSheet()
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        if let image = self.imageView.image {
            let newPost = Post(image: image, date: nil)
            CloudKit.shared.save(post: newPost, completion: { (success) in
                if success {
                    print("Saved Post successfully to CloudKit!")
                } else {
                    print("Did NOT successfully save to CloudKit...")
                }
            })
        }
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        guard let image = self.imageView.image else { return }
        
        self.collectionViewHeightConstraint.constant = 150
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
//        let alertController = UIAlertController(title: "Filter", message: "Please select a filter", preferredStyle: .alert)
//        
//        let blackAndWhiteAction = UIAlertAction(title: "Black & White", style: .default) { (action) in
//            Filters.shared.filter(name: .blackAndWhite, image: image, completion: { (filteredImage) in
//                self.imageView.image = filteredImage
//            })
//        }
//        let vintageAction = UIAlertAction(title: "Vintage", style: .default) { (action) in
//            Filters.shared.filter(name: .vintage, image: image, completion: { (filteredImage) in
//                self.imageView.image = filteredImage
//            })
//        }
//        let invertAction = UIAlertAction(title: "Invert", style: .default) { (action) in
//            Filters.shared.filter(name: .invert, image: image, completion: { (filteredImage) in
//                self.imageView.image = filteredImage
//            })
//        }
//        let sepiaAction = UIAlertAction(title: "Sepia", style: .default) { (action) in
//            Filters.shared.filter(name: .sepia, image: image, completion: { (filteredImage) in
//                self.imageView.image = filteredImage
//            })
//        }
//        let instantAction = UIAlertAction(title: "Instant", style: .default) { (action) in
//            Filters.shared.filter(name: .instant, image: image, completion: { (filteredImage) in
//                self.imageView.image = filteredImage
//            })
//        }
//        let resetAction = UIAlertAction(title: "Reset Image", style: .destructive) { (action) in
//            self.imageView.image = Filters.originalImage
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        alertController.addAction(blackAndWhiteAction)
//        alertController.addAction(vintageAction)
//        alertController.addAction(invertAction)
//        alertController.addAction(sepiaAction)
//        alertController.addAction(instantAction)
//        alertController.addAction(resetAction)
//        alertController.addAction(cancelAction)
//        
//        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func userLongPressed(_ sender: UILongPressGestureRecognizer) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            guard let composeController = SLComposeViewController(forServiceType: SLServiceTypeTwitter) else { return }
            
            composeController.add(self.imageView.image)
            self.present(composeController, animated: true, completion: nil)
        }
    }
    
    func presentActionSheet() {
        let actionSheetController = UIAlertController(title: "Source", message: "Please Select Source Tyle", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.presentImagePickerWith(sourceType: .camera)
        }
        let photoAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.presentImagePickerWith(sourceType: .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            cameraAction.isEnabled = false
        }
        
        actionSheetController.addAction(cameraAction)
        actionSheetController.addAction(photoAction)
        actionSheetController.addAction(cancelAction)
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
}


//MARK: UICollectionView DataSource
extension HomeViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.identifier, for: indexPath) as! FilterCell
        
        guard let originalImage = Filters.originalImage else { return filterCell }
        guard let resizedImage = originalImage.resize(size: CGSize(width: 75, height: 75)) else { return filterCell }
        let filterName = self.filterNames[indexPath.row]
        
        Filters.shared.filter(name: filterName, image: resizedImage) { (filteredImage) in
            filterCell.imageView.image = filteredImage
        }
        
        return filterCell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }
}

//MARK: GalleryViewController Delegate
extension HomeViewController : GalleryViewControllerDelegate {
    func galleryController(didSelect image: UIImage) {
        self.imageView.image = image
        self.tabBarController?.selectedIndex = 0
    }
}





