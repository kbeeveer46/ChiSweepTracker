import UIKit
import CoreLocation
import MapKit
import Firebase

class SearchViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate {
    
	// Controls
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var searchAddressButton: UIButton!
	@IBOutlet weak var chicagoMapViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var chicagoMapView: MKMapView!
    @IBOutlet weak var searchTypeSegment: UISegmentedControl!
	@IBOutlet weak var searchStackView: UIStackView!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var messageCardView: CardView!
	
	// Classes
    let schedule = ScheduleModel()
    let common = Common()
    
	// Shared
	let locationManager = CLLocationManager()
    var addressFromTextField = ""
    var addressFromCoordinates = ""
	let currentDay = Calendar.current.component(.day, from: Date())
	let currentMonth = Calendar.current.component(.month, from: Date())
	let currentYear = Calendar.current.component(.year, from: Date())
    
	// MARK: Methods
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		// Show finished schedule button if month is < 4 or greater than 11
		self.showStatusMessage()
		
		// Load map with user default lat and long or Chicago
		self.loadSearchMap()
		
		// Style controls
		self.styleControls()
		
		// Initialize controls per device
		self.initializeControlsPerDevice()
		
	}
	
	func initializeControlsPerDevice() {
		
		switch UIDevice().type {
		case .iPhoneSE:
			chicagoMapViewHeightConstraint.constant = 175
			searchStackView.spacing = 9
			searchTypeSegment.setTitle("My Location", forSegmentAt: 2)
		default:
			break
		}
	}
	
	// Show finished schedule button if the current month is less thatn 4 (April) or greater than 11 (November)
	func showStatusMessage() {
		
		if currentMonth > 11 {
			
			self.messageLabel.text = self.common.constants.finishedScheduleMessage.replacingOccurrences(of: "_currentYear_", with: "\(currentYear)")
		
		}
		else if currentMonth < 4 {

			// Show begin schedule message along with the amount of days until the begin date
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "M/dd/yyyy"
			let start = dateFormatter.date(from: "\(currentMonth)/\(currentDay)/\(currentYear)")!
			let end = dateFormatter.date(from: "4/1/\(currentYear)")!
			let diff = Date.daysBetween(start: start, end: end)
			
			self.messageLabel.text = self.common.constants.beginScheduleMessage.replacingOccurrences(of: "_amount_", with: "\(diff)")
		}
		else {
			
			if self.common.favoriteAddress() != "" {
				getNextSweepingDate()
			}
			else {
				self.messageCardView.isHidden = true
			}
		}
	}
	
	func getNextSweepingDate(_ count: Int = 0) {

		var foundNextSweepingDay = false
		var nextSweepingDay = 0
		var nextSweepingMonth = 0
		
		self.messageCardView.isHidden = true
		
		// Create SODA client using domain and token
		let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
		
		// Query SODA API to get months and days
		let scheduleQuery = wardClient.query(dataset: self.common.scheduleDataset())
			.filter("\(self.common.wardTitle()) = '\(self.common.favoriteWard())' AND \(self.common.sectionTitle()) = '\(self.common.favoriteSection())' AND \(self.common.monthNumberTitle()) >= '\(currentMonth)'")
			.orderAscending(self.common.monthNumberTitle())
		
		scheduleQuery.get { res in
			switch res {
			case .dataset (let data):
				
				if data.count > 0 {
					
					// Loop through months
					for (_, item) in data.enumerated() {
						
						let monthNumber = item[self.common.monthNumberTitle()] as? String ?? ""
						let dates = item[self.common.dates()] as? String ?? ""
						let datesArray = dates.components(separatedBy: ",").sorted {$0.localizedStandardCompare($1) == .orderedAscending}
						
						if (Int(monthNumber) == (self.currentMonth + count)) {
							
							// Loop through dates
							for day in datesArray {
															
								if !day.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
									
									if count == 0 {
										
										if Int(day)! >= self.currentDay {
											
											nextSweepingDay = Int(day)!
											nextSweepingMonth = Int(monthNumber)!
											
											foundNextSweepingDay = true
											break
											
										}
									}
									else {
										nextSweepingDay = Int(day)!
										nextSweepingMonth = Int(monthNumber)!
										
										foundNextSweepingDay = true
										break
									}
								}
							}
							if foundNextSweepingDay {
								break
							}
						}
					}
					
					if foundNextSweepingDay {
						DispatchQueue.main.async {
							self.messageCardView.isHidden = false
							self.messageLabel.text = "Your next sweeping is on \(nextSweepingMonth)/\(nextSweepingDay)/\(self.currentYear)"
						}
					}
					
					if foundNextSweepingDay == false && count <= 7 {
						self.getNextSweepingDate(count + 1)
					}
				}
			case .error (let err):
				print("getNextSweepingDate error: \(err.localizedDescription)")
			}
		}
	}

	// Add annotation when Chicago map is tapped
	@objc func addDroppedPin(gesture: UIGestureRecognizer) {
		
		if gesture.state == .ended {
			
			// Change segmented control to drop pin
			searchTypeSegment.selectedSegmentIndex = 1
			
			// Stop updating location if user drops pin
			locationManager.stopUpdatingLocation()
			
			// Create point from dropped pin
			let point = gesture.location(in: chicagoMapView)
			
			// Get coordinates from point
			let coordinate = chicagoMapView.convert(point, toCoordinateFrom: chicagoMapView)
			
			// Create location from coordinates
			let location: CLLocation =  CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
			
			// Create map span from coordinates
			let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
			
			// Create map region from spam
			let region = MKCoordinateRegion(center: location.coordinate, span: span)
			
			// Get address from lat and long
			getAddressFromCoordinates(location)
			
			// Create annotation
			let annotation = CustomAnnotation()
			annotation.customImageName = "pin-address"
			annotation.coordinate = location.coordinate

			// Add annotation to map
			chicagoMapView.removeAnnotations(chicagoMapView.annotations)
			chicagoMapView.addAnnotation(annotation)
			
			// Set map region
			chicagoMapView.setRegion(region, animated: true)
			
		}
	}
    
	// Search for schedule when search button is tapped
    func searchForSchedule(_ address: String) {
        
		// Clear all months and polygons so there are no duplicates
        self.schedule.months.removeAll()
        self.schedule.polygonCoordinates.removeAll()
        
        //print("searchForSchedule address: \(address)")
        
		// Set schedule address
        self.schedule.address = address
        
        // Get coordinates from address
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            
			// No internet connection will cause an error
            if error != nil {
				self.common.showAlert(self.common.constants.errorTitle, self.common.constants.noInternetConnectionSearchMessage)
                return
            }
            
            if placemarks != nil {
            
				// Get first placemark in list
                let placemark = placemarks?.first
				
				// Create coorindates from placemark
                var coordinates = CLLocationCoordinate2D()
                coordinates.latitude = placemark?.location?.coordinate.latitude ?? 0
                coordinates.longitude = placemark?.location?.coordinate.longitude ?? 0
				
				// Set schedule location coordinates
                self.schedule.locationCoordinate = coordinates
                
				// Set default lat and long to be used when user re-opens the app
                defaults.set(placemark?.location?.coordinate.latitude, forKey: "defaultLatitude")
                defaults.set(placemark?.location?.coordinate.longitude, forKey: "defaultLongitude")
                
                //print("searchForSchedule latitude: \(self.schedule.locationCoordinate.latitude)")
                //print("searchForSchedule longitude: \(self.schedule.locationCoordinate.longitude)")
                
				//print("searchForSchedule geom: \(self.common.geomTitle())")
				//print("searchForSchedule ward dataset: \(self.common.wardDataset())")
				
				// Create SODA client using domain and token
				let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
                
				// Query SODA API to get ward and section
				let wardQuery = wardClient.query(dataset: self.common.wardDataset())
                    .filter("intersects(\(self.common.geomTitle()),'POINT(\(self.schedule.locationCoordinate.longitude) \(self.schedule.locationCoordinate.latitude))')")
					.limit(1)
                
                wardQuery.get { res in
                    switch res {
                    case .dataset (let data):
                        
                        if data.count > 0 {
                            
							// Get values from json query
                            let ward = data[0][self.common.wardTitle()] as? String ?? ""
                            let section = data[0][self.common.sectionTitle()] as? String ?? ""
                            let the_geom = data[0][self.common.geomTitle()] as? [String: Any] ?? [:]
                            let coordinatesWrapper = the_geom[self.common.coordinatesTitle()] as? NSMutableArray
                            let coordinatesArray = coordinatesWrapper?[0] as? [[NSMutableArray]]
                            
							//print("searchForSchedule ward: \(ward)")
							//print("searchForSchedule section: \(section)")
							
							// Set default polygon array to be used in all the views
                            defaults.set(coordinatesArray, forKey: "defaultCoordinatesArray")
                            
							// Loop through coordinates array
                            for(_, coordinate) in coordinatesArray!.enumerated() {
                                
								// Loop through each pair of coordinates
                                for item in coordinate {
                                    
									// Create coorindate from lat and long in array
                                    var coordinate = CLLocationCoordinate2D()
                                    coordinate.longitude = item[0] as? Double ?? 0
                                    coordinate.latitude = item[1] as? Double ?? 0
                                    
									// Add coordinates to schedule polygon coordinates
                                    self.schedule.polygonCoordinates.append(coordinate)
                                    
                                }
                            }
                            
							// Set schedule ward and section
                            self.schedule.ward = ward
                            self.schedule.section = String(section).trimmingCharacters(in: .whitespaces)
                            
							// If there are multiple sections then segue to select section view
                            if self.schedule.section.isEmpty {
								if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "SelectSectionViewController") as? SelectSectionViewController {
									destinationViewController.schedule = self.schedule
									self.navigationController?.pushViewController(destinationViewController, animated: true)
								}
                                return
                            }
                            
                            // Query SODA API to get months and days
							let scheduleQuery = wardClient.query(dataset: self.common.scheduleDataset())
								.filter("\(self.common.wardTitle()) = '\(ward)' \(section != "" ? "AND \(self.common.sectionTitle()) = '\(section)'" : "") ")
								.orderAscending(self.common.monthNumberTitle())
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        // Loop through months
                                        for (_, item) in data.enumerated() {
                                            
											// Get values from json data
                                            let monthName = item[self.common.monthNameTitle()] as? String ?? ""
                                            let monthNumber = item[self.common.monthNumberTitle()] as? String ?? ""
                                            let dates = item[self.common.dates()] as? String ?? ""
                                            let datesArray = dates.components(separatedBy: ",").sorted {$0.localizedStandardCompare($1) == .orderedAscending}
                                            
                                            //print("searchForSchedule month name: \(monthName)")
                                            //print("searchForSchedule dates: \(datesArray)")
                                            
											// Create month object
                                            let month = MonthModel()
                                            month.name = monthName
                                            month.number = monthNumber
                                            
											// Loop through dates
                                            for day in datesArray {
                                                
                                                //print("searchForSchedule date: \(day)")
                                                
												// Add date to month
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
                            self.common.showAlert("Could Not Find Schedule", "Address must reside in Chicago")
                        }
                    case .error (let err):
                        print("searchForSchedule Unable to get ward data from the City of Chicago: \(err.localizedDescription)")
                        self.common.showAlert(self.common.constants.errorTitle, "Unable to get ward data from the City of Chicago")
                    }
                }
            }
            else {
                self.common.showAlert("Could Not Find Schedule", "Address must reside in Chicago")
            }
        }
    }

    // Get address from coordinates after location manager retrieves user's location
    func getAddressFromCoordinates(_ location: CLLocation) {
        
        var address = ""
		
		// Create geocoder
        let geocoder = CLGeocoder()
		
		// Create location from CLLocation
        let location = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
		// Query geocoder to get address
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
				
			// No internet connection will cause an error
			if (error != nil) {
				
				print("getAddressFromCoordinates error: \(error!.localizedDescription)")
				
				// Stop updating location if user appears to be offline
				self.locationManager.stopUpdatingLocation()
				self.common.showAlert(self.common.constants.errorTitle, "You must be connected to the Internet to find your sweep area.")
				return
			}
			
			if placemarks != nil {
				
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
				
				// Save defaults to be use when user re-opens app
				defaults.set(self.addressFromCoordinates, forKey: "defaultAddress")
				defaults.set(location.coordinate.latitude, forKey: "defaultLatitude")
				defaults.set(location.coordinate.longitude, forKey: "defaultLongitude")
				
				//print("getAddressFromCoordinates: \(self.addressFromCoordinates)")
						
			}
        })
    }
	
	// If user disables location access prompt them to open the settings page to re-enable it
	func showLocationDisabledAlert() {
		
		// Create alert
		let alert = UIAlertController(title: "Location Access Disabled", message: "You will have to drop a pin on the map or enter your address", preferredStyle: .alert)
		
		// Cancel option
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
		
		// Yes option. Opening settings only available in iOS 10 and later
		if #available(iOS 10.0, *) {
			let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
				if let url = URL(string: UIApplication.openSettingsURLString) {
					UIApplication.shared.open(url, options: [:], completionHandler: nil)
				}
			}
			
			alert.addAction(openAction)
		}
		
		// Present alert
		self.present(alert, animated: true, completion: nil)
	}
	
	// Load map using use default values or a generic map of Chicago
	func loadSearchMap() {
		
		// Set required properties for map
		chicagoMapView.delegate = self
		
		// Get values from defaults
		let addressFromDefaults = self.common.defaultAddress()
		let longitudeFromDefaults = self.common.defaultLongitude()
		let latitudeFromDefaults = self.common.defaultLatitude()
		
		//print("Default address: \(addressFromDefaults)")
		//print("Default longitude: \(longitudeFromDefaults)")
		//print("Default latitude: \(latitudeFromDefaults)")
		
		// Put address in address text box
		addressTextField.text = addressFromDefaults
		
		// Create tap gesture to allow user to tap on map to drop a pin
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addDroppedPin(gesture:)))
		
		// Add tap gesture to map
		chicagoMapView.addGestureRecognizer(tapGesture)
		
		// If user has previously searched for an address use those defaults to load the map
		// Load default map of the entire city of Chicago if no defaults are set
		if longitudeFromDefaults != 0 && latitudeFromDefaults != 0 {
			
			// Create location from coordinates
			let location: CLLocation = CLLocation(latitude: latitudeFromDefaults, longitude: longitudeFromDefaults)
			
			// Create map annotation
			let annotation = CustomAnnotation()
			annotation.customImageName = "pin-address"
			annotation.coordinate = location.coordinate
			//annotation.title = addressFromDefaults
			
			// Create map span from coordinates
			let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
			
			// Create map region from spam
			let region = MKCoordinateRegion(center: location.coordinate, span: span)
			
			// Add annotation to map
			chicagoMapView.removeAnnotations(chicagoMapView.annotations)
			chicagoMapView.addAnnotation(annotation)
			
			// Set map region
			chicagoMapView.setRegion(region, animated: false)
		}
		else {
			
			// Create map span using Chicago
			let span = MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45)
			
			// Create coordinates using Chicago
			let chicagoCoordinate = CLLocationCoordinate2D(latitude: 41.846647, longitude: -87.629576)
			
			// Create map region from span and coordinates
			let region = MKCoordinateRegion(center: chicagoCoordinate, span: span)
			
			// Set map region
			chicagoMapView.setRegion(region, animated: false)
		}
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		let reuseIdentifier = "pin"
		
		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
		
		if annotationView == nil {
			
			annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
			annotationView?.canShowCallout = true
			
		}
		else {
			
			annotationView?.annotation = annotation
			
		}
		
		let customPointAnnotation = annotation as! CustomAnnotation
		annotationView?.image = UIImage(named: customPointAnnotation.customImageName)
		annotationView?.centerOffset = CGPoint(x: 0, y: -(annotationView?.image!.size.height)!/2)
		annotationView?.subviews.forEach({ $0.removeFromSuperview() })
		
		return annotationView
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
		
		// Enter address
		if searchTypeSegment.selectedSegmentIndex == 0 {
			
			//print("Enter address selected and stopped updating location")
			
			// Clear search text box
			addressTextField.text = ""
			
			// Stop updating location if user selects "enter address"
			locationManager.stopUpdatingLocation()
			
		}
		// Drop pin
		else if searchTypeSegment.selectedSegmentIndex == 1 {
			
			// Stop updating location if user selects "drop pin"
			locationManager.stopUpdatingLocation()
			
			//print("Drop pin selected and stopped updating location")
			
		}
		// Use my location
		else if searchTypeSegment.selectedSegmentIndex == 2 {
			
			//print("Use my location selected")
			
			// Request location access. If access granted, start updating location and update map
			locationManager.requestWhenInUseAuthorization()
			
			//print("Requested location access")
			
			// Check if location services in enabled
			if CLLocationManager.locationServicesEnabled() {
				
				// Set location manager properties
				locationManager.delegate = self
				locationManager.desiredAccuracy = kCLLocationAccuracyBest

				// Start getting user's location
				locationManager.startUpdatingLocation()
				
				//print("Location services enabled and started updating location")
			}
			else {
				//print("Location services are not enabled")
			}
		}
	}
	
	// Search address button is tapped
	@IBAction func searchAddressTapped(_ sender: Any) {
		
		//print("Find schedule pressed")

		// Add haptic feedback
		let generator = UISelectionFeedbackGenerator()
		generator.prepare()
		generator.selectionChanged()
		
		// Stop updating user's location to save battery
		locationManager.stopUpdatingLocation()
		
		//print("Stopped updating location")
		
		// Get address from text field for searching
		var address = addressTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
		
		// Add "Chicago" to address if it doesn't contain it to help find address
		if !address.lowercased().contains("chicago") && !address.isEmpty {
			address = address + " Chicago"
		}
		
		// Alert user if they didn't enter an address
		if address.isEmpty {
			self.common.showAlert("Address cannot be blank", "")
			return
		}
		
		// Set default address to be used when app is re-opened
		defaults.set(address, forKey: "defaultAddress")
		
		// Find address and go to select section view or schedule view
		self.searchForSchedule(address)
		
	}
	
    // MARK: Location Manager
    
    // Get user's last location and get address from coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
		// Get last location
        if let location = locations.last {
            
			// Get address from coordinates to be used to fill in address text field and for schedule model
            getAddressFromCoordinates(location)
            
			// Create coordinate from location coordinates
            var coordinates = CLLocationCoordinate2D()
            coordinates.latitude = location.coordinate.latitude
            coordinates.longitude = location.coordinate.longitude
            
			// Create map annotation
			let annotation = CustomAnnotation()
			annotation.customImageName = "pin-address"
			annotation.coordinate = location.coordinate
			
			// Create map span
            let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
			
			// Create map region from coordinates and span
            let region = MKCoordinateRegion(center: coordinates, span: span)
            
			// Set map region
            chicagoMapView.setRegion(region, animated: true)
			
			// Add annotation to map
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
		self.tabBarController?.navigationItem.title = "Search For Sweep Schedule"
		
        // Style segmented search type control with blue background on selected item
        if #available(iOS 13.0, *) {
            self.searchTypeSegment.selectedSegmentTintColor = UIColor(red: 1.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            let fontAttribute = [NSAttributedString.Key.foregroundColor: UIColor.white]
            searchTypeSegment.setTitleTextAttributes(fontAttribute, for: .selected)
        }
        
        // Style and add images to buttons
        self.common.styleButton(searchAddressButton, "search_circle", "007AFF")

    }
}

