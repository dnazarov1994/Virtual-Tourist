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

class ShowPhotosViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var passData: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        getPhotos()
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
    }
    
    func getPhotos() {
        Client.taskForGetRequest(url: Client.Endpoints.getPhotos(passData).url, responseType: PhotoResponse.self) { (value, error) in
            if let error = error {
                print(error)
            } else if let value = value {
                print(value)
            }
        }
    }
    
}
