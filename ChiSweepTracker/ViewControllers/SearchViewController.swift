import UIKit
import CoreLocation
import MapKit

class SearchViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate {
    
    var window: UIWindow?
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var searchAddressButton: UIButton!
    @IBOutlet weak var chicagoMapView: MKMapView!
    @IBOutlet weak var searchTypeSegment: UISegmentedControl!
    @IBOutlet weak var newScheduleButton: UIButton!
    @IBOutlet weak var finishedScheduleButton: UIButton!
    
    let schedule = ScheduleModel()
    let locationManager = CLLocationManager()
    let common = Common()
    let defaults = UserDefaults.standard
    
    var addressFromTextField = ""
    var addressFromCoordinates = ""
    var addressFromDefaults = ""
    var longitudeFromDefaults = 0.0
    var latitudeFromDefaults = 0.0
    
    let databaseModel = DatabaseModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Check if new datasets are available and show new schedule button.
        // When user opens app save data set name
        // Check data set name against one from database.
        // If it doesn't match then they need to update their notifications.
        // Show update button on search page and notification page?
        // Only if they have notifications toggled
        self.newScheduleButton.isHidden = false
        let newButtonString = NSMutableAttributedString(string: "2020 sweep schedule available. Click here to set up your new notifications.")
        self.newScheduleButton.setAttributedTitle(newButtonString, for: .normal)
        
        styleControls()
        
        getDefaults()
        
        getSweepingStatus()
        
        loadChicagoMap()
        
        // Make enter key close keyboard
        self.addressTextField.delegate = self
        
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.title = "Chicago Sweep Tracker"
    }
    
    // MARK: Actions
    
    @IBAction func searchTypeTapped(_ sender: Any) {
        
        // Add haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        
        // Remove map annotations
        chicagoMapView.removeAnnotations(chicagoMapView.annotations)
        
        if searchTypeSegment.selectedSegmentIndex == 0 {
            
            // Stop updating location if user selects "drop pin"
            locationManager.stopUpdatingLocation()
            
        }
        else if searchTypeSegment.selectedSegmentIndex == 1 {
            
            // Request location access
            locationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.locationServicesEnabled() {
                    
                addressTextField.text = ""
                    
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                
            }
            else {
                print("Location services are not enabled")
            }
            
//            if CLLocationManager.locationServicesEnabled() {
//                 switch CLLocationManager.authorizationStatus() {
//                    case .notDetermined, .restricted, .denied:
//                         //showLocationDisabledPopup()
//                        break
//                    case .authorizedAlways, .authorizedWhenInUse:
//
//                        // Clear out address text field. It will be updated once device gets user's location
//                        addressTextField.text = ""
//
//                        locationManager.delegate = self
//                        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//                        locationManager.startUpdatingLocation()
//
//                 @unknown default:
//                    print("Location services are not enabled")
//                }
//            }
//            else {
//                print("Location services are not enabled")
//            }
            
        }
        else if searchTypeSegment.selectedSegmentIndex == 2 {
            // Stop updating location if user selects "enter address"
            locationManager.stopUpdatingLocation()
        }
    }
    
    // Search address button is tapped
    @IBAction func searchAddressTapped(_ sender: Any) {
        
        // Add haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        
        locationManager.stopUpdatingLocation()
        
        var address = addressTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        if !address.lowercased().contains("chicago") && !address.isEmpty {
            address = address + " Chicago"
        }
        
        if address.isEmpty {
            self.common.showAlert("Please Enter An Address", "")
            return
        }
        
        getSchedule(address)
        //getSchedule("750 N Dearborn St Chicago, IL")
        //getSchedule("1601 North Clark Street, Chicago, IL, USA")
    
    }
    
    // Add annotation when Chicago map is tapped
    @objc func addDroppedPin(gesture: UIGestureRecognizer) {
        
        if gesture.state == .ended {
            
            let point = gesture.location(in: chicagoMapView)
            let coordinate = chicagoMapView.convert(point, toCoordinateFrom: chicagoMapView)
            
            let location: CLLocation =  CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            self.defaults.set(coordinate.latitude, forKey: "defaultLatitude")
            self.defaults.set(coordinate.longitude, forKey: "defaultLongitude")
            
            getAddressFromCoordinates(location)
            addressTextField.text = addressFromCoordinates
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            chicagoMapView.removeAnnotations(chicagoMapView.annotations)
            chicagoMapView.addAnnotation(annotation)

        }
    }
    
    
    
    // Prepare segue and pass data to view controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectSectionSegue" {
            if let selectSectionViewController = segue.destination as? SelectSectionViewController {
                selectSectionViewController.schedule = schedule
            }
        }
    }
    
    // MARK: Methods
    
    func getSweepingStatus() {
        
        let currentMonthNumber = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
        
        let wardQuery = wardClient.query(dataset: self.common.constants.scheduleDataset)
            .limit(1)
            .orderDescending("month_number")
            .filter("month_number IS NOT NULL")
        
        wardQuery.get { res in
        switch res {
        case .dataset (let data):
            
            let month = data[0][self.common.constants.month_number] as? String ?? ""
            let days = data[0][self.common.constants.dates] as? String ?? ""
            print("Last sweep month: \(month)")
            print("Last sweep days: \(days)")
            
            if !month.isEmpty {
                if Int(month)! > 0 {
                    if currentMonthNumber > Int(month)! {
                        self.finishedScheduleButton.isHidden = false
                        let attributedString = NSMutableAttributedString(string: "Sweeping has ended for \(currentYear). Check back next spring for the new schedule and to set up your notifications.")
                        self.finishedScheduleButton.setAttributedTitle(attributedString, for: .normal)
                    }
                    else {
                        self.finishedScheduleButton.isHidden = true
                    }
                }
            }
        case .error (let err):
            print("Unable to get sweep status from the City of Chicago: \(err.localizedDescription)")
            }
        }
        
    }
    
    func getSchedule(_ address: String) {
        
        self.schedule.months.removeAll()
        self.schedule.polygonCoordinates.removeAll()
        
        print("Address: \(address)")
        
        self.schedule.address = address
        
        // Get coordinates
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            
            if error != nil {
                
                self.common.showAlert(self.common.constants.errorTitle, "Unable to get coordinats from Apple's servers")
                return
            }
            
            if placemarks != nil {
            
                let placemark = placemarks?.first
                
                var coordinates = CLLocationCoordinate2D()
                coordinates.latitude = placemark?.location?.coordinate.latitude ?? 0
                coordinates.longitude = placemark?.location?.coordinate.longitude ?? 0
                self.schedule.locationCoordinate = coordinates
                
                self.defaults.set(placemark?.location?.coordinate.latitude, forKey: "defaultLatitude")
                self.defaults.set(placemark?.location?.coordinate.longitude, forKey: "defaultLongitude")
                
                print("Latitude: \(self.schedule.locationCoordinate.latitude)")
                print("Longitude: \(self.schedule.locationCoordinate.longitude)")
                
                let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
                
                // Get ward and section JSON from City of Chicago
                
                let wardQuery = wardClient.query(dataset: self.common.constants.wardDataset)
                    .filter("intersects(\(self.common.constants.the_geom),'POINT(\(self.schedule.locationCoordinate.longitude) \(self.schedule.locationCoordinate.latitude))')")
                
                wardQuery.get { res in
                    switch res {
                    case .dataset (let data):
                        
                        if data.count > 0 {
                            
                            let ward = data[0][self.common.constants.ward] as? String ?? ""
                            let section = data[0][self.common.constants.section] as? String ?? ""
                            let the_geom = data[0][self.common.constants.the_geom] as? [String: Any] ?? [:]
                            let coordinatesWrapper = the_geom[self.common.constants.coordinates] as? NSMutableArray
                            let coordinatesArray = coordinatesWrapper?[0] as? [[NSMutableArray]]
                            
                            //let coordinatesData = NSKeyedArchiver.archivedData(withRootObject: coordinatesArray as Any)
                            self.defaults.set(coordinatesArray, forKey: "defaultCoordinatesArray")
                            self.defaults.synchronize()
                            
                            for(_, coordinate) in coordinatesArray!.enumerated() {
                                
                                for item in coordinate {
                                    
                                    var coordinate = CLLocationCoordinate2D()
                                    coordinate.longitude = item[0] as? Double ?? 0
                                    coordinate.latitude = item[1] as? Double ?? 0
                                    
                                    self.schedule.polygonCoordinates.append(coordinate)
                                    
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
                            
                            let scheduleQuery = wardClient.query(dataset: self.common.constants.scheduleDataset)
                                .filter("ward = '\(ward)' \(section != "" ? "AND section = '\(section)'" : "") ")
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        // Populate schedule model to be used on schedule view
                                        
                                        for (_, item) in data.enumerated() {
                                            
                                            let monthName = item[self.common.constants.month_name] as? String ?? ""
                                            let monthNumber = item[self.common.constants.month_number] as? String ?? ""
                                            let dates = item[self.common.constants.dates] as? String ?? ""
                                            let datesArray = dates.components(separatedBy: ",")
                                            
                                            print("Month name: \(monthName)")
                                            print("Dates: \(datesArray)")
                                            
                                            //let month = MonthModel(name: "", number: "", dates: [DateModel]())
                                            let month = MonthModel()
                                            month.name = monthName
                                            month.number = monthNumber
                                            
                                            for day in datesArray {
                                                
                                                print("Date: \(day)")
                                                
                                                if !day.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                    
                                                    //let date = DateModel(date: 0)
                                                    let date = DateModel()
                                                    date.date = Int(day) ?? 0
                                                    
                                                    if !month.dates.contains(where: { $0.date == Int(day) ?? 0}) {
                                                        month.dates.append(date)
                                                    }
                                                }
                                            }
                                            
                                            self.schedule.months.append(month)
                                            
                                        }
                                        
                                        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
                                            destinationViewController.schedule = self.schedule
                                            self.navigationController?.pushViewController(destinationViewController, animated: true)
                                        }
                                
                                    }
                                case .error (let err):
                                    print(err.localizedDescription)
                                    self.common.showAlert(self.common.constants.errorTitle, "Unable to get schedule data from the City of Chicago")
                                }
                            }
                        }
                        else {
                            self.common.showAlert(self.common.constants.errorTitle, self.common.constants.notFound)
                        }
                    case .error (let err):
                        print(err.localizedDescription)
                        self.common.showAlert(self.common.constants.errorTitle, "Unable to get ward data from the City of Chicago")
                    }
                }
            }
            else {
                
                self.common.showAlert(self.common.constants.errorTitle, self.common.constants.notFound)
            }
        }
    }

    // Get address from coordinates after location manager retrieves user's location
    func getAddressFromCoordinates(_ location: CLLocation) {
        
        var address = ""
        let ceo = CLGeocoder()
        let loc = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    self.common.showAlert(self.common.constants.errorTitle, error!.localizedDescription)
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
                            self.defaults.set(self.addressFromCoordinates, forKey: "defaultAddress")
                            
                            print("getAddressFromCoordinates: \(self.addressFromCoordinates)")
                            
                        }
                    }
                }
        })
    }
    
    // MARK: Location Manager
    
    // Get user's last location and get address from coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            
            self.defaults.set(location.coordinate.latitude, forKey: "defaultLatitude")
            self.defaults.set(location.coordinate.longitude, forKey: "defaultLongitude")
            
            getAddressFromCoordinates(location)
            
            var coordinates = CLLocationCoordinate2D()
            coordinates.latitude = location.coordinate.latitude
            coordinates.longitude = location.coordinate.longitude
            
            let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
            let region = MKCoordinateRegion(center: coordinates, span: span)
            
            chicagoMapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            chicagoMapView.removeAnnotations(chicagoMapView.annotations)
            chicagoMapView.addAnnotation(annotation)
            
            //locationManager.stopUpdatingLocation()
            
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.denied {
            
            showLocationDisabledPopup()
            
        }
    }
    
    func showLocationDisabledPopup() {
        
        let alertController = UIAlertController(title: "Location Access Disabled", message: "You will have to drop a pin or enter your address", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if #available(iOS 10.0, *) {
            
            let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                
                if let url = URL(string: UIApplication.openSettingsURLString) {
                                        
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    
                }
            }
            
            alertController.addAction(openAction)
        }

        self.present(alertController, animated: true, completion: nil)
    }
    
    func getDefaults() {
        
        addressFromDefaults = defaults.string(forKey: "defaultAddress") ?? ""
        longitudeFromDefaults = defaults.double(forKey: "defaultLongitude")
        latitudeFromDefaults = defaults.double(forKey: "defaultLatitude")
        
        print("Default address: \(addressFromDefaults)")
        print("Default longitude: \(longitudeFromDefaults)")
        print("Default latitude: \(latitudeFromDefaults)")
        
        addressTextField.text = addressFromDefaults
        
    }
    
    func loadChicagoMap() {
        
        chicagoMapView.delegate = self
        
        // Add tap gesture to allow user to tap on map to drop a pin
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addDroppedPin(gesture:)))
        chicagoMapView.addGestureRecognizer(tapGesture)
        
        // If user has previously searched for an address use those defaults to load the map
        // Load default map of the entire city of Chicago if no defaults are set
        if longitudeFromDefaults != 0 && latitudeFromDefaults != 0 {

            let location: CLLocation = CLLocation(latitude: latitudeFromDefaults, longitude: longitudeFromDefaults)

            let annotation = MKPointAnnotation()
            annotation.title = addressFromDefaults
            annotation.coordinate = location.coordinate

            let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)

            chicagoMapView.removeAnnotations(chicagoMapView.annotations)
            chicagoMapView.addAnnotation(annotation)
            chicagoMapView.setRegion(region, animated: true)
        }
        else {
            
            let span = MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45)
            
            let chicagoCoordinate = CLLocationCoordinate2D(latitude: 41.846647, longitude: -87.629576)
            
            let region = MKCoordinateRegion(center: chicagoCoordinate, span: span)
            
            chicagoMapView.setRegion(region, animated: true)
            
        }

    }
    
    // MARK: Helpers
    
    // Make enter key close keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
    
    func styleControls() {
        
        // Style segmented search type control
        if #available(iOS 13.0, *) {
            
            self.searchTypeSegment.selectedSegmentTintColor = UIColor(red: 1.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            
            let fontAttribute = [NSAttributedString.Key.foregroundColor: UIColor.white]

            searchTypeSegment.setTitleTextAttributes(fontAttribute, for: .selected)
        }
        
        // Style find sweep area button
        self.common.styleButton(searchAddressButton, "search_circle", "007AFF")
        self.common.styleButton(newScheduleButton, "new", "1EA896")
        self.common.styleButton(finishedScheduleButton, "ended", "BF1A2F")
        
    }
}

