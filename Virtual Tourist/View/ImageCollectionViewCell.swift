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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
        imageView.image = nil
    }
}
