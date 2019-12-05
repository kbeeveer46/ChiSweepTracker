import UIKit
import CoreLocation
import MapKit

class SearchViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var searchAddressButton: UIButton!
    @IBOutlet weak var useMyLocationButton: UIButton!
    @IBOutlet weak var chicagoMapView: MKMapView!
    @IBOutlet weak var searchTypeSegment: UISegmentedControl!
    
    let locationManager = CLLocationManager()
    let constants = Constants()
    
    var schedule = Schedule()
    var addressFromTextField = ""
    var addressFromCoordinates = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.addressTextField.isHidden = true
        //self.searchAddressButton.isHidden = true
        self.useMyLocationButton.isHidden = true
        
        // Make enter key close keyboard
        self.addressTextField.delegate = self
        //addressTextField.layer.borderColor = UIColor(red: 48/255, green: 178/255, blue: 99/255, alpha: 1).cgColor
        //addressTextField.layer.borderWidth = 1
        //addressTextField.layer.cornerRadius = 7.0
        
        
        // Style buttons and add images
        searchAddressButton.backgroundColor = UIColor.init(red: 48/255, green: 178/255, blue: 99/255, alpha: 1)
        searchAddressButton.layer.cornerRadius = 7.0
        searchAddressButton.tintColor = .white
        if #available(iOS 13.0, *) {
            searchAddressButton.leftImage(image: UIImage(systemName: "magnifyingglass.circle")!)
        }
        
        useMyLocationButton.backgroundColor = UIColor.init(red: 48/255, green: 178/255, blue: 99/255, alpha: 1)
        useMyLocationButton.layer.cornerRadius = 7.0
        useMyLocationButton.tintColor = .white
        if #available(iOS 13.0, *) {
            useMyLocationButton.leftImage(image: UIImage(systemName: "location.circle")!)
        }
        
        // Load Chicago map
        chicagoMapView.delegate = self
        
        //let longPressGesture = UILongPressGestureRecognizer(target: chicagoMapView, action: #selector(addAnnotation(gesture:)))
        //let longPressGesture = UILongPressGestureRecognizer(target: chicagoMapView, action: #selector(addAnnotation))
        //longPressGesture.minimumPressDuration = 2.0
        //longPressGesture.delegate = self
        //chicagoMapView.addGestureRecognizer(longPressGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addAnnotation(gesture:)))
        chicagoMapView.addGestureRecognizer(tapGesture)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
        
        var chicagoCoordinate = CLLocationCoordinate2D()
        chicagoCoordinate.latitude = 41.882698
        chicagoCoordinate.longitude = -87.694779
        
        let region = MKCoordinateRegion(center: chicagoCoordinate, span: span)
        
        chicagoMapView.setRegion(region, animated: true)
        
    }
    
    @IBAction func searchTypeTapped(_ sender: Any) {
        
        if searchTypeSegment.selectedSegmentIndex == 0 {
            
            self.addressTextField.isHidden = false
            self.searchAddressButton.isHidden = false
            self.useMyLocationButton.isHidden = true
            
        }
        else if searchTypeSegment.selectedSegmentIndex == 1 {
            
            useMyLocationButton.isHidden = false
            searchAddressButton.isHidden = true
            addressTextField.isHidden = true
            
        }
        else if searchTypeSegment.selectedSegmentIndex == 2 {
            
            useMyLocationButton.isHidden = true
            searchAddressButton.isHidden = false
            addressTextField.isHidden = false
            
        }
        
    }
    
    // Add annotation when Chicago map is long pressed
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
            //annotation.title = addressFromCoordinates
            //annotation.subtitle = "subtitle"
            
            chicagoMapView.removeAnnotations(chicagoMapView.annotations)
            chicagoMapView.addAnnotation(annotation)
        }
    }
//    @objc func addAnnotation(gesture: UILongPressGestureRecognizer) {
//
//        print("addAnnotation has fired")
//
//        if gesture.state == .ended {
//
//            let point = gesture.location(in: chicagoMapView)
//            let coordinate = chicagoMapView.convert(point, toCoordinateFrom: chicagoMapView)
//            print(coordinate)
//
//
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = coordinate
//            //annotation.title = "Title"
//            //annotation.subtitle = "subtitle"
//
//            chicagoMapView.addAnnotation(annotation)
//        }
//    }
    
    // Check if segue should perform (for validatin fields)
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        addressFromTextField = addressTextField.text!.trimmingCharacters(in: .whitespaces)
        //addressFromTextField = "750 N Dearborn St. Chicago, IL"
        //addressFromTextField = "1060 W Addison Chicago, IL"
        //addressFromTextField = "1601 North Clark Street, Chicago, IL, USA"
        
//        if (sender as? UIButton == searchAddressButton) {
//
//            if addressFromTextField.isEmpty {
//
//                // Show error
//
//                return false
//
//            }
//
//        } else if (sender as? UIButton == useMyLocationButton) {
//
//            if addressFromCoordinates.isEmpty {
//
//                // Show error
//
//                return false
//
//            }
//
//
//        }
//
       return true
        
    }
    
    // Prepare segue and pass data to view controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "selectSectionSegue" {
            if let selectSectionViewController = segue.destination as? SelectSectionViewController {
                selectSectionViewController.schedule = schedule
            }
        }
//        else if segue.identifier == "viewScheduleSegue" {
//            if let sweepScheduleViewController = segue.destination as? ScheduleViewController {
//                sweepScheduleViewController.schedule = schedule
//            }
//        }
        
//        let scheduleViewController = segue.destination as! ScheduleViewController
//
//        if (sender as? UIButton == searchAddressButton) {
//
//            //print("search address button")
//            scheduleViewController.address = addressFromTextField
//
//        } else if (sender as? UIButton == useMyLocationButton) {
//
//            //print("my location button")
//            scheduleViewController.address = addressFromCoordinates
//
//        }
        
    }
    
    // Search address button is tapped
    @IBAction func searchAddressTapped(_ sender: Any) {
        
        // Check for empty string
        
        getSchedule(addressTextField.text?.trimmingCharacters(in: .whitespaces) ?? "")
        //getSchedule("750 N Dearborn St Chicago, IL")
        //getSchedule("1601 North Clark Street, Chicago, IL, USA")
    
    }
    
    // Use my location button is tapped
    @IBAction func useMyLocationTapped(_ sender: Any) {
        
        // Request location access
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
            
        }
        
    }
    
    //func getSchedule(_ address: String, _ finished: () -> Void) {
    func getSchedule(_ address: String) {
        
        self.schedule.months.removeAll()
        self.schedule.polygonCoordinatesForMap.removeAll()
        
        print("Address: \(address)")
        
        self.schedule.address = address
        
        // 1. Get coordinates
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            
            if error != nil {
                
                //self.showingError = true
                //self.errorMessage = (error! as NSError).userInfo.debugDescription
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
                
                // 2. Get ward and section JSON from City of Chicago
                
                //print("Ward query: intersects(the_geom,'POINT(\(self.longitude) \(self.latitude))')")
                
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
                            
                            // 3. Get schedule JSON from City of Chicago
                            
                            let scheduleQuery = wardClient.query(dataset: self.constants.scheduleDataset)
                                .filter("ward = '\(ward)' \(section != "" ? "AND section = '\(section)'" : "") ")
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        //self.schedules = data
                                        
                                        // 4. Populate schedule model to be used on schedule view
                                        
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
                                    
                                        self.performSegue(withIdentifier: "viewScheduleSegue", sender: self)
                                
                                    }
                                case .error (let err):
                                    
                                    print((err as NSError).userInfo.debugDescription)
                                    
                                    //self.showingError = true
                                    //self.errorMessage = (err as NSError).userInfo.debugDescription
                                }
                            }
                        }
                        else {
                            //self.showingError = true
                            //self.errorMessage = "Could not find sweep area. Please try again."
                        }
                    case .error (let err):
                        
                        print((err as NSError).userInfo.debugDescription)
                        
                        //self.showingError = true
                        //self.errorMessage = (err as NSError).userInfo.debugDescription
                        
                    }
                }
            }
            else {
                //self.showingError = true
                //self.errorMessage = "Could not find sweep area. Please try again."
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
                    print("reverse geodcode fail: \(error!.localizedDescription)")
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
            
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.denied {
            
            showLocationDisabledPopup()
            
        }
    }
    
    func showLocationDisabledPopup() {
        
        let alertController = UIAlertController(title: "Location Access Disabled", message: "You will have to manually search for your address if you wish to disable location access", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            
            if let url = URL(string: UIApplication.openSettingsURLString) {
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            }
        }
        
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
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

