import UIKit
import CoreLocation
import MapKit
import Firebase

class SearchViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var searchAddressButton: UIButton!
    @IBOutlet weak var chicagoMapView: MKMapView!
    @IBOutlet weak var searchTypeSegment: UISegmentedControl!
    @IBOutlet weak var finishedScheduleButton: UIButton!
	
    let schedule = ScheduleModel()
    let locationManager = CLLocationManager()
    let common = Common()
	let toast = Toast()
    
    var addressFromTextField = ""
    var addressFromCoordinates = ""
    
	// MARK: Methods
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		// Show finished schedule button if month is < 4 or greater than 11
		self.showFinishedScheduleButton()
		
		// Load map with user default lat and long or Chicago
		self.loadSearchMap()
		
		// Style controls
		self.styleControls()
        
    }
	
	// Show finished schedule button if the current month is less thatn 4 (April) or greater than 11 (November)
	func showFinishedScheduleButton() {
		
		// Get current month and year
		let currentMonthNumber = Calendar.current.component(.month, from: Date())
		var currentYear = Calendar.current.component(.year, from: Date())
		
		// If month is less than 4 then change the year to the previous year
		if (currentMonthNumber < 4) {
			currentYear = currentYear - 1
		}
		
		// Hide finished button by default
		self.finishedScheduleButton.isHidden = true
		
		// Show finished button if month is 4, 5, 6, 7, 8, 9, 10, or 11
		if currentMonthNumber < 4 || currentMonthNumber > 11
		{
			let attributedString = NSMutableAttributedString(string: "Sweeping has ended for \(currentYear). Check back next spring for the new schedule and to set up your notifications.")
			self.finishedScheduleButton.setAttributedTitle(attributedString, for: .normal)
			self.finishedScheduleButton.isHidden = false
		}
	}

	// Add annotation when Chicago map is tapped
	@objc func addDroppedPin(gesture: UIGestureRecognizer) {
		
		if gesture.state == .ended {
			
			// Select drop pin in segmented control
			searchTypeSegment.selectedSegmentIndex = 0
			
			// Stop updating location if user drops pin
			locationManager.stopUpdatingLocation()
			
			// Get coordinates from dropped pin
			let point = gesture.location(in: chicagoMapView)
			let coordinate = chicagoMapView.convert(point, toCoordinateFrom: chicagoMapView)
			let location: CLLocation =  CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
			
			// Save default lat and long to be use when user re-opens app
			defaults.set(coordinate.latitude, forKey: "defaultLatitude")
			defaults.set(coordinate.longitude, forKey: "defaultLongitude")
			
			// Get address from lat and long
			getAddressFromCoordinates(location)
			
			// Create annotation
			let annotation = MKPointAnnotation()
			annotation.coordinate = coordinate
			
			// Add annotation to map
			chicagoMapView.removeAnnotations(chicagoMapView.annotations)
			chicagoMapView.addAnnotation(annotation)
			
		}
	}
    
	// Search for schedule when search button is tapped
    func searchForSchedule(_ address: String) {
        
		// Clear all months and polygons so there are no duplicates
        self.schedule.months.removeAll()
        self.schedule.polygonCoordinates.removeAll()
        
        print("searchForSchedule address: \(address)")
        
        self.schedule.address = address
        
        // Get coordinates from address
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            
			// No internet connection will cause an error
            if error != nil {
                self.common.showAlert(self.common.constants.errorTitle, "You must be connected to the Internet to find your sweep area.")
                return
            }
            
            if placemarks != nil {
            
				// Get first placemark in list
                let placemark = placemarks?.first
                
				// Set schedule location coordinates
                var coordinates = CLLocationCoordinate2D()
                coordinates.latitude = placemark?.location?.coordinate.latitude ?? 0
                coordinates.longitude = placemark?.location?.coordinate.longitude ?? 0
                self.schedule.locationCoordinate = coordinates
                
				// Set default lat and long to be used when user re-opens the app
                defaults.set(placemark?.location?.coordinate.latitude, forKey: "defaultLatitude")
                defaults.set(placemark?.location?.coordinate.longitude, forKey: "defaultLongitude")
                
                print("searchForSchedule latitude: \(self.schedule.locationCoordinate.latitude)")
                print("searchForSchedule longitude: \(self.schedule.locationCoordinate.longitude)")
                
				print("searchForSchedule geom: \(self.common.the_geom())")
				print("searchForSchedule ward dataset: \(self.common.wardDataset())")
				
				// Get ward and section
				
				let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
                let wardQuery = wardClient.query(dataset: self.common.wardDataset())
                    .filter("intersects(\(self.common.the_geom()),'POINT(\(self.schedule.locationCoordinate.longitude) \(self.schedule.locationCoordinate.latitude))')")
					.limit(1)
                
                wardQuery.get { res in
                    switch res {
                    case .dataset (let data):
                        
                        if data.count > 0 {
                            
							// Get values from json query
                            let ward = data[0][self.common.ward()] as? String ?? ""
                            let section = data[0][self.common.section()] as? String ?? ""
                            let the_geom = data[0][self.common.the_geom()] as? [String: Any] ?? [:]
                            let coordinatesWrapper = the_geom[self.common.coordinates()] as? NSMutableArray
                            let coordinatesArray = coordinatesWrapper?[0] as? [[NSMutableArray]]
                            
							print("searchForSchedule ward: \(ward)")
							print("searchForSchedule section: \(section)")
							
							// Set default polygon array to be used on all the views
                            defaults.set(coordinatesArray, forKey: "defaultCoordinatesArray")
                            
							// Loop through coordinates array and add them to schedule
                            for(_, coordinate) in coordinatesArray!.enumerated() {
                                
                                for item in coordinate {
                                    
                                    var coordinate = CLLocationCoordinate2D()
                                    coordinate.longitude = item[0] as? Double ?? 0
                                    coordinate.latitude = item[1] as? Double ?? 0
                                    
                                    self.schedule.polygonCoordinates.append(coordinate)
                                    
                                }
                            }
                            
                            self.schedule.ward = ward
                            self.schedule.section = String(section).trimmingCharacters(in: .whitespaces)
                            
							// If there are multiple sections then segue to select section view
                            if self.schedule.section.isEmpty {
                                self.performSegue(withIdentifier: "selectSectionSegue", sender: self)
                                return
                            }
                            
                            // Get sweep months and days
                            
                            let scheduleQuery = wardClient.query(dataset: self.common.scheduleDataset())
								.filter("\(self.common.ward()) = '\(ward)' \(section != "" ? "AND \(self.common.section()) = '\(section)'" : "") ")
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        // Populate schedule model to be used on schedule view
                                        
                                        for (_, item) in data.enumerated() {
                                            
											// Get values from json call
                                            let monthName = item[self.common.month_name()] as? String ?? ""
                                            let monthNumber = item[self.common.month_number()] as? String ?? ""
                                            let dates = item[self.common.dates()] as? String ?? ""
                                            let datesArray = dates.components(separatedBy: ",")
                                            
                                            print("searchForSchedule month name: \(monthName)")
                                            print("searchForSchedule dates: \(datesArray)")
                                            
                                            let month = MonthModel()
                                            month.name = monthName
                                            month.number = monthNumber
                                            
											// Loop through dates and add them to month
                                            for day in datesArray {
                                                
                                                print("searchForSchedule date: \(day)")
                                                
                                                if !day.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                    
                                                    let date = DateModel()
                                                    date.date = Int(day) ?? 0
                                                    
                                                    if !month.dates.contains(where: { $0.date == Int(day) ?? 0}) {
                                                        month.dates.append(date)
                                                    }
                                                }
                                            }
                                            
											// Add month to schedule
                                            self.schedule.months.append(month)
                                            
                                        }
                                        
										// Segue to schedule view
                                        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
                                            destinationViewController.schedule = self.schedule
                                            self.navigationController?.pushViewController(destinationViewController, animated: true)
                                        }
                                
                                    }
                                case .error (let err):
                                    print("searchForSchedule Unable to get schedule data from the City of Chicago: \(err.localizedDescription)")
                                    self.common.showAlert(self.common.constants.errorTitle, "Unable to get schedule data from the City of Chicago")
                                }
                            }
                        }
                        else {
                            self.common.showAlert(self.common.constants.errorTitle, self.common.constants.notFound)
                        }
                    case .error (let err):
                        print("searchForSchedule Unable to get ward data from the City of Chicago: \(err.localizedDescription)")
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
		
		// Get address from schedule location coordinates
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
				
				// No internet connection will cause an error
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
                            
							// Get first placemark in list
                            let placemark = placemarks![0]
                            
							// Create address string by combining placemark value
                            if placemark.subThoroughfare != nil {
                                address = address + placemark.subThoroughfare! + " "
                            }
                            if placemark.thoroughfare != nil {
                                address = address + placemark.thoroughfare! + ", "
                            }
                            if placemark.locality != nil {
                                address = address + placemark.locality! + " "
                            }
                            if placemark.postalCode != nil {
                                address = address + placemark.postalCode! + " "
                            }
                            
							// Save address to global variable and address text box
                            self.addressFromCoordinates = address.trimmingCharacters(in: .whitespaces)
                            self.addressTextField.text = self.addressFromCoordinates
							
							// Save default address to be use when user re-opens app
                            defaults.set(self.addressFromCoordinates, forKey: "defaultAddress")
                            
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
		
		let addressFromDefaults = self.common.defaultAddress()
		let longitudeFromDefaults = self.common.defaultLongitude()
		let latitudeFromDefaults = self.common.defaultLatitude()
		
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
			
			print("Drop pin selected and stopped updating location")
			
		}
		else if searchTypeSegment.selectedSegmentIndex == 1 {
			
			print("Use my location selected")
			
			// Request location access. If access granted, start updating location and update map
			locationManager.requestWhenInUseAuthorization()
			
			print("Requested location access")
			
			if CLLocationManager.locationServicesEnabled() {
				locationManager.delegate = self
				locationManager.desiredAccuracy = kCLLocationAccuracyBest
				locationManager.startUpdatingLocation()
				print("Location services enabled and started updating location")
			}
			else {
				print("Location services are not enabled")
			}
		}
		else if searchTypeSegment.selectedSegmentIndex == 2 {
			
			print("Enter address selected and stopped updating location")
			
			// Stop updating location if user selects "enter address"
			locationManager.stopUpdatingLocation()
		}
	}
	
	// Search address button is tapped
	@IBAction func searchAddressTapped(_ sender: Any) {
		
		print("Find schedule pressed")

		// Add haptic feedback
		let generator = UISelectionFeedbackGenerator()
		generator.prepare()
		generator.selectionChanged()
		
		// Stop updating user's location to save battery
		locationManager.stopUpdatingLocation()
		
		print("Stopped updating location")
		
		// Get address from text field for searching
		var address = addressTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
		
		// Add "Chicago" to address if it doesn't contain it to help find address
		if !address.lowercased().contains("chicago") && !address.isEmpty {
			address = address + " Chicago"
		}
		
		// Alert user if they didn't enter an address
		if address.isEmpty {
			self.common.showAlert("Address cannot be blank", "")
			//toast.toast("Address cannot be blank")
			return
		}
		
		// Set default address to be used when app is re-opened
		defaults.set(address, forKey: "defaultAddress")
		
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
            defaults.set(location.coordinate.latitude, forKey: "defaultLatitude")
            defaults.set(location.coordinate.longitude, forKey: "defaultLongitude")
            
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
		
		// Make enter key close keyboard
		self.addressTextField.delegate = self
        
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
        self.common.styleButton(finishedScheduleButton, "ended", "BF1A2F")

    }
}

