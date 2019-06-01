//
//  ImageCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Dzhavid Babakishiiev on 5/12/19.
//  Copyright © 2019 Dzhavid. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData


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
    
    func set(photo: Photo, coordinates: CLLocationCoordinate2D) {
        Client.downloadPhoto(url: Client.Endpoints.downloadPhoto(photo).url) { (image, error) in
            self.fill(with: image)
            guard let delegate = UIApplication.shared.delegate as? AppDelegate, let image = image else {
                return
            }
            let context = delegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "PhotoData", in: context)!
            let photoData = NSManagedObject(entity: entity, insertInto: context)
            
            photoData.setValue(coordinates.latitude, forKey: "latitude")
            photoData.setValue(coordinates.longitude, forKey: "longitude")
            let data = image.jpegData(compressionQuality: 1)
            photoData.setValue(data, forKey: "data")
            
            do {
                try context.save()
            } catch {
                print(error)
            }
            
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
