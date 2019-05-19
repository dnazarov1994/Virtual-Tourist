//
//  ShowPhotosCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Dzhavid Babakishiiev on 5/5/19.
//  Copyright © 2019 Dzhavid. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ShowPhotosViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var noImagesLabel: UILabel!
    
    @IBOutlet weak var newCollectionButton: UIButton!
    
    var passData: CLLocationCoordinate2D!
    
    var page:Int = 1
    
    var imagesInfo: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        getPhotos()
        collectionView.dataSource = self
        noImagesLabel.isHidden = true
        newCollectionButton.isEnabled = false
        collectionViewSetup()
    }
    
    
    func collectionViewSetup() {
        let layout = UICollectionViewFlowLayout()
        let space:CGFloat = 2.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        layout.itemSize = CGSize(width: dimension, height: dimension)
            
        collectionView.collectionViewLayout = layout
    }
    
    func setupMap() {
        mapView.delegate = self
        let annotation = MKPointAnnotation()
        annotation.coordinate = passData
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: passData, span: span)
        mapView.setRegion(region, animated: false)
        
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = "newpin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pin) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pin)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
        
    }
    
    @IBAction func newCollectionButton(_ sender: Any) {
        page = page + 1
        getPhotos(at: page)
    }
    
    func getPhotos(at page: Int = 1) {
        Client.taskForGetRequest(url: Client.Endpoints.getPhotos(passData, page).url, responseType: PhotoResponse.self) { (value, error) in
            if let error = error {
                print(error)
            } else if let value = value {
                self.newCollectionButton.isEnabled = value.photos.page != value.photos.pages
                let info = value.photos.photo
                if info.count == 0 {
                   self.noImagesLabel.isHidden = false
                }
                self.imagesInfo = info
                self.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesInfo.count > 21 ? 21:imagesInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "id", for: indexPath) as! ImageCollectionViewCell
        cell.set(photo: imagesInfo[indexPath.row])
        return cell
    }
    
}
