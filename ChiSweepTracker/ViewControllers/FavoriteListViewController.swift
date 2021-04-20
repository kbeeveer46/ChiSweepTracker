import UIKit
import MapKit

class FavoriteListViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var favoriteListMapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fill in notification form values with user defaults
        //self.loadNotificationControlValues()

        self.loadFavoriteMap()
        
        // Initialize controls per device
        //self.initializeControlsPerDevice()
        
    }
    
    // Load map with default lat, long, and polygon coordinates or load Chicago map
    func loadFavoriteMap() {
        
        // Set required properties for map
        //self.favoriteListMapView.delegate = self
        self.favoriteListMapView.removeOverlays(favoriteListMapView.overlays)
        self.favoriteListMapView.removeAnnotations(favoriteListMapView.annotations)
        
        // Get favorite values from defaults
//        let favoriteAddress = self.common.favoriteAddress()
//        let favoriteWard = self.common.favoriteWard()
//        let favoriteSection = self.common.favoriteSection()
//        let favoriteLongitude = self.common.favoriteLongitude()
//        let favoriteLatitude = self.common.favoriteLatitude()
//        let favoriteCoordinatesArray = self.common.favoriteCoordinatesArray()
//        let selectedAnnotationLongitude = self.common.selectedAnnotationLongitude()
//        let selectedAnnotationLatitude = self.common.selectedAnnotationLatitude()
//        var mapOverlayCoordinates = [CLLocationCoordinate2D]()
//
//        if favoriteLongitude != 0 && favoriteLatitude != 0 {
//
//            // Loop through favorite coordinates array
//            if favoriteCoordinatesArray.count > 0 {
//                for(_, coordinate) in favoriteCoordinatesArray.enumerated() {
//                    for item in coordinate {
//
//                        // Add coordinates to array for map
//                        var coordinate = CLLocationCoordinate2D()
//                        coordinate.longitude = item[0] as? Double ?? 0
//                        coordinate.latitude = item[1] as? Double ?? 0
//                        mapOverlayCoordinates.append(coordinate)
//                    }
//                }
//            }
//
//            // Create polygons
//            let polygons = MKPolygon(coordinates: mapOverlayCoordinates, count: mapOverlayCoordinates.count)
//
//            // Add polygons to map
//            favoriteMapView.addOverlay(polygons)
//
//            // Create location using lat and long
//            let location =  CLLocation(latitude: favoriteLatitude, longitude: favoriteLongitude)
//            let selectedAnnotationLocation = CLLocation(latitude: selectedAnnotationLatitude, longitude: selectedAnnotationLongitude)
//
//            defaults.set(0, forKey: "selectedAnnotationLongitude")
//            defaults.set(0, forKey: "selectedAnnotationLatitude")
//
//            // Add Divvy stations to map
//            addDivvyStationsToMap(location)
//
//            // Add relocated vehicles to map
//            addRelocationVehiclesToMap(location)
//
//            // Create annotation using location coordinate
//            let annotation = CustomAnnotation()
//            annotation.customImageName = "pin-address"
//            annotation.coordinate = location.coordinate
//            annotation.title = favoriteAddress
//            annotation.subtitle = "Ward: \(favoriteWard) - Section: \(favoriteSection)"
//
//            // Create map span
//            let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
//
//            // Create map region
//            let region = MKCoordinateRegion(center: selectedAnnotationLocation.coordinate.latitude != 0 && selectedAnnotationLocation.coordinate.longitude != 0 ? selectedAnnotationLocation.coordinate : location.coordinate, span: span)
//
//            // Set map region
//            favoriteMapView.setRegion(region, animated: false)
//
//            // Add annoation to map
//            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "address")
//            self.favoriteMapView.addAnnotation(annotationView.annotation!)
//
//        }
//        else {
            
            // If there is no favorite then set the map to Chicago
        
            self.tabBarController?.navigationItem.title = "No Favorite Addresses Saved"
            
            // Create map span
            let span = MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45)
            
            // Create map coordinates using Chicago
            let chicagoCoordinate = CLLocationCoordinate2D(latitude: 41.846647, longitude: -87.629576)
            
            // Create map region using coordinates and span
            let region = MKCoordinateRegion(center: chicagoCoordinate, span: span)
            
            // Set map region
        self.favoriteListMapView.setRegion(region, animated: false)
            
            // Remove an annotations leftover from having a favorite saved
        self.favoriteListMapView.removeAnnotations(self.favoriteListMapView.annotations)
            
//        }
    }

}
