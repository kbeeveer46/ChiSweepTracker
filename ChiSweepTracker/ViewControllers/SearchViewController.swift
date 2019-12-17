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
	@IBOutlet weak var refreshNotificationsAfterUpdateButton: UIButton!
	@IBOutlet weak var refreshNotificationsAfterNewDatasetButton: UIButton!
	
    let schedule = ScheduleModel()
    let locationManager = CLLocationManager()
    let common = Common()
    let defaults = UserDefaults.standard
    
    var addressFromTextField = ""
    var addressFromCoordinates = ""
	//var latestDatasetVersionGlobal = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Not everything I want loads in viewDidLoad so I put it in viewWillAppear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

		//self.defaults.set(1, forKey: "userDatasetVersion")
		
		//self.updateNotifications()
		
		self.showFinishedScheduleButton()
		
//		self.getCityOfChicagoValuesFromDatabase(completion: { message in
//	
//			
//		})
		
		self.loadSearchMap()
		
		// Style controls
		self.styleControls()
		
		// Make enter key close keyboard
		self.addressTextField.delegate = self
        
    }
    
    // MARK: Methods
	
	// Show finished schedule button if the current month is less thatn 4 (April) or greater than 11 (November)
	func showFinishedScheduleButton() {
		
		let currentMonthNumber = Calendar.current.component(.month, from: Date())
		var currentYear = Calendar.current.component(.year, from: Date())
		if (currentMonthNumber < 4) {
			currentYear = currentYear - 1
		}
		
		self.finishedScheduleButton.isHidden = true
		
		if currentMonthNumber < 4 || currentMonthNumber > 11
		{
			let attributedString = NSMutableAttributedString(string: "Sweeping has ended for \(currentYear). Check back next spring for the new schedule and to set up your notifications.")
			self.finishedScheduleButton.setAttributedTitle(attributedString, for: .normal)
			self.finishedScheduleButton.isHidden = false
		}
	}
	
//	func addNotificationsForLatestDatasetVersion() {
//
//		let favoriteAddress = self.common.constants.favoriteAddress()
//		let notificationsToggled = self.common.constants.notificationsToggled()
//
//		if !favoriteAddress.isEmpty && notificationsToggled == true {
//
//
//
//		}
//
//
//	}
//
//
//	func addNotificationsForLatestAppVersion() {
//
//		let favoriteAddress = self.common.constants.favoriteAddress()
//		let notificationsToggled = self.common.constants.notificationsToggled()
//
//		if !favoriteAddress.isEmpty && notificationsToggled == true {
//
//
//
//		}
//
//	}
//
//	func showNewScheduleButton() {
//
//		// User's app version (year) is stored in constants file
//		// Pull the latest version (year) from the database and see if it matches user app version
//		// If it does not match that means the City of Chicago has released a new schedule and I put the values in Firebase
//		// If it does not match, show new schedule button and direct them to the app store.
//		// This requires a new record in Firebase at the exact same time the app is released
//
//		self.newScheduleButton.isHidden = true
//
//		let userAppVersion = self.common.constants.appVersion // Year
//		let latestAppVersion = self.common.constants.latestAppVersion()
//
//		print("Latest App Version: \(latestAppVersion)")
//		print("User App Version: \(userAppVersion)")
//
//		if userAppVersion < latestAppVersion {
//
//			let newButtonString = NSMutableAttributedString(string: "\(latestAppVersion) sweep schedule is now available! You must update this app to see the new schedule and set up your notifications. Click here to visit the App Store.")
//			self.newScheduleButton.setAttributedTitle(newButtonString, for: .normal)
//			self.newScheduleButton.addTarget(nil, action: #selector(self.common.openAppStore), for: .touchUpInside)
//			self.newScheduleButton.isHidden = false
//
//		}
//		else {
//
//			// Only show finished button if the new button is not shown
//			self.showFinishedScheduleButton()
//
//		}
//	}
//
	
//	func showRefreshNotificationsAfterNewVersionButton() {
//
//		// Show "new version" refresh notifications button after users updates the app
//
//		self.refreshNotificationsAfterUpdateButton.isHidden = true
//
//		let favoriteAddress = self.common.constants.favoriteAddress()
//		let notificationsToggled = self.common.constants.notificationsToggled()
//		//let hasUserRefreshedNotificationsAfterNewVersion = self.common.constants.hasUserRefreshedNotificationsAfterNewVersion()
//		let lastYearUserRefreshedNotificationsAfterNewVersion = self.common.constants.lastYearUserRefreshedNotifications()
//		let appVersion = self.common.constants.appVersion
//		let latestAppVersion = Int(self.common.constants.latestAppVersion())
//
//		if !favoriteAddress.isEmpty &&
//			notificationsToggled == true &&
//			appVersion == latestAppVersion &&
//			//hasUserRefreshedNotificationsAfterNewVersion == false &&
//			(lastYearUserRefreshedNotificationsAfterNewVersion == 0 || lastYearUserRefreshedNotificationsAfterNewVersion < appVersion) {
//
//			// This runs when it shouldn't!!
//			// Need to figure out how to tell the difference between a new and updated install
//			self.refreshNotificationsAfterNewVersion()
//
//			//self.refreshNotificationsAfterUpdateButton.addTarget(nil, action: #selector(self.refreshNotifications), for: .touchUpInside)
//			//self.refreshNotificationsAfterUpdateButton.isHidden = false
//
//		}
//
//	}
	
	// Check to see if Chicago has updated the schedule/data set
	// This means that I updated the "version" field by 1 in the Updates table
//	func showRefreshNoticationsAfterDatasetUpdateButton() {
//
//		self.refreshNotificationsAfterNewDatasetButton.isHidden = true
//
//		let db = Firestore.firestore()
//		let docRef = db.collection(self.common.constants.updatesDatabaseName)
//			.document(String(self.common.constants.appVersion))
//
//		docRef.getDocument { (document, error) in
//			if let document = document, document.exists {
//
//				let data = document.data()
//
//				let latestDatasetVersion = data!["version"] as! Int
//				let userDatasetVersion = self.common.constants.userDatasetVersion()
//				let favoriteAddress = self.common.constants.favoriteAddress()
//				let notificationsToggled = self.common.constants.notificationsToggled()
//				//let hasUserRefreshedNotificationsAfterNewDataset = self.common.constants.hasUserRefreshedNotificationsAfterNewDataset()
//				//let lastVersionUserRefreshedNewDatasetNotifications = self.common.constants.lastVersionUserRefreshedNewDatasetNotifications()
//
//				print("Latest dataset version: \(latestDatasetVersion)")
//				print("User dataset version: \(userDatasetVersion)")
//				//print("User has updated: \(hasUserRefreshedNotificationsAfterNewDataset)")
//				//print("Last dataset version user has updated: \(lastVersionUserRefreshedNewDatasetNotifications)")
//
//				// Set this value globally so I can set it in their defaults when they click on the button
//				// I don't have access to the latestDataset in the button tapped event so I had to set it here
//				self.latestDatasetVersionGlobal = latestDatasetVersion
//
//				if userDatasetVersion == 0 {
//					// Set userDatasetVersion default to the latest data set version if this is the first time they opened the app
//					self.defaults.set(latestDatasetVersion, forKey: "userDatasetVersion")
//				}
//				else if userDatasetVersion > 0 &&
//					    userDatasetVersion < latestDatasetVersion &&
//					    !favoriteAddress.isEmpty &&
//					    notificationsToggled == true //&&
//					//hasUserRefreshedNotificationsAfterNewDataset == false &&
//					//(lastVersionUserRefreshedNewDatasetNotifications == 0 || (lastVersionUserRefreshedNewDatasetNotifications < latestDatasetVersion))
//				{
//					// Show refresh notifications after a new dataset button
//					self.refreshNotificationsAfterNewDatasetButton.addTarget(nil, action: #selector(self.refreshNotificationsAfterNewDataset), for: .touchUpInside)
//					self.refreshNotificationsAfterNewDatasetButton.isHidden = false
//				}
//			} else {
//				print("Updates database record does not exist for \(self.common.constants.appVersion)")
//			}
//		}
//	}
	
//	@objc func refreshNotificationsAfterNewDataset() {
//		
//		// Call getSchedule in the notification controller because that function also adds notifications
//		let notificationViewController = NotificationsViewController()
//		notificationViewController.getSchedule(true, true)
//		
//		// Hide button after notifications are refreshed
//		self.refreshNotificationsAfterNewDatasetButton.isHidden = true
//		
//		// Set users data set version to the newest now that they updated
//		// I wish I could set this in the notification controller getSchedule call but I don't have access to latestDatasetVersion
//		defaults.set(latestDatasetVersionGlobal, forKey: "userDatasetVersion")
//		
//	}
//	
//	@objc func refreshNotificationsAfterNewVersion() {
//		
//		// Call getSchedule in the notification controller because that function also adds notifications
//		let notificationViewController = NotificationsViewController()
//		notificationViewController.getSchedule(true, true)
//		
//		// Hide button after notifications are refreshed
//		self.refreshNotificationsAfterUpdateButton.isHidden = true
//	}

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
    
    func searchForSchedule(_ address: String) {
        
        self.schedule.months.removeAll()
        self.schedule.polygonCoordinates.removeAll()
        
        print("getSchedule address: \(address)")
        
        self.schedule.address = address
        
        // Get coordinates
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            
            if error != nil {
                self.common.showAlert(self.common.constants.errorTitle, "You must be connected to the Internet to find your sweep area.")
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
                
				print("geom: \(self.common.constants.the_geom())")
				print("ward dataset: \(self.common.constants.wardDataset())")
				
                let wardQuery = wardClient.query(dataset: self.common.constants.wardDataset())
                    .filter("intersects(\(self.common.constants.the_geom()),'POINT(\(self.schedule.locationCoordinate.longitude) \(self.schedule.locationCoordinate.latitude))')")
                
                wardQuery.get { res in
                    switch res {
                    case .dataset (let data):
                        
                        if data.count > 0 {
                            
                            let ward = data[0][self.common.constants.ward()] as? String ?? ""
                            let section = data[0][self.common.constants.section()] as? String ?? ""
                            let the_geom = data[0][self.common.constants.the_geom()] as? [String: Any] ?? [:]
                            let coordinatesWrapper = the_geom[self.common.constants.coordinates()] as? NSMutableArray
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
                            
                            let scheduleQuery = wardClient.query(dataset: self.common.constants.scheduleDataset())
                                .filter("ward = '\(ward)' \(section != "" ? "AND section = '\(section)'" : "") ")
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        // Populate schedule model to be used on schedule view
                                        
                                        for (_, item) in data.enumerated() {
                                            
                                            let monthName = item[self.common.constants.month_name()] as? String ?? ""
                                            let monthNumber = item[self.common.constants.month_number()] as? String ?? ""
                                            let dates = item[self.common.constants.dates()] as? String ?? ""
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
					print("getAddressFromCoordinates error: \(error!.localizedDescription)")
					// Stop updating location if user appears to be offline
					self.locationManager.stopUpdatingLocation()
                    self.common.showAlert(self.common.constants.errorTitle, "You must be connected to the Internet to find your sweep area.")
					return
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
	
	// Load map using use default values or a generic map of Chicago
	func loadSearchMap() {
		
		chicagoMapView.delegate = self
		
		let addressFromDefaults = defaults.string(forKey: "defaultAddress") ?? ""
		let longitudeFromDefaults = defaults.double(forKey: "defaultLongitude")
		let latitudeFromDefaults = defaults.double(forKey: "defaultLatitude")
		
		print("Default address: \(addressFromDefaults)")
		print("Default longitude: \(longitudeFromDefaults)")
		print("Default latitude: \(latitudeFromDefaults)")
		
		addressTextField.text = addressFromDefaults
		
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
	
	// MARK: Actions
	
	// Search type segmented control option changed event
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
		self.searchForSchedule(address)
		
		// Test addresses
		//self.searchForSchedule("1601 North Clark Street, Chicago, IL, USA") // Has multiple sections
		
	}
	
	// Prepare segue and pass data to view controllers
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "selectSectionSegue" {
			if let selectSectionViewController = segue.destination as? SelectSectionViewController {
				selectSectionViewController.schedule = schedule
			}
		}
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
		self.common.styleButton(refreshNotificationsAfterUpdateButton, "phone_white", "863D96")
		self.common.styleButton(refreshNotificationsAfterNewDatasetButton, "ended", "BF1A2F")

    }
}

