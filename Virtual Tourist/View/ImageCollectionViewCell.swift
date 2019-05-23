//
//  ImageCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Dzhavid Babakishiiev on 5/12/19.
//  Copyright © 2019 Dzhavid. All rights reserved.
//

import Foundation
import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            opacityView.isHidden = !isSelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        opacityView.isHidden = true
        startLoading()
    }
    
    func fill(with image: UIImage?) {
        imageView.image = image
        stopLoading()
    }
    
    func set(photo: Photo) {
        Client.downloadPhoto(url: Client.Endpoints.downloadPhoto(photo).url) { (image, error) in
            self.fill(with: image)
        }
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        startLoading()
        opacityView.isHidden = true
        imageView.image = nil
    }
}
