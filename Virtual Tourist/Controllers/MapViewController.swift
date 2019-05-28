//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Dzhavid Babakishiiev on 5/4/19.
//  Copyright © 2019 Dzhavid. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    var viewSelected: MKAnnotationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPins()
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didPress))
        map.addGestureRecognizer(gestureRecognizer)
        map.delegate = self
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "OK", style: .plain, target: nil, action: nil)
    }
    
    func loadPins() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "Pins")
        var pins: [NSManagedObject] = []
        do {
            pins = try managedContext.fetch(request)
        } catch {
            print(error)
        }
        
        pins.forEach { (object) in
            if let longitude = object.value(forKey: "longitude") as? Double,
                let latitude = object.value(forKey: "latitude") as? Double {
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                addAnnotation(to: coordinate)
            }
        }
        
    }
    
    func savePin(coordinate: CLLocationCoordinate2D) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Pins", in: managedContext)! // unwrapping
        let pin = NSManagedObject(entity: entity, insertInto: managedContext)
        
        pin.setValue(coordinate.latitude, forKey: "latitude")
        pin.setValue(coordinate.longitude, forKey: "longitude")
        
        do {
            try managedContext.save()
        } catch {
            print(error)
        }
    }

    @objc func didPress(gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        let touchPoint = gestureRecognizer.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        savePin(coordinate: coordinate)
        addAnnotation(to: coordinate)
    }
    
    func addAnnotation(to coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        viewSelected = view
        performSegue(withIdentifier: "next", sender: nil)
        mapView.deselectAnnotation(view.annotation, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ShowPhotosViewController
        vc.passData = viewSelected?.annotation?.coordinate
    }
}
