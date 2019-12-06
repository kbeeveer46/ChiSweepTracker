import UIKit
import CoreLocation
import MapKit

class SearchViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var searchAddressButton: UIButton!
    @IBOutlet weak var chicagoMapView: MKMapView!
    @IBOutlet weak var searchTypeSegment: UISegmentedControl!
    
    
    let locationManager = CLLocationManager()
    let constants = Constants()
    var droppedPin = MKPointAnnotation()
    
    var schedule = Schedule()
    var addressFromTextField = ""
    var addressFromCoordinates = ""
    //var errorMessage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make enter key close keyboard
        self.addressTextField.delegate = self
        //addressTextField.layer.borderColor = UIColor(red: 48/255, green: 178/255, blue: 99/255, alpha: 1).cgColor
        //addressTextField.layer.borderWidth = 1
        //addressTextField.layer.cornerRadius = 7.0
        
        self.styleControls()
        
        self.loadChicagoMap()
        
        //self.showError("This is an error message")
        
    }
    
    // MARK - Actions
    
    @IBAction func searchTypeTapped(_ sender: Any) {
        
        chicagoMapView.removeAnnotations(chicagoMapView.annotations)
        
        if searchTypeSegment.selectedSegmentIndex == 0 {
            
            chicagoMapView.addAnnotation(droppedPin) // Doesn't work!
            locationManager.stopUpdatingLocation()
            
        }
        else if searchTypeSegment.selectedSegmentIndex == 1 {
            
            addressTextField.text = ""
            
            // Request location access
            locationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.locationServicesEnabled() {
                
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                locationManager.startUpdatingLocation()
                
                
            }

        }
        else if searchTypeSegment.selectedSegmentIndex == 2 {
            
            locationManager.stopUpdatingLocation()

        }
    }
    
    // Search address button is tapped
    @IBAction func searchAddressTapped(_ sender: Any) {
        
        if searchTypeSegment.selectedSegmentIndex != 1 {
            locationManager.stopUpdatingLocation()
        }
        
        getSchedule(addressTextField.text?.trimmingCharacters(in: .whitespaces) ?? "")
        //getSchedule("750 N Dearborn St Chicago, IL")
        //getSchedule("1601 North Clark Street, Chicago, IL, USA")
    
    }
    
    // Add annotation when Chicago map is tapped
    @objc func addAnnotation(gesture: UIGestureRecognizer) {
        
        if gesture.state == .ended {
            
            let point = gesture.location(in: chicagoMapView)
            let coordinate = chicagoMapView.convert(point, toCoordinateFrom: chicagoMapView)
            
            //print("Pin coordinates: \(coordinate))")
            
            let getLat: CLLocationDegrees = coordinate.latitude
            let getLon: CLLocationDegrees = coordinate.longitude

            let location: CLLocation =  CLLocation(latitude: getLat, longitude: getLon)
            
            getAddressFromCoordinates(location)
            addressTextField.text = addressFromCoordinates
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            //droppedPin = annotation // Doesn't work!!
            
            chicagoMapView.removeAnnotations(chicagoMapView.annotations)
            chicagoMapView.addAnnotation(annotation)

        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationIdentifier = "AnnotationIdentifier"

        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }

        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "car_pin")
        }
        
        return annotationView

    }
    

    
    // Prepare segue and pass data to view controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "selectSectionSegue" {
            if let selectSectionViewController = segue.destination as? SelectSectionViewController {
                selectSectionViewController.schedule = schedule
            }
        }
//        else if segue.identifier == "showErrorSegue" {
//            if let errorViewController = segue.destination as? ErrorViewController {
//                errorViewController.errorMessage = errorMessage
//            }
//        }
        
    }

    //func showError() {
    func showError(_ error: String) {
        
        //self.errorMessage = errorMessage
        //self.performSegue(withIdentifier: "showErrorSegue", sender: self)
        
        let alert = UIAlertController(title: "Something went wrong...", message: error, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        self.present(alert, animated: true)
        
        return
        
    }
    
    func getSchedule(_ address: String) {
        
        self.schedule.months.removeAll()
        self.schedule.polygonCoordinatesForMap.removeAll()
        
        print("Address: \(address)")
        
        self.schedule.address = address
        
        // Get coordinates
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            
            if error != nil {
                
                //self.showError((error! as NSError).userInfo.debugDescription)
            }
            
            if placemarks != nil {
            
                let placemark = placemarks?.first
                
                var coordinates = CLLocationCoordinate2D()
                coordinates.latitude = placemark?.location?.coordinate.latitude ?? 0
                coordinates.longitude = placemark?.location?.coordinate.longitude ?? 0
                self.schedule.locationCoordinate = coordinates
                
                print("Latitude: \(self.schedule.locationCoordinate.latitude)")
                print("Longitude: \(self.schedule.locationCoordinate.longitude)")
                
                let wardClient = SODAClient(domain: self.constants.SODADomain, token: self.constants.SODAToken)
                
                // Get ward and section JSON from City of Chicago
                
                let wardQuery = wardClient.query(dataset: self.constants.wardDataset)
                    .filter("intersects(\(self.constants.the_geom),'POINT(\(self.schedule.locationCoordinate.longitude) \(self.schedule.locationCoordinate.latitude))')")
                
                wardQuery.get { res in
                    switch res {
                    case .dataset (let data):
                        
                        if data.count > 0 {
                            
                            let ward = data[0]["ward"] as? String ?? ""
                            let section = data[0]["section"] as? String ?? ""
                            let the_geom = data[0][self.constants.the_geom] as? [String: Any] ?? [:]
                            let coordinatesWrapper = the_geom["coordinates"] as? NSMutableArray
                            let coordinatesArray = coordinatesWrapper?[0] as? [[NSMutableArray]]
                            
                            for(_, coordinate) in coordinatesArray!.enumerated() {
                                
                                for item in coordinate {
                                    
                                    var coordinate = CLLocationCoordinate2D()
                                    coordinate.longitude = item[0] as? Double ?? 0
                                    coordinate.latitude = item[1] as? Double ?? 0
                                    
                                    self.schedule.polygonCoordinatesForMap.append(coordinate)
                                    
                                }
                            }
                            
                            print("Ward: \(ward)")
                            print("Section: \(section)")
                            
                            self.schedule.ward = ward
                            self.schedule.section = String(section).trimmingCharacters(in: .whitespaces)
                            
                            if self.schedule.section.isEmpty {
                                
                                self.performSegue(withIdentifier: "selectSectionSegue", sender: self)
                                return
                            }
                            
                            // Get schedule JSON from City of Chicago
                            
                            let scheduleQuery = wardClient.query(dataset: self.constants.scheduleDataset)
                                .filter("ward = '\(ward)' \(section != "" ? "AND section = '\(section)'" : "") ")
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        // Populate schedule model to be used on schedule view
                                        
                                        for (_, item) in data.enumerated() {
                                            
                                            let monthName = item["month_name"] as? String ?? ""
                                            let monthNumber = item["month_number"] as? Int ?? 0
                                            let dates = item["dates"] as? String ?? ""
                                            let datesArray = dates.components(separatedBy: ",")
                                            
                                            print("Month name: \(monthName)")
                                            print("Dates: \(datesArray)")
                                            
                                            let month = Month()
                                            month.name = monthName
                                            month.number = monthNumber
                                            
                                            for day in datesArray {
                                                
                                                print("Date: \(day)")
                                                
                                                if !day.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                    
                                                    let date = Date()
                                                    date.date = Int(day) ?? 0
                                                    
                                                    if !month.dates.contains(where: { $0.date == Int(day) ?? 0}) {
                                                        month.dates.append(date)
                                                    }
                                                }
                                            }
                                            
                                            self.schedule.months.append(month)
                                            
                                        }
                                    
                                        self.performSegue(withIdentifier: "selectSectionSegue", sender: self)
                                
                                    }
                                case .error (let err):
                                    
                                    self.showError((err as NSError).userInfo.debugDescription)
                                    
                                }
                            }
                        }
                        else {
                            
                            self.showError(self.constants.notFound)
                            
                        }
                    case .error (let err):
                        
                        self.showError((err as NSError).userInfo.debugDescription)
                        
                    }
                }
            }
            else {
                
                self.showError(self.constants.notFound)
            }
        }
    }

    // Get address from coordinates after location manager retrieves user's location
    func getAddressFromCoordinates(_ location: CLLocation) {
        
        var address = ""
        let ceo: CLGeocoder = CLGeocoder()
        let loc: CLLocation = CLLocation(latitude: location.coordinate.latitude,
                                         longitude: location.coordinate.longitude)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    //self.showError(error!.localizedDescription)
                }
                
                if placemarks != nil {
                    
                    if placemarks!.count > 0 {
                        
                        let pm = placemarks! as [CLPlacemark]
                        
                        if pm.count > 0 {
                            
                            let pm = placemarks![0]
                            
                            if pm.subThoroughfare != nil {
                                address = address + pm.subThoroughfare! + " "
                            }
                            if pm.thoroughfare != nil {
                                address = address + pm.thoroughfare! + ", "
                            }
                            if pm.locality != nil {
                                address = address + pm.locality! + " "
                            }
                            if pm.postalCode != nil {
                                address = address + pm.postalCode! + " "
                            }
                            
                            self.addressFromCoordinates = address.trimmingCharacters(in: .whitespaces)
                            self.addressTextField.text = self.addressFromCoordinates
                            
                            print("getAddressFromCoordinates: \(self.addressFromCoordinates)")
                            
                        }
                    }
                }
        })
    }
    
    // MARK - Location Manager
    
    // Get user's last location and get address from coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            
            getAddressFromCoordinates(location)
            
            var coordinates = CLLocationCoordinate2D()
            coordinates.latitude = location.coordinate.latitude
            coordinates.longitude = location.coordinate.longitude
            
            let span = MKCoordinateSpan(latitudeDelta: 0.0009, longitudeDelta: 0.0009)
            let region = MKCoordinateRegion(center: coordinates, span: span)
            
            chicagoMapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            //annotation.title = addressTextField.text
            chicagoMapView.removeAnnotations(chicagoMapView.annotations)
            chicagoMapView.addAnnotation(annotation)
            
            locationManager.stopUpdatingLocation()
            
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.denied {
            
            showLocationDisabledPopup()
            
        }
    }
    
    func showLocationDisabledPopup() {
        
        let alertController = UIAlertController(title: "Location Access Disabled", message: "You will have to drop a pin or manually search for your address", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            
            if let url = URL(string: UIApplication.openSettingsURLString) {
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
                
            }
        }
        
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK - Load Chicago map
    
    func loadChicagoMap() {
        
        chicagoMapView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addAnnotation(gesture:)))
        chicagoMapView.addGestureRecognizer(tapGesture)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45)
        
        var chicagoCoordinate = CLLocationCoordinate2D()
        chicagoCoordinate.latitude = 41.846647
        chicagoCoordinate.longitude = -87.629576
        
        let region = MKCoordinateRegion(center: chicagoCoordinate, span: span)
        
        chicagoMapView.setRegion(region, animated: true)
        
    }
    
    // MARK - Styling
    
    func styleControls() {
        
        searchAddressButton.backgroundColor = .systemBlue
        searchAddressButton.layer.cornerRadius = 7.0
        searchAddressButton.tintColor = .white
        searchAddressButton.leftImage(image: UIImage(named: "search_circle")!)
        
    }
    
    // MARK - Helpers
    
    // Make enter key close keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
}

// MARK - Extensions

extension UIButton {
    
    // Add image on left view
    func leftImage(image: UIImage) {
        self.setImage(image, for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image.size.width)
    }
}


//    // Check if segue should perform (for validatin fields)
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//
//        addressFromTextField = addressTextField.text!.trimmingCharacters(in: .whitespaces)
//        //addressFromTextField = "750 N Dearborn St. Chicago, IL"
//        //addressFromTextField = "1060 W Addison Chicago, IL"
//        //addressFromTextField = "1601 North Clark Street, Chicago, IL, USA"
//
////        if (sender as? UIButton == searchAddressButton) {
////
////            if addressFromTextField.isEmpty {
////
////                // Show error
////
////                return false
////
////            }
////
////        } else if (sender as? UIButton == useMyLocationButton) {
////
////            if addressFromCoordinates.isEmpty {
////
////                // Show error
////
////                return false
////
////            }
////
////
////        }
////
//       return true
//
//    }
