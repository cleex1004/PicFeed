//
//  HomeViewController.swift
//  picfeed
//
//  Created by Christina Lee on 3/27/17.
//  Copyright © 2017 Christina Lee. All rights reserved.
//

import UIKit
import Social

class HomeViewController: UIViewController, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    let filterNames = [FilterName.BlackAndWhite, FilterName.Instant, FilterName.Inverted, FilterName.Sepia, FilterName.Vintage]

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var filterButtonTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var postButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        setupPublicDelegate()
        setupPrivateDelegate()
        Filters.originalImage = imageView.image
    }
    
    func setupPrivateDelegate() {
        if let tabBarController = self.tabBarController {
            guard let viewControllers = tabBarController.viewControllers else { return }
            guard let privateController = viewControllers[1] as? GalleryViewController else { return }
            
            privateController.delegate = self
        }
    }
    
    func setupPublicDelegate() {
        if let tabBarController = self.tabBarController {
            guard let viewControllers = tabBarController.viewControllers else { return }
            guard let publicController = viewControllers[2] as? PublicViewController else { return }
            
            publicController.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        filterButtonTopConstraint.constant = 5
        UIView.animate(withDuration: 0.6) {
            self.view.layoutIfNeeded()
        }
        postButtonBottomConstraint.constant = 5
        UIView.animate(withDuration: 0.6) {
            self.view.layoutIfNeeded()
        }

    }
    
//MARK: Actions
    @IBAction func imageTapped(_ sender: Any) {
        print("User Tapped Image!")
        self.presentActionSheet()
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Private or Public", message: "Where would you liked to post this?", preferredStyle: .actionSheet)
        let privateAction = UIAlertAction(title: "Private Post", style: .default) { (action) in
            if let image = self.imageView.image {
                let newPost = Post(image: image, date: nil)
                CloudKit.shared.savePrivate(post: newPost, completion: { (success) in
                    if success {
                        print("Saved Post successfully to CloudKit!")
                    } else {
                        print("Did NOT successfully save to CloudKit...")
                    }
                })
            }
        }
        
        let publicAction = UIAlertAction(title: "Public Post", style: .default) { (action) in
            if let image = self.imageView.image {
                let newPost = Post(image: image, date: nil)
                CloudKit.shared.savePublic(post: newPost, completion: { (success) in
                    if success {
                        print("Saved Post successfully to CloudKit!")
                    } else {
                        print("Did NOT successfully save to CloudKit...")
                    }
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(privateAction)
        alertController.addAction(publicAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        //guard let image = self.imageView.image else { return }
        
        if self.collectionViewHeightConstraint.constant == 0 {
            self.collectionViewHeightConstraint.constant = 130
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.collectionViewHeightConstraint.constant = 0
            UIView.animate(withDuration: 0.5, animations: { 
                self.view.layoutIfNeeded()
            })
        }
        
        
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

//MARK: UIImagePickerController Delegate
extension HomeViewController : UIImagePickerControllerDelegate {
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
}

//MARK: UICollectionView DataSource
extension HomeViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.identifier, for: indexPath) as! FilterCell
        
        guard let originalImage = Filters.originalImage else { return filterCell }
        guard let resizedImage = originalImage.resize(size: CGSize(width: 75, height: 75)) else { return filterCell }
        let filterName = self.filterNames[indexPath.row]
        
        Filters.shared.filter(name: filterName, image: resizedImage) { (filteredImage) in
            filterCell.imageView.image = filteredImage
            filterCell.filterDescriptionLabel.text = String(describing: filterName)
        }
        
        return filterCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        guard let image = Filters.originalImage else { return }
        let filter = self.filterNames[indexPath.row]
        Filters.shared.filter(name: filter, image: image) { (filteredImage) in
            self.imageView.image = filteredImage
        }
    }
}

//MARK: GalleryViewController PublicViewController Delegate
extension HomeViewController : PublicViewControllerDelegate, GalleryViewControllerDelegate {
    func galleryController(didSelect image: UIImage) {
        self.imageView.image = image
        Filters.originalImage = image
        self.collectionViewHeightConstraint.constant = 0
        self.tabBarController?.selectedIndex = 0
    }
    func publicController(didSelect image: UIImage) {
        self.imageView.image = image
        Filters.originalImage = image
        self.collectionViewHeightConstraint.constant = 0
        self.tabBarController?.selectedIndex = 0
    }
}



//old action sheet
//        @IBAction func filterButtonPressed(_ sender: Any) {
//            guard let image = self.imageView.image else { return }
//    
//            let alertController = UIAlertController(title: "Filter", message: "Please select a filter", preferredStyle: .alert)
//    
//            let blackAndWhiteAction = UIAlertAction(title: "Black & White", style: .default) { (action) in
//                Filters.shared.filter(name: .blackAndWhite, image: image, completion: { (filteredImage) in
//                    self.imageView.image = filteredImage
//                })
//            }
//            let vintageAction = UIAlertAction(title: "Vintage", style: .default) { (action) in
//                Filters.shared.filter(name: .vintage, image: image, completion: { (filteredImage) in
//                    self.imageView.image = filteredImage
//                })
//            }
//            let invertAction = UIAlertAction(title: "Invert", style: .default) { (action) in
//                Filters.shared.filter(name: .invert, image: image, completion: { (filteredImage) in
//                    self.imageView.image = filteredImage
//                })
//            }
//            let sepiaAction = UIAlertAction(title: "Sepia", style: .default) { (action) in
//                Filters.shared.filter(name: .sepia, image: image, completion: { (filteredImage) in
//                    self.imageView.image = filteredImage
//                })
//            }
//            let instantAction = UIAlertAction(title: "Instant", style: .default) { (action) in
//                Filters.shared.filter(name: .instant, image: image, completion: { (filteredImage) in
//                    self.imageView.image = filteredImage
//                })
//            }
//            let resetAction = UIAlertAction(title: "Reset Image", style: .destructive) { (action) in
//                self.imageView.image = Filters.originalImage
//            }
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//    
//            alertController.addAction(blackAndWhiteAction)
//            alertController.addAction(vintageAction)
//            alertController.addAction(invertAction)
//            alertController.addAction(sepiaAction)
//            alertController.addAction(instantAction)
//            alertController.addAction(resetAction)
//            alertController.addAction(cancelAction)
//            
//            self.present(alertController, animated: true, completion: nil)
//         }




