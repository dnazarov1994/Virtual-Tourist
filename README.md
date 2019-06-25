# Virtual Tourist
This app allows users to drop pins on a map, as if they were stops on a tour. Users are able to download pictures for the location and persist both the pictures, and the association of the pictures with the pin.

### Architecture 
- Travel Locations Map View: Allows the user to drop pins around the world
- Photo Album View: Allows the users to download and edit an album for a location

### Functionality
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
If the user selects a pin that already has a photo album then the Photo Album view displays the album and the New Collection button is enabled

### Data from network resources
The app using data from the Flickr API

### Error handling
