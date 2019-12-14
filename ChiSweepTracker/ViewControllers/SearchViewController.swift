import UIKit
import CoreLocation
import MapKit
import Firebase

class SearchViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Not everything I want loads in viewDidLoad so I put it in viewWillAppear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

		// Show new schedule button if userAppVersion doesn't match latest appVersion (year) in Firestore
        showNewScheduleButton()
		
		// Style controls
        styleControls()
        
		// Get default address, lat, and long
        getDefaults()
        
		// Load map of Chicago or use default lat and long
        loadSearchMap()
        
        // Make enter key close keyboard
        self.addressTextField.delegate = self
        
    }
    
    // MARK: Actions
    
	// Search for sweep schedule button clicked
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
            
            // Request location access. If access granted, start updating location and update map
            locationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.locationServicesEnabled() {
                    
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                
            }
            else {
                print("Location services are not enabled")
            }
            
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
        
		// Stop updating user's location to save battery
        locationManager.stopUpdatingLocation()
        
		// Get address from text field for searching
        var address = addressTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
		// Add "Chicago" to address if it doesn't contain it to help find address
        if !address.lowercased().contains("chicago") && !address.isEmpty {
            address = address + " Chicago"
        }
        
		// Alert user if they didn't enter an address
        if address.isEmpty {
            self.common.showAlert("Please Enter An Address", "")
            return
        }
        
		// Find address and go to select section view or schedule view
        getSchedule(address)
		
		// Test addresses
        //getSchedule("1601 North Clark Street, Chicago, IL, USA") // Has multiple sections
    
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
	
	// Add annotation when Chicago map is tapped
	@objc func addDroppedPin(gesture: UIGestureRecognizer) {
		
		if gesture.state == .ended {
			
			let point = gesture.location(in: chicagoMapView)
			let coordinate = chicagoMapView.convert(point, toCoordinateFrom: chicagoMapView)
			
			let location: CLLocation =  CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
			
			// Save default lat and long to be use when user re-opens app
			self.defaults.set(coordinate.latitude, forKey: "defaultLatitude")
			self.defaults.set(coordinate.longitude, forKey: "defaultLongitude")
			
			getAddressFromCoordinates(location)
			
			let annotation = MKPointAnnotation()
			annotation.coordinate = coordinate
			
			chicagoMapView.removeAnnotations(chicagoMapView.annotations)
			chicagoMapView.addAnnotation(annotation)
			
		}
	}
    
    func showNewScheduleButton() {
        
		// User's app version is stored in constants file
		// Pull the latest version (year) from the database and see if it matches user app version
		// If it does not match that means the City of Chicago has released a new schedule and I put the values in Firebase
		// If it does not match show new schedule button and direct them to the app store.
		// This requires a new record in Firebase at the exact same time the app is released
		
        self.newScheduleButton.isHidden = true
        let userAppVersion = Int(self.common.constants.appVersion)! // Year
        
        let db = Firestore.firestore()
        db.collection("Schedules")
            .order(by: "year", descending: true)
            .limit(to: 1)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Could not get showNewScheduleButton data from Firebase: \(err)")
                } else {
                    for document in querySnapshot!.documents {

                        let latestAppVersion = document.data()["year"] as! Int
                        
						print("userAppVersion: \(userAppVersion)")
						print("latestAppVersion: \(latestAppVersion)")
						
                        if userAppVersion < latestAppVersion {
                            
							// TODO: Change this string to include app id to go directly to app in store
                            let newButtonString = NSMutableAttributedString(string: "\(latestAppVersion) sweep schedule is now available. You must update this app to view the new schedule and set up your notifications. Click here to visit the App Store and update.")
                            self.newScheduleButton.setAttributedTitle(newButtonString, for: .normal)
                            self.newScheduleButton.addTarget(nil, action: #selector(self.refreshNotifications), for: .touchUpInside)
                            self.newScheduleButton.isHidden = false
                            
                        }
						else {
							
							// Only show finished button if the new button is not shown
							self.showFinishedScheduleButton()
							
						}
                    }
                }
        }
    }
    
    @objc func refreshNotifications() {
        
		// Send user to app store to update app
        
    }
    
    func showFinishedScheduleButton() {
        
		// Show finished schedule button if the current month is greater than the last month of sweeping
		
		self.finishedScheduleButton.isHidden = true
		
		let isNewButtonVisible = !self.newScheduleButton.isHidden
        let currentMonthNumber = Calendar.current.component(.month, from: Date())
		let currentYear = Int(self.common.constants.appVersion)! // Year
        let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
        
        let wardQuery = wardClient.query(dataset: self.common.constants.scheduleDataset)
			.limit(1)
			.orderDescending("month_number")
			.filter("month_number IS NOT NULL")
		
		wardQuery.get { res in
		switch res {
		case .dataset (let data):
			
			let month = data[0][self.common.constants.month_number] as? String ?? ""
			print("Last sweep month: \(month)")
			
			if !month.isEmpty {
				if Int(month)! > 0 {
					if (currentMonthNumber > Int(month)!) && isNewButtonVisible == false {
						self.finishedScheduleButton.isHidden = false
						let attributedString = NSMutableAttributedString(string: "Sweeping has ended for \(currentYear). Check back next spring for the new schedule and to set up your notifications.")
						self.finishedScheduleButton.setAttributedTitle(attributedString, for: .normal)
					}
				}
			}
		case .error (let err):
			print("Unable to get getSweepingStatus data from the City of Chicago: \(err.localizedDescription)")
			}
		}
    }
    
    func getSchedule(_ address: String) {
        
        self.schedule.months.removeAll()
        self.schedule.polygonCoordinates.removeAll()
        
        print("getSchedule address: \(address)")
        
        self.schedule.address = address
        
        // Get coordinates
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            
            if error != nil {
                self.common.showAlert(self.common.constants.errorTitle, "getSchedule: Unable to get coordinats from Apple's servers")
                return
            }
            
            if placemarks != nil {
            
                let placemark = placemarks?.first
                
                var coordinates = CLLocationCoordinate2D()
                coordinates.latitude = placemark?.location?.coordinate.latitude ?? 0
                coordinates.longitude = placemark?.location?.coordinate.longitude ?? 0
                self.schedule.locationCoordinate = coordinates
                
				// Set default lat and long to be used when user re-opens the app
                self.defaults.set(placemark?.location?.coordinate.latitude, forKey: "defaultLatitude")
                self.defaults.set(placemark?.location?.coordinate.longitude, forKey: "defaultLongitude")
                
				// Save default lat and long to be use when user re-opens app
                print("getSchedule latitude: \(self.schedule.locationCoordinate.latitude)")
                print("getSchedule longitude: \(self.schedule.locationCoordinate.longitude)")
                
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
                            
							// Set default polygon array to be used on all the views
                            self.defaults.set(coordinatesArray, forKey: "defaultCoordinatesArray")
                            //self.defaults.synchronize()
                            
                            for(_, coordinate) in coordinatesArray!.enumerated() {
                                
                                for item in coordinate {
                                    
                                    var coordinate = CLLocationCoordinate2D()
                                    coordinate.longitude = item[0] as? Double ?? 0
                                    coordinate.latitude = item[1] as? Double ?? 0
                                    
                                    self.schedule.polygonCoordinates.append(coordinate)
                                    
                                }
                            }
                            
                            print("getSchedule ward: \(ward)")
                            print("getSchedule section: \(section)")
                            
                            self.schedule.ward = ward
                            self.schedule.section = String(section).trimmingCharacters(in: .whitespaces)
                            
							// If there are multiple sections then segue to select section view
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
                                            
                                            print("getSchedule month name: \(monthName)")
                                            print("getSchedule dates: \(datesArray)")
                                            
                                            let month = MonthModel()
                                            month.name = monthName
                                            month.number = monthNumber
                                            
                                            for day in datesArray {
                                                
                                                print("getSchedule date: \(day)")
                                                
                                                if !day.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                    
                                                    let date = DateModel()
                                                    date.date = Int(day) ?? 0
                                                    
                                                    if !month.dates.contains(where: { $0.date == Int(day) ?? 0}) {
                                                        month.dates.append(date)
                                                    }
                                                }
                                            }
                                            
                                            self.schedule.months.append(month)
                                            
                                        }
                                        
										// Segue to schedule view
                                        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
                                            destinationViewController.schedule = self.schedule
                                            self.navigationController?.pushViewController(destinationViewController, animated: true)
                                        }
                                
                                    }
                                case .error (let err):
                                    print("getSchedule Unable to get schedule data from the City of Chicago: \(err.localizedDescription)")
                                    self.common.showAlert(self.common.constants.errorTitle, "Unable to get schedule data from the City of Chicago")
                                }
                            }
                        }
                        else {
                            self.common.showAlert(self.common.constants.errorTitle, self.common.constants.notFound)
                        }
                    case .error (let err):
                        print("getSchedule Unable to get ward data from the City of Chicago: \(err.localizedDescription)")
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
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                if (error != nil) {
                    self.common.showAlert(self.common.constants.errorTitle, error!.localizedDescription)
                }
                
                if placemarks != nil {
                    
                    if placemarks!.count > 0 {
                        
                        let placemark = placemarks! as [CLPlacemark]
                        
                        if placemark.count > 0 {
                            
                            let mark = placemarks![0]
                            
                            if mark.subThoroughfare != nil {
                                address = address + mark.subThoroughfare! + " "
                            }
                            if mark.thoroughfare != nil {
                                address = address + mark.thoroughfare! + ", "
                            }
                            if mark.locality != nil {
                                address = address + mark.locality! + " "
                            }
                            if mark.postalCode != nil {
                                address = address + mark.postalCode! + " "
                            }
                            
                            self.addressFromCoordinates = address.trimmingCharacters(in: .whitespaces)
                            self.addressTextField.text = self.addressFromCoordinates
							
							// Save default address to be use when user re-opens app
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
            
			// Set default lat and long to be used when user re-opens app
            self.defaults.set(location.coordinate.latitude, forKey: "defaultLatitude")
            self.defaults.set(location.coordinate.longitude, forKey: "defaultLongitude")
            
			// Get address from coordinates to be used to fill in address text field and for schedule model
            getAddressFromCoordinates(location)
            
            var coordinates = CLLocationCoordinate2D()
            coordinates.latitude = location.coordinate.latitude
            coordinates.longitude = location.coordinate.longitude
            
			let annotation = MKPointAnnotation()
			annotation.coordinate = coordinates
			
            let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
            let region = MKCoordinateRegion(center: coordinates, span: span)
            
            chicagoMapView.setRegion(region, animated: true)
            chicagoMapView.removeAnnotations(chicagoMapView.annotations)
            chicagoMapView.addAnnotation(annotation)
            
        }
    }
    
    // If user denies location access then show location disabled alert
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.denied {
            showLocationDisabledAlert()
        }
    }
    
	// If user disables location access prompt them to open the settings page to re-enable it
    func showLocationDisabledAlert() {
        
        let alertController = UIAlertController(title: "Location Access Disabled", message: "You will have to drop a pin on the map or enter your address", preferredStyle: .alert)
        
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
    
	// Get default lat, long, and address to populate the map and address text field
    func getDefaults() {
        
        addressFromDefaults = defaults.string(forKey: "defaultAddress") ?? ""
        longitudeFromDefaults = defaults.double(forKey: "defaultLongitude")
        latitudeFromDefaults = defaults.double(forKey: "defaultLatitude")
        
        print("Default address: \(addressFromDefaults)")
        print("Default longitude: \(longitudeFromDefaults)")
        print("Default latitude: \(latitudeFromDefaults)")
        
        addressTextField.text = addressFromDefaults
        
    }
    
	// Load map using use default values or a generic map of Chicago
    func loadSearchMap() {
        
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
        
		// Navigation items in tab bar are the same for every tab so they need to be set to nil when not needed
		self.tabBarController?.navigationItem.rightBarButtonItem = nil
		self.tabBarController?.navigationItem.leftBarButtonItem = nil
		
		// Set the title or else the title is used from another tab
		self.tabBarController?.navigationItem.title = "Chicago Sweep Tracker"
		
        // Style segmented search type control
        if #available(iOS 13.0, *) {
            
            self.searchTypeSegment.selectedSegmentTintColor = UIColor(red: 1.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            
            let fontAttribute = [NSAttributedString.Key.foregroundColor: UIColor.white]

            searchTypeSegment.setTitleTextAttributes(fontAttribute, for: .selected)
        }
        
        // Style and add images to buttons
        self.common.styleButton(searchAddressButton, "search_circle", "007AFF")
        self.common.styleButton(newScheduleButton, "new", "1EA896")
        self.common.styleButton(finishedScheduleButton, "ended", "BF1A2F")
        
    }
}

