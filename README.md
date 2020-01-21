# Virtual Touristh
This app allows users to drop pins on a map as if they were stops on a tour. Users are able to download pictures for the location and persist both the pictures and the association of the pictures with the pin.

<img width="540" alt="Screen Shot 2019-08-18 at 9 16 34 PM" src="https://user-images.githubusercontent.com/46335329/63233373-d1aa5b00-c1fd-11e9-85c1-5dd76a928468.png">

<img width="540" alt="Screen Shot 2019-08-18 at 9 17 42 PM" src="https://user-images.githubusercontent.com/46335329/63233414-09b19e00-c1fe-11e9-9986-f76fde1af093.png">

## Functionality
When the user opens the app for the first time, the Map View appears. The user is able to zoom and scroll around the map using standard pinch and drag gestures.
Tapping and holding the map drops a new pin. Users can place any number of pins on the map.
When a pin is tapped, the app navigates to the Photo Album view associated with the pin.
If the user taps a pin that does not yet have a photo album, the app download Flickr images associated with the latitude and longitude of the pin.
If no images are found a “No Images” label displayed.
If there are images, then they displayed in a collection view.
While the images are downloading, the photo album is in a temporary “downloading” state in which the New Collection button is disabled. 
Once the images have all been downloaded, the app enables the New Collection button at the bottom of the page. Tapping this button app fetches a new set of images.
Users are able to remove photos from an album by tapping them. Pictures are flowed up to fill the space vacated by the removed photo.
All changes to the photo album are automatically made persistent.
Tapping the back button returns the user to the Map view.
If the user selects a pin that already has a photo album then the Photo Album view displays the album and the New Collection button is enabled.

## App Implementation 
The app has two view controller scenes:
- Travel Locations Map View: Allows the user to drop pins around the world
```
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
            show(error: error)
        }
        
        pins.forEach { (object) in
            if let longitude = object.value(forKey: "longitude") as? Double,
                let latitude = object.value(forKey: "latitude") as? Double {
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                addAnnotation(to: coordinate)
            }
        }
        
    }
```
- Photo Album View: Allows the users to download and edit an album for a location
```
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
```


## API
The app using data from the Flickr API: "https://api.flickr.com/services/rest"

## Error handling
If the submission fails to post the data to the server, then the user sees an alert with an error message describing the failure.
```
 func show(error:Error) {
        let alert = UIAlertController(title: "ERROR", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
 }
```

## Requirements

- Xcode 9.2
- Swift 4.2
