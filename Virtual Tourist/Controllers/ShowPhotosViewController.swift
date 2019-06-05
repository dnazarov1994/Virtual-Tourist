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
import CoreData

// Баги
// 1) Есть список фото, однако появляется надпись. Шаги для воспроизведения
// - Долистать до последней страницы с фотографиями

// 2) when the pin has only 1 page, "Remove Selected Pictures" button is desabled (must be Enabled)

class ShowPhotosViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var noImagesLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    var action: (() -> Void)?
    
    var passData: CLLocationCoordinate2D!
    
    let maxPhotoCount = 21
    
    var page:Int = 1
    
    
    var fetchedImages: [UIImage] = []
    var imagesInfo: [Photo] = []
    var usedPhotos: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        loadPhoto()
        action = loadNewCollection
        collectionView.dataSource = self
        noImagesLabel.isHidden = true
        collectionViewSetup()
    }
    
    func loadPhoto() {
        do {
            let data = try fetchData()
            fetchedImages = filter(imageObjects: data)
            actionButton.isEnabled = true
            if fetchedImages.isEmpty {
                getPhotos()
            }
        } catch {
            getPhotos()
        }
    }
    
    func filter(imageObjects: [NSManagedObject]) -> [UIImage] {
        
        var objects: [NSManagedObject] = []
        
        imageObjects.forEach { (object) in
            if let longitude = object.value(forKey: "longitude") as? Double,
                let latitude = object.value(forKey: "latitude") as? Double,
                longitude == passData.longitude && latitude == passData.latitude {
                objects.append(object)
            }
        }
        
        usedPhotos = objects

        var images: [UIImage] = []
        
        objects.forEach { object in
            if let data = object.value(forKey: "data") as? Data, let image = UIImage(data: data) {
                images.append(image)
            }
        }
        return images
    }
    
    func collectionViewSetup() {
        let layout = UICollectionViewFlowLayout()
        let space:CGFloat = 2.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        layout.itemSize = CGSize(width: dimension, height: dimension)
        collectionView.allowsMultipleSelection = true
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
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
    
    // MARK: actions for button
    func loadNewCollection() {
        page = page + 1
        getPhotos(at: page)
    }
    
    func fetchData() throws -> [NSManagedObject] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw SystemError.defaultError
        }
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "PhotoData")

        return try context.fetch(request)
    }
        
    
    func removePhotos() {
        guard let indexPaths = collectionView.indexPathsForSelectedItems else {
            return
        }
        
        if !fetchedImages.isEmpty {
            fetchedImages = fetchedImages
                .enumerated()
                .filter { (index, element) -> Bool in
                    return !indexPaths.contains { $0.row == index }
                }.map { $0.element }
        }
        
        imagesInfo = imagesInfo
            .enumerated()
            .filter { (index, element) -> Bool in
                return !indexPaths.contains { $0.row == index }
            }.map { $0.element }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        indexPaths.forEach { (indexPath) in
            context.delete(usedPhotos[indexPath.row])
        }
        
        collectionView.deleteItems(at: indexPaths)
        updateButtonState()
    }
    
    // MARK: map view
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
        action?()
    }
    
    func getPhotos(at page: Int = 1) {
        Client.taskForGetRequest(url: Client.Endpoints.getPhotos(passData, page).url, responseType: PhotoResponse.self) { (value, error) in
            if let error = error {
                print(error)
            } else if let value = value {
                self.actionButton.isEnabled = value.photos.page != value.photos.pages
                let info = value.photos.photo
                if info.count == 0 {
                   self.noImagesLabel.isHidden = false
                }
                self.imagesInfo = info
                if self.maxPhotoCount < info.count {
                    self.imagesInfo.replaceSubrange(self.maxPhotoCount..<info.count, with: [])
                }
                self.removeOldImages()
                
                self.collectionView.reloadData()
            }
        }
    }
    
    func removeOldImages() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        do {
            let data = try fetchData()
            data.forEach { (object) in
                if let longitude = object.value(forKey: "longitude") as? Double, let latitude = object.value(forKey: "latitude") as? Double,
                    longitude == passData.longitude, latitude  == passData.latitude
                    
                {
                    context.delete(object)
                }
            }
        } catch {
            show(error: error)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesInfo.isEmpty ? fetchedImages.count:imagesInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "id", for: indexPath) as! ImageCollectionViewCell
        if !imagesInfo.isEmpty {
            cell.set(photo: imagesInfo[indexPath.row], coordinates: passData)
        } else {
            cell.fill(with: fetchedImages[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateButtonState()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateButtonState()
    }
    
    func updateButtonState() {
        if let selectedItems = collectionView.indexPathsForSelectedItems, !selectedItems.isEmpty {
            actionButton.setTitle("Remove Selected Pictures", for: .normal)
            action = removePhotos
        } else {
            actionButton.setTitle("New Collection", for: .normal)
            action = loadNewCollection
        }
    }
    
}
