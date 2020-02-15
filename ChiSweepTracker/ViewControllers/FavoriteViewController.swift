import UIKit
import UserNotifications
import CoreLocation
import MapKit
import THLabel

class FavoriteViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, MKMapViewDelegate {
    
	// Controls
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
	@IBOutlet weak var onPicker: UIPickerView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var favoriteMapView: MKMapView!
	@IBOutlet weak var favoriteMapHeighConstraint: NSLayoutConstraint!
	@IBOutlet weak var infoLabel: UILabel!
	
	// Classes
    let common = Common()
    var schedule = ScheduleModel()
	
	// Shared
    let whenData = ["Day Of Sweep", "1 Day Prior", "2 Days Prior", "3 Days Prior", "4 Days Prior", "5 Days Prior", "6 Days Prior", "7 Days Prior"]
	var relocatedVehicleCount = 0
	var divvyStationCount = 0
	
	// MARK: Methods
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
		// Fill in notification form values with user defaults
		self.loadNotificationControlValues()
    
		// Load map using user favorite lat, long, and polygon coorndinates
		self.loadFavoriteMap()
		
		// Initialize controls per device
		self.initializeControlsPerDevice()
        
    }
	
	// Change constraints and sizes per device
	func initializeControlsPerDevice() {
		
		switch UIDevice().type {
		case .iPhoneSE:
			infoLabel.font = .systemFont(ofSize: 11)
			favoriteMapHeighConstraint.constant = 150
		default:
			break
		}
	}
	
	// Go to schedule page when top left schedule button is clicked
    @objc func viewSchedule() {
        
        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
            destinationViewController.schedule = self.schedule
            self.navigationController?.pushViewController(destinationViewController, animated: true)
        }
    }
    
	// Load map with default lat, long, and polygon coordinates or load Chicago map
    func loadFavoriteMap() {
        
		// Set required properties for map
        favoriteMapView.delegate = self
        
		// Get favorite values from defaults
		let favoriteAddress = self.common.favoriteAddress()
		let favoriteWard = self.common.favoriteWard()
		let favoriteSection = self.common.favoriteSection()
		let favoriteLongitude = self.common.favoriteLongitude()
		let favoriteLatitude = self.common.favoriteLatitude()
		let favoriteCoordinatesArray = self.common.favoriteCoordinatesArray()
        var mapOverlayCoordinates = [CLLocationCoordinate2D]()
        
        if favoriteLongitude != 0 && favoriteLatitude != 0 {
            
			// Loop through favorite coordinates array
			if favoriteCoordinatesArray.count > 0 {
				for(_, coordinate) in favoriteCoordinatesArray.enumerated() {
					for item in coordinate {
						
						// Add coordinates to array for map
						var coordinate = CLLocationCoordinate2D()
						coordinate.longitude = item[0] as? Double ?? 0
						coordinate.latitude = item[1] as? Double ?? 0
						mapOverlayCoordinates.append(coordinate)
					}
				}
			}
			
			// Create polygons
			let polygons = MKPolygon(coordinates: mapOverlayCoordinates, count: mapOverlayCoordinates.count)
			
			// Add polygons to map
			favoriteMapView.removeOverlays(favoriteMapView.overlays)
			favoriteMapView.addOverlay(polygons)

			// Create location using lat and long
            let location: CLLocation = CLLocation(latitude: favoriteLatitude, longitude: favoriteLongitude)

			// Create annotation using location coordinate
			let annotation = CustomAnnotation()
			annotation.customImageName = "pin-red"
			annotation.coordinate = location.coordinate
			annotation.title = favoriteAddress
			annotation.subtitle = "Ward: \(favoriteWard) - Section: \(favoriteSection)"

			// Create map span
            let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
			
			// Create map region
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            
			// Add annoation to map
			favoriteMapView.removeAnnotations(favoriteMapView.annotations)
			let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "address")
			self.favoriteMapView.addAnnotation(annotationView.annotation!)
			
			// Set map region
            favoriteMapView.setRegion(region, animated: true)
			
			// Add Divvy stations to map
			addDivvyStationsToMap(location)
			
			// Ad relocated vehicles to map
			addRelocationVehiclesToMap(location)
			
        }
        else {
            
			// If there is no favorite then set the map to Chicago
			
			// Create map span
            let span = MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45)
			
			// Create map coordinates using Chicago
            let chicagoCoordinate = CLLocationCoordinate2D(latitude: 41.846647, longitude: -87.629576)
			
			// Create map region using coordinates and span
            let region = MKCoordinateRegion(center: chicagoCoordinate, span: span)
			
			// Set map region
            favoriteMapView.setRegion(region, animated: true)
            
        }
    }
	
	func addRelocationVehiclesToMap(_ favoriteLocation: CLLocation) {
	
		// Get show relocated vehicle setting from defaults
		let showTowedVehicles = self.common.showTowedVehicles()
		
		self.relocatedVehicleCount = 0
		
		// Show relocated vehicles if user has that option turned on
		if (showTowedVehicles) {
			
			// Create SODA client
			let relocatedClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
			
			// Create SODA query
			let relocatedQuery = relocatedClient.query(dataset: self.common.relocatedDataset()).limit(5000)
			
			relocatedQuery.get { res in
				switch res {
				case .dataset (let data):
					
					if data.count > 0 {
												
						// Loop through relocated vehicle data
						for (_, item) in data.enumerated() {
							
							// Get values for each relocated vehicle
							var relocatedDate = item[self.common.relocatedDateTitle()] as? String ?? ""
							let make = item[self.common.relocatedMakeTitle()] as? String ?? ""
							let color = item[self.common.relocatedColorTitle()] as? String ?? ""
							let plate = item[self.common.relocatedPlateTitle()] as? String ?? ""
							let state = item[self.common.relocatedStateTitle()] as? String ?? ""
							let relocatedToAddressNumber = item[self.common.relocatedToAddressNumberTitle()] as? String ?? ""
							let relocatedToDirection = item[self.common.relocatedToDirectionTitle()] as? String ?? ""
							let relocatedToStreet = item[self.common.relocatedToStreetTitle()] as? String ?? ""
							let relocatedReason = item[self.common.relocatedReasonTitle()] as? String ?? ""
							let relocatedFromLatitude = item[self.common.relocatedFromLatitudeTitle()] as? String ?? ""
							let relocatedFromLongitude = item[self.common.relocatedFromLongitudeTitle()] as? String ?? ""
							let relocatedFromAddressNumber = item[self.common.relocatedFromAddressNumberTitle()] as? String ?? ""
							let relocatedFromDirection = item[self.common.relocatedFromDirectionTitle()] as? String ?? ""
							let relocatedFromStreet = item[self.common.relocatedFromStreetTitle()] as? String ?? ""
							
							if (relocatedFromLatitude != "" && relocatedFromLongitude != "") {
							
								let relocatedLocation: CLLocation = CLLocation(latitude: Double(relocatedFromLatitude)!, longitude: Double(relocatedFromLongitude)!)
										
								// Get distance from favorite address to relocated vehicle
								let distance = relocatedLocation.distance(from: favoriteLocation)
								
								// Show relocated vehicle on map if distance is less than or equal to 300 meters
								if (distance <= 200) {
								
									self.relocatedVehicleCount += 1
									
									relocatedDate = Date.getFormattedDate(relocatedDate)
									
									// Create annotation for relocated location
									let relocatedAnnotation = CustomAnnotation()
									relocatedAnnotation.customImageName = "pin-orange"
									relocatedAnnotation.coordinate = relocatedLocation.coordinate
									relocatedAnnotation.subtitle = "Click on magnifying glass for more details" //"#:\(plate) State:\(state) Make:\(make) Color:\(color)"
									relocatedAnnotation.title = "Make: \(make) - Plate #: \(plate)" //"\(relocatedDate) To: \(relocatedToAddressNumber) \(relocatedToDirection) \(relocatedToStreet)"
									
									let relocatedVehicle = VehicleModel()
									relocatedVehicle.relocatedToAddress = "\(relocatedToAddressNumber) \(relocatedToDirection) \(relocatedToStreet)"
									relocatedVehicle.color = color
									relocatedVehicle.make = make
									relocatedVehicle.plate = plate
									relocatedVehicle.state = state
									relocatedVehicle.relocatedDate = relocatedDate
									relocatedVehicle.relocatedFromLatitude = relocatedFromLatitude
									relocatedVehicle.relocatedFromLongitude = relocatedFromLongitude
									relocatedVehicle.relocatedFromAddress = "\(relocatedFromAddressNumber) \(relocatedFromDirection) \(relocatedFromStreet)"
									relocatedVehicle.relocatedReason = relocatedReason
									relocatedAnnotation.relocatedVehicle = relocatedVehicle
									
									// Add annotation to map
									let relocatedAnnotationView = MKPinAnnotationView(annotation: relocatedAnnotation, reuseIdentifier: "relocated")
									self.favoriteMapView.addAnnotation(relocatedAnnotationView.annotation!)
								
								}
							}
						}
					}
					else {
						//self.common.showAlert("Search Completed", "No vehicles near your address have been relocated.\n\nHide relocated vehicles in the settings menu to stop seeing this message.")
					}
				case .error (let err):
					print((err as NSError).userInfo.debugDescription)
				}
			}
		}
	}
	
	func addDivvyStationsToMap(_ favoriteLocation: CLLocation) {
		
		// Get show Divvy station setting from defaults
		let showDivvyStations = self.common.showDivvyStations()
		
		self.divvyStationCount = 0
		
		// Show Divvy stations if user has that option turned on
		if (showDivvyStations) {
			
			// Create SODA client
			let divvyClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
			
			// Create SODA query
			let divvyQuery = divvyClient.query(dataset: self.common.divvyDataset())
			
			divvyQuery.get { res in
				switch res {
				case .dataset (let data):
					
					if data.count > 0 {
						
						// Loop through Divvy data
						for (_, item) in data.enumerated() {
							
							// Get values for each Divvy station
							let latitude = item["latitude"] as? String ?? ""
							let longitude = item["longitude"] as? String ?? ""
							let name = item["station_name"] as? String ?? ""
							let docksInService = item["docks_in_service"] as? String ?? ""
							let status = item["status"] as? String ?? ""
							
							if (latitude != "" && longitude != "") {
								
								// Create station location
								let stationLocation: CLLocation = CLLocation(latitude: Double(latitude)!, longitude: Double(longitude)!)
								
								// Get distance from favorite address to station
								let distance = stationLocation.distance(from: favoriteLocation)
								
								// Show station on map if distance is less than or equal to 300 meters
								if (distance <= 300) {
									
									self.divvyStationCount += 1
									
									// Create annotation for divvy station
									let divvyAnnotation = CustomAnnotation()
									divvyAnnotation.customImageName = "pin-blue"
									divvyAnnotation.coordinate = stationLocation.coordinate
									divvyAnnotation.title = name
									divvyAnnotation.subtitle = "Status: \(status) - Docks In Service: \(docksInService)"
									
									// Add annotation to map
									let divvyAnnotationView = MKPinAnnotationView(annotation: divvyAnnotation, reuseIdentifier: "divvy")
									self.favoriteMapView.addAnnotation(divvyAnnotationView.annotation!)
									
								}
							}
						}
					}
				case .error (let err):
					print((err as NSError).userInfo.debugDescription)
				}
			}
		}
	}
    
    @objc func openOptionsMenu() {
		
		// Add haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
		
		// Get values from defaults
		let showDivvyStations = self.common.showDivvyStations()
		let showTowedVehicles = self.common.showTowedVehicles()
        
		// Create options alert
		let optionsAlert = UIAlertController(title: nil, message: "Options", preferredStyle: .actionSheet)
		
		// Create remove favorite option for options alert
		let removeFavoriteAction = UIAlertAction(title: "Remove Favorite Address", style: .default, handler:{ action in
			
			// Create remove favorite alert
			let removeFavoriteAlert = UIAlertController(title: "Remove Favorite Address?", message: "You will no longer receive notifications", preferredStyle: .alert)
			
			// Create yes option for remove favorite alert
			let yesAction = UIAlertAction(title: "Yes", style: .default, handler:{ action in
			
				print("Deleted favorite address: \(self.common.favoriteAddress())")
				
				// Clear favorite default values
				defaults.set("", forKey: "favoriteAddress")
				defaults.set("", forKey: "favoriteWard")
				defaults.set("", forKey: "favoriteSection")
				defaults.set(0.0, forKey: "favoriteLongitude")
				defaults.set(0.0, forKey: "favoriteLatitude")
				defaults.set(nil, forKey: "favoriteCoordinatesArray")
				defaults.set(false, forKey: "notificationsToggled")
				
				// Delete future local iOS notifications
				UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
				
				// Unregister from Firebase Cloud Messaging notifications
				UIApplication.shared.unregisterForRemoteNotifications()
				
				print("Deleted user's local notifications")
				
				// If on a view with a tab control then use it to go to the search view
				self.tabBarController?.selectedIndex = 0
				
				// If not on a view with a tab control, use navigation controller to go to search view
				if self.tabBarController == nil {
					
					if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
						self.navigationController?.pushViewController(destinationViewController, animated: true)
					}
				}
				
			})
			yesAction.setValue(UIColor.red, forKey: "titleTextColor")
			
			// Create and add no option for remove favorite alert
			removeFavoriteAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
			
			// Add yes option to remove favorite alert
			removeFavoriteAlert.addAction(yesAction)
			
			// Present remove favorite alert
			self.present(removeFavoriteAlert, animated: true, completion: nil)
			
		})
		removeFavoriteAction.setValue(UIColor.red, forKey: "titleTextColor")
		
		// Create nearby Divvy stations options for alert
		if (showDivvyStations == false) {
			let showDivvyAction = UIAlertAction(title: "Show Nearby Divvy Stations", style: .default, handler:{ action in
				defaults.set(true, forKey: "showDivvyStations")
				self.loadFavoriteMap()
			})
			optionsAlert.addAction(showDivvyAction)
		}
		else {
			let hideDivvyAction = UIAlertAction(title: "Hide Nearby Divvy Stations (\(divvyStationCount))", style: .default, handler:{ action in
				defaults.set(false, forKey: "showDivvyStations")
				self.loadFavoriteMap()
			})
			optionsAlert.addAction(hideDivvyAction)
		}
		
		// Create nearby towed/relocated vehicle options for alert
		if (showTowedVehicles == false) {
			let showRelocatedAction = UIAlertAction(title: "Vehicle Missing? Show Relocated Vehicles", style: .default, handler:{ action in
				defaults.set(true, forKey: "showTowedVehicles")
				self.loadFavoriteMap()
			})
			optionsAlert.addAction(showRelocatedAction)
		}
		else {
			let hideRelocatedAction = UIAlertAction(title: "Hide Relocated Vehicles (\(relocatedVehicleCount))", style: .default, handler:{ action in
				defaults.set(false, forKey: "showTowedVehicles")
				self.loadFavoriteMap()
			})
			optionsAlert.addAction(hideRelocatedAction)
		}
		
		let showTowedAction = UIAlertAction(title: "Vehicle Missing? Search Towed Vehicles", style: .default, handler:{ action in
			
			// Segue to towed search view
			if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "TowedSearchViewController") as? TowedSearchViewController {
				//destinationViewController.schedule = self.schedule
				self.navigationController?.pushViewController(destinationViewController, animated: true)
			}
			
		})
		optionsAlert.addAction(showTowedAction)
		
		// Create cancel option for options alert
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		
		// Add options to options alert
		optionsAlert.addAction(cancelAction)
		optionsAlert.addAction(removeFavoriteAction)
        
		// Present options alert
        self.present(optionsAlert, animated: true, completion: nil)
        
    }
    
    @objc func timePickerChanged(picker: UIDatePicker) {
        
		// Save form values to defaults
        saveDefaultNotificationValues()
        
		// Update notifications when picker is changed
        if self.pushNotificationsSwitch.isOn {
            self.getSchedule(true)
        }
    }
    
    func loadNotificationControlValues() {
        
		// Set the title or else the title is used from another tab
		self.tabBarController?.navigationItem.title = "Favorite Address"
		
		// Set required properties for when picker
		self.onPicker.delegate = self
		self.onPicker.dataSource = self
		
		// Set values for when and time pickers
		let when = self.common.notificationWhen()
        let index = whenData.firstIndex(of: when) ?? 0
        let hour = self.common.notificationHour()
        let minute = self.common.notificationMinute()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        let date = dateFormatter.date(from: "\(hour):\(minute)")
        
        self.onPicker.selectRow(index, inComponent: 0, animated: false)
        self.timePicker.date = date!
        
        timePicker.addTarget(self, action: #selector(timePickerChanged(picker:)), for: .valueChanged)

		let favoriteAddress = self.common.favoriteAddress()
		let notificationsToggled = self.common.notificationsToggled()
		
		// Disable form depending if they have notifications toggled on or off
		if !favoriteAddress.isEmpty {
			
			// Get schedule so we have the most update to date version
			// Used to pass schedule model to schedule view
			self.getSchedule(false)
			
			self.pushNotificationsSwitch.isOn = notificationsToggled
			self.pushNotificationsSwitch.isUserInteractionEnabled = true
			self.onPicker.isUserInteractionEnabled = notificationsToggled
			self.timePicker.isUserInteractionEnabled = notificationsToggled
			
			self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "list"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(viewSchedule))
			self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(openOptionsMenu))
			
			if self.tabBarController == nil {
				//self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "list"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(viewSchedule))
				self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(openOptionsMenu))
			}
		}
		else {
			
			self.tabBarController?.navigationItem.title = "No Favorite Address Saved"
			
			self.pushNotificationsSwitch.isOn = false
			self.pushNotificationsSwitch.isUserInteractionEnabled = false
			self.onPicker.isUserInteractionEnabled = false
			self.timePicker.isUserInteractionEnabled = false
			
			self.tabBarController?.navigationItem.leftBarButtonItem = nil
			self.tabBarController?.navigationItem.rightBarButtonItem = nil
			
			if self.tabBarController == nil {
				self.navigationItem.leftBarButtonItem = nil
				self.navigationItem.rightBarButtonItem = nil
			}
		}
    }
    
	// Save form values to defaults
    func saveDefaultNotificationValues() {
        
        let time = self.timePicker.date
        let comp = Calendar.current.dateComponents([.hour, .minute], from: time)
        let hour = comp.hour!
        let minute = comp.minute!
        let when = self.whenData[self.onPicker.selectedRow(inComponent: 0)]
        
        defaults.set(when, forKey: "notificationWhen")
        defaults.set(hour, forKey: "notificationHour")
        defaults.set(minute, forKey: "notificationMinute")
        
    }
    
	// Populate schedule model and add notifications if applicable
	// useDefaultNotificationValues is set to true when running getSchedule from outside notifications view controller
	func getSchedule(_ registerForPushNotifications: Bool, _ useDefaultNotificationValues: Bool = false) {
        
		self.schedule.address = self.common.favoriteAddress()
		
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(self.schedule.address) { placemarks, error in
            
            if error != nil {
                
				print("getSchedule geocode error: \((error! as NSError).userInfo.debugDescription)")
				
				// Remove schedule button in the top left if there's an error getting the coordinates
				// If there's an error getting the coornidates then the schedule won't be populated correctly
				self.tabBarController?.navigationItem.leftBarButtonItem = nil
				
			}
            
            if placemarks != nil {
				
                let placemark = placemarks?.first
                
                var coordinates = CLLocationCoordinate2D()
                coordinates.latitude = placemark?.location?.coordinate.latitude ?? 0
                coordinates.longitude = placemark?.location?.coordinate.longitude ?? 0
                self.schedule.locationCoordinate = coordinates
                
                let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
                
                let wardQuery = wardClient.query(dataset: self.common.wardDataset())
                    .filter("intersects(\(self.common.geomTitle()),'POINT(\(self.schedule.locationCoordinate.longitude) \(self.schedule.locationCoordinate.latitude))')")
					.limit(1)
				
                wardQuery.get { res in
                    switch res {
                    case .dataset (let data):
                        
                        if data.count > 0 {
                            
                            let ward = data[0][self.common.wardTitle()] as? String ?? ""
                            let section = data[0][self.common.sectionTitle()] as? String ?? ""
                            let the_geom = data[0][self.common.geomTitle()] as? [String: Any] ?? [:]
                            let coordinatesWrapper = the_geom[self.common.coordinatesTitle()] as? NSMutableArray
                            let coordinatesArray = coordinatesWrapper?[0] as? [[NSMutableArray]]
                            
                            self.schedule.polygonCoordinates.removeAll()
                            
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
                            
                            if self.schedule.section.isEmpty {
								self.schedule.section = self.common.favoriteSection()
                            }
                            
                            let scheduleQuery = wardClient.query(dataset: self.common.scheduleDataset())
								.filter("\(self.common.wardTitle()) = '\(ward)' AND \(self.common.sectionTitle()) = '\(self.schedule.section)'")
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        self.schedule.months.removeAll()
                                        
                                        for (_, item) in data.enumerated() {
                                            
                                            let monthName = item[self.common.monthNameTitle()] as? String ?? ""
                                            let monthNumber = item[self.common.monthNumberTitle()] as? String ?? ""
                                            let dates = item[self.common.dates()] as? String ?? ""
                                            let datesArray = dates.components(separatedBy: ",")
                                            
											let month = MonthModel()
                                            month.name = monthName
                                            month.number = monthNumber
                                            
                                            for day in datesArray {
                                                
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
										
										// Show schedule button in the top left in case it was hidden when the user didn't have an Internet connection
										self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "list"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(self.viewSchedule))
                                        
                                        if registerForPushNotifications == true {
                                            
                                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
												granted, error in
                                            
                                                print("requestAuthorization granted: \(granted)")
                                                
                                                if granted == false {
                                                    
                                                    // User's notifications are disabled in settings. Prompt them to open settings
                                                    DispatchQueue.main.async {
                                                    
                                                        let alertController = UIAlertController (title: "Notifications Are Disabled", message: "Do you want to go to settings and turn notifications back on?", preferredStyle: .alert)

                                                        let settingsAction = UIAlertAction(title: "Yes", style: .default) { (_) -> Void in

                                                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                                                return
                                                            }

                                                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                                                    print("User opened the settings page")
                                                                })
                                                            }
                                                        }
                                                        alertController.addAction(settingsAction)
                                                        
                                                        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler:{ action in
                                                            
															print("User declined to go to settings page")
															
                                                            self.pushNotificationsSwitch.isOn = false
                                                            self.timePicker.isUserInteractionEnabled = false
                                                            self.onPicker.isUserInteractionEnabled = false
                                                            defaults.set(false, forKey: "notificationsToggled")
                                                            
                                                        })
                                                        alertController.addAction(cancelAction)

                                                        self.present(alertController, animated: true, completion: nil)
                                                    }
                                                }
                                                else {
													
													// Clear current notifications and re-add them in case they changed
													UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
													
													print("Deleted user's local notifications")
													
													 // Do not remove DispatchQueue
                                                     DispatchQueue.main.async {
														
														#if DEBUG
														self.sendTestNotifications()
														#endif
                                                    
                                                        let center = UNUserNotificationCenter.current()
														let calendar = Calendar.current
														let currentYear = self.common.latestAppVersion() 
														let notificationWhenDefault = self.common.notificationWhen()
														let notificationHourDefault = self.common.notificationHour()
														let notificationMinuteDefault = self.common.notificationMinute()
														var hour = 0
														var minute = 0
														var when = ""
														
														if useDefaultNotificationValues == true {
															hour = notificationHourDefault
															minute = notificationMinuteDefault
															when = notificationWhenDefault
														}
														else {
															let time = self.timePicker.date
															let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
															hour = timeComponents.hour!
															minute = timeComponents.minute!
															when = self.whenData[self.onPicker.selectedRow(inComponent: 0)]
														}
														
                                                        for monthInSchedule in self.schedule.months {
                                                            
                                                            for dayInMonth in monthInSchedule.dates {
                                                                
																let dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current, year: currentYear, month: Int(monthInSchedule.number), day: dayInMonth.date, hour: hour, minute: minute, second: 0)
																var date = calendar.date(from: dateComponents)
																
                                                                switch when {
                                                                case "1 Day Prior":
                                                                    date = calendar.date(byAdding: .day, value: -1, to: date!)
                                                                case "2 Days Prior":
                                                                    date = calendar.date(byAdding: .day, value: -2, to: date!)
                                                                case "3 Days Prior":
                                                                    date = calendar.date(byAdding: .day, value: -3, to: date!)
                                                                case "4 Days Prior":
                                                                    date = calendar.date(byAdding: .day, value: -4, to: date!)
                                                                case "5 Days Prior":
                                                                    date = calendar.date(byAdding: .day, value: -5, to: date!)
                                                                case "6 Days Prior":
                                                                    date = calendar.date(byAdding: .day, value: -6, to: date!)
                                                                case "7 Days Prior":
                                                                    date = calendar.date(byAdding: .day, value: -7, to: date!)
                                                                default:
                                                                    break
                                                                }
																
																// Create notificaton trigger
																let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: date!)
                                                                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
                                                                
																// Create notification contents
                                                                let content = UNMutableNotificationContent()
                                                                content.title = "Street Sweeping \(monthInSchedule.number)/\(dayInMonth.date)"
                                                                content.body = "Check your neighborhood for signage and move your vehicle to avoid tickets."
                                                                let soundName = UNNotificationSoundName("notification.m4r")
																content.sound = UNNotificationSound(named: soundName)
                                                                content.badge = 1
																//content.userInfo = ["address":self.common.favoriteAddress()]

																// Create notificaton identifier
																let identifier = "LocalNotification-\(triggerComponents.month!)-\(triggerComponents.day!)-\(triggerComponents.hour!)-\(triggerComponents.minute!)-\(triggerComponents.second!)"

																// Create notification request
                                                                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                                                                
																// Add notification
																center.add(request, withCompletionHandler: { (error) in
                                                                    if let error = error {
                                                                        print("Error adding notification: \(error.localizedDescription)")
                                                                    }
                                                                    else {
                                                                        print("Notification added: \(date!.description(with: Locale.current))")
                                                                    }
                                                                })
                                                            }
                                                        }
														
														// Set the last year when notifications were updated.
														// Use the value to alert them if they loaded the app after a new year came out
														let notificationsYear = self.common.notificationsYear()
														let latestAppVersion = self.common.latestAppVersion()
														if notificationsYear < latestAppVersion {
															self.common.showAlert("Notifications Updated", "Chicago has released the \(latestAppVersion) schedule and your push notifications have been automatically updated.")
														}
														defaults.set(latestAppVersion, forKey: "notificationsYear")
														
														// Set the latest dataset version when notifications were updated
														// Use the value to alert them if they loaded the app after Chicago changed the schedule
														let latestDatasetVersion = self.common.latestDatasetVersion()
														let userDatasetVersion = self.common.userDatasetVersion()
														if userDatasetVersion < latestDatasetVersion {
															self.common.showAlert("Notifications Updated", "Chicago has changed the \(latestAppVersion) schedule and your push notifications have been automatically updated.")
														}
														defaults.set(latestDatasetVersion, forKey: "userDatasetVersion")
													}
                                                }
                                            }
                                        }
                                    }
                                case .error (let err):
                                    print((err as NSError).userInfo.debugDescription)
									self.tabBarController?.navigationItem.leftBarButtonItem = nil
                                }
                            }
                        }
                        else {
                            print(self.common.constants.notFound)
							self.tabBarController?.navigationItem.leftBarButtonItem = nil
                        }
                    case .error (let err):
                        print((err as NSError).userInfo.debugDescription)
						self.tabBarController?.navigationItem.leftBarButtonItem = nil
                    }
                }
            }
            else {
                print(self.common.constants.notFound)
				self.tabBarController?.navigationItem.leftBarButtonItem = nil
            }
        }
    }
	
	func sendTestNotifications() {
		
		// Get notification center
		let center = UNUserNotificationCenter.current()
		
		// Set notification date and time
		let calendar = Calendar.current
		let notificationDate = calendar.date(byAdding: .second, value: 15, to: Date())
		
		// Create notification trigger components
		let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: notificationDate!)
		
		// Create notification trigger
		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
		
		// Get notification sound
		let soundName = UNNotificationSoundName("notification.m4r")
		
		// Create notification content
		let content = UNMutableNotificationContent()
		
		// Set notification properties
		content.title = "Street Sweeping 7/9 (Test)"
		content.body = "Check your neighborhood for signage and move your vehicle to avoid tickets."
		content.sound = UNNotificationSound(named: soundName)
		content.badge = 1
		//content.userInfo = ["address":self.common.favoriteAddress()]
		
		// Create notification id
		let identifier = "LocalNotification-\(triggerComponents.month!)-\(triggerComponents.day!)-\(triggerComponents.hour!)-\(triggerComponents.minute!)-\(triggerComponents.second!)"
		
		// Create notification request with id, content, and trigger
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
		
		// Add notification request to notification center
		center.add(request, withCompletionHandler: { (error) in
			if let error = error {
				print("Unable to create test notification with error: \(error.localizedDescription)")
			}
			else {
				print("Test notification added: \(identifier)")
			}
		})
	}
	
	// When and time picker methods
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return whenData.count
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		// Save default notification form values when picker is changed
		self.saveDefaultNotificationValues()
		
		// Update notifications after picker is changed
		if self.pushNotificationsSwitch.isOn {
			self.getSchedule(true)
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return whenData[row]
	}
	
	// Required to load polygons on favorites map
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		
		if overlay is MKPolygon {
			
			if let polygon = overlay as? MKPolygon {
				
				let renderer = MKPolygonRenderer(polygon: polygon)
				renderer.fillColor = .red
				renderer.alpha = 0.4
				return renderer
			}
		}
		
		return MKOverlayRenderer(overlay: overlay)
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
		annotationView?.leftCalloutAccessoryView = nil
		
		if (customPointAnnotation.customImageName == "pin-red") {
		
			let annotationLabel = THLabel(frame: CGRect(x: -40, y: 40, width: 125, height: 30))
			annotationLabel.lineBreakMode = .byWordWrapping
			annotationLabel.textAlignment = .center
			annotationLabel.font = .boldSystemFont(ofSize: 11)
			annotationLabel.text = annotation.title!
			annotationLabel.strokeSize = 1
			annotationLabel.strokeColor = UIColor.white
			annotationView?.addSubview(annotationLabel)
			
		}
		else if (customPointAnnotation.customImageName == "pin-orange") {
			
			let detailsButton = UIButton()
			detailsButton.frame.size.width = 35
			detailsButton.frame.size.height = 35
			//detailsButton.layer.cornerRadius = 7.0
			//detailsButton.backgroundColor = UIColor(hexString: "#FF7832")
			detailsButton.setImage(UIImage(named: "pageview"), for: .normal)
			
			annotationView?.leftCalloutAccessoryView = detailsButton
			
		}
		
		return annotationView
	}
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if let annotation = view.annotation as? CustomAnnotation {
			
			// Segue to relocated detail view
			if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "RelocatedDetailViewController") as? RelocatedDetailViewController {
				destinationViewController.relocatedVehicle = annotation.relocatedVehicle
				self.navigationController?.pushViewController(destinationViewController, animated: true)
			}
		}
	}

	//MARK: Actions
	
	// Push notifications toggle switch event
	@IBAction func pushNotificationsTapped(_ sender: Any) {
		
		if pushNotificationsSwitch.isOn == true {
			
			let latestAppVersion = self.common.latestAppVersion()
			let latestDatasetVersion = self.common.latestDatasetVersion()

			// Save settings to defaults
			defaults.set(true, forKey: "notificationsToggled")
			defaults.set(latestAppVersion, forKey: "notificationsYear")
			defaults.set(latestDatasetVersion, forKey: "userDatasetVersion")
			
			// Enable when and time controls
			self.timePicker.isUserInteractionEnabled = true
			self.onPicker.isUserInteractionEnabled = true
			
			// Save form values to defaults
			saveDefaultNotificationValues()
			
			// Register for Firebase Cloud Messaging notifications
			UIApplication.shared.registerForRemoteNotifications()
			
			// Get schedule and update user's local notifications
			self.getSchedule(true)
			
		}
		else {
			
			// Save toggle setting to defaults
			defaults.set(false, forKey: "notificationsToggled")
			
			// Disable when and time controls
			self.timePicker.isUserInteractionEnabled = false
			self.onPicker.isUserInteractionEnabled = false
			
			// Delete all location iOS notifications
			UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
			
			// Unregister from Firebase Cloud Messaging notifications
			UIApplication.shared.unregisterForRemoteNotifications()
			
			print("Deleted user's local notifications")
			
		}
	}
}
