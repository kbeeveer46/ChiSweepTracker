import UIKit
import UserNotifications
import CoreLocation
import MapKit

class NotificationsViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, MKMapViewDelegate {
    
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    @IBOutlet weak var onPicker: UIPickerView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var favoriteMapView: MKMapView!
    
    //let current = UNUserNotificationCenter.current()
    let common = Common()
    var schedule = ScheduleModel()
    var favoriteAddress = ""
    let whenData = ["Day Of", "1 Day Prior", "2 Days Prior", "3 Days Prior", "4 Days Prior", "5 Days Prior", "6 Days Prior", "7 Days Prior"]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		// Not everything I want loads in viewDidLoad so I put it in viewWillAppear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
		// Fill in notification form values with user defaults
        loadDefaultNotificationValues()
    
		// Load map using user favorite lat, long, and polygon coorndinates
        loadFavoriteMap()
        
        if !favoriteAddress.isEmpty {
			
			// Get schedule so we have the most update to date version
			// Used to pass schedule model to schedule view
			getSchedule(false)
        }
    }
	
	// MARK: Methods
	
	// Go to schedule page when schedule button is clicked
    @objc func viewSchedule() {
        
        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
            destinationViewController.schedule = self.schedule
            self.navigationController?.pushViewController(destinationViewController, animated: true)
        }
    }
    
	// Load map with default lat, long, and polygon coordinates or load Chicago map
    func loadFavoriteMap() {
        
        favoriteMapView.delegate = self
        favoriteMapView.removeAnnotations(favoriteMapView.annotations)
        
        let favoriteWard = defaults.string(forKey: "favoriteWard") ?? ""
        let favoriteSection = defaults.string(forKey: "favoriteSection") ?? ""
        let favoriteLongitude = defaults.double(forKey: "favoriteLongitude")
        let favoriteLatitude = defaults.double(forKey: "favoriteLatitude")
        let favoriteCoordinatesArray = defaults.object(forKey: "favoriteCoordinatesArray") as? [[NSArray]]
        var mapOverlayCoordinates = [CLLocationCoordinate2D]()
        
        if favoriteLongitude != 0 && favoriteLatitude != 0 {
            
            if favoriteCoordinatesArray != nil {
                for(_, coordinate) in favoriteCoordinatesArray!.enumerated() {
                    for item in coordinate {
                        var coordinate = CLLocationCoordinate2D()
                        coordinate.longitude = item[0] as? Double ?? 0
                        coordinate.latitude = item[1] as? Double ?? 0
                        mapOverlayCoordinates.append(coordinate)
                    }
                }
                let polygon = MKPolygon(coordinates: mapOverlayCoordinates, count: mapOverlayCoordinates.count)
                favoriteMapView.removeOverlays(favoriteMapView.overlays)
                favoriteMapView.addOverlay(polygon)
            }

            let location: CLLocation = CLLocation(latitude: favoriteLatitude, longitude: favoriteLongitude)

            let annotation = MKPointAnnotation()
            annotation.title = favoriteAddress
            annotation.subtitle = "Ward \(favoriteWard) - Section \(favoriteSection)"
            annotation.coordinate = location.coordinate

            let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            
            favoriteMapView.addAnnotation(annotation)
            favoriteMapView.setRegion(region, animated: true)

        }
        else {
            
            let span = MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45)
            let chicagoCoordinate = CLLocationCoordinate2D(latitude: 41.846647, longitude: -87.629576)
            let region = MKCoordinateRegion(center: chicagoCoordinate, span: span)
            favoriteMapView.setRegion(region, animated: true)
            
            self.tabBarController?.navigationItem.title = "No Favorite Address Saved"
            
        }
        
    }
    
    @objc func removeFavorite() {
        
		// Add haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        
		// Alert user if they want to delete their favorite because they will no longer receive push notifications
        let alert = UIAlertController(title: "Delete Favorite?", message: "You will no longer receive push notifications", preferredStyle: .alert)
        
		// Add Yes button option
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
            
            defaults.set("", forKey: "favoriteAddress")
            defaults.set("", forKey: "favoriteWard")
            defaults.set("", forKey: "favoriteSection")
            defaults.set(0.0, forKey: "favoriteLongitude")
            defaults.set(0.0, forKey: "favoriteLatitude")
            defaults.set(nil, forKey: "favoriteCoordinatesArray")
            defaults.set(false, forKey: "notificationsToggled")
            self.favoriteAddress = ""
			
			print("Deleted favorite address: \(self.favoriteAddress)")
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            print("Deleted user's local notifications")
            
            // If on a view with a tab control then use it to go to the search view
            self.tabBarController?.selectedIndex = 0
            
            // If not on a view with a tab control, use navigation controller to go to search view
            if self.tabBarController == nil {
                
                if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
                    //destinationViewController.schedule = self.schedule
                    self.navigationController?.pushViewController(destinationViewController, animated: true)
                }
            }
        }))
        
		// Add No button option
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
		// Present alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func timePickerChanged(picker: UIDatePicker) {
        
		// Save form values to defaults
        saveDefaultNotificationValues()
        
		// Update notifications when picker is changed
        if self.pushNotificationsSwitch.isOn {
            self.getSchedule(true)
        }
    }
    
    func loadDefaultNotificationValues() {
        
		// Set the title or else the title is used from another tab
		self.tabBarController?.navigationItem.title = "Favorite Address"
		
		// Set required properties for when picker
		self.onPicker.delegate = self
		self.onPicker.dataSource = self
		
		// Set values for when and time pickers
        let when = defaults.object(forKey: "notificationWhen") as? String ?? ""
        let index = whenData.firstIndex(of: when) ?? 0
        let hour = defaults.integer(forKey: "notificationHour")
        let minute = defaults.integer(forKey: "notificationMinute")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        let date = dateFormatter.date(from: "\(hour):\(minute)")
        
        self.onPicker.selectRow(index, inComponent: 0, animated: false)
        self.timePicker.date = date!
        
        timePicker.addTarget(self, action: #selector(timePickerChanged(picker:)), for: .valueChanged)
        
		// Turn form on or off depending if they have notifications toggled on or off
        favoriteAddress = defaults.string(forKey: "favoriteAddress") ?? ""
		let notificationsToggled = defaults.bool(forKey: "notificationsToggled")
		
		if !favoriteAddress.isEmpty {
			self.pushNotificationsSwitch.isOn = notificationsToggled
			self.pushNotificationsSwitch.isUserInteractionEnabled = true
			self.onPicker.isUserInteractionEnabled = notificationsToggled
			self.timePicker.isUserInteractionEnabled = notificationsToggled
			
			self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "list"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(viewSchedule))
			self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "star"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(removeFavorite))
		}
		else {
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
        
		self.schedule.address = self.common.constants.favoriteAddress()
		
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
                                self.schedule.section = defaults.string(forKey: "favoriteSection") ?? ""
                            }
                            
                            let scheduleQuery = wardClient.query(dataset: self.common.constants.scheduleDataset())
								.filter("\(self.common.constants.ward()) = '\(ward)' AND \(self.common.constants.section()) = '\(self.schedule.section)'")
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        self.schedule.months.removeAll()
                                        
                                        for (_, item) in data.enumerated() {
                                            
                                            let monthName = item[self.common.constants.month_name()] as? String ?? ""
                                            let monthNumber = item[self.common.constants.month_number()] as? String ?? ""
                                            let dates = item[self.common.constants.dates()] as? String ?? ""
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
                                            
                                            // Clear current notifications and re-add them in case they changed
                                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                            
											print("Deleted user's local notifications")
											
                                            #if DEBUG
                                                //self.sendTestNotifications()
                                            #endif
                                            
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
                                                    
													 // Do not remove DispatchQueue
                                                     DispatchQueue.main.async {
                                                    
                                                        let center = UNUserNotificationCenter.current()
														let calendar = Calendar.current
														let currentYear = self.common.constants.latestAppVersion() 
														let notificationWhenDefault = defaults.object(forKey: "notificationWhen") as? String ?? ""
														let notificationHourDefault = defaults.integer(forKey: "notificationHour")
														let notificationMinuteDefault = defaults.integer(forKey: "notificationMinute")
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
                                                                
																let dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current, year: currentYear, month: Int(monthInSchedule.number), day: dayInMonth.date, hour: hour, minute: minute)
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
																let triggerComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute,.timeZone], from: date!)
                                                                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
                                                                
																// Create notification contents
                                                                let content = UNMutableNotificationContent()
                                                                content.title = "Sweep Alert"
                                                                content.body = "Your area is being swept on \(monthInSchedule.number)/\(dayInMonth.date) between 9 am and 2 pm"
                                                                let soundName = UNNotificationSoundName("notification.m4r")
																content.sound = UNNotificationSound(named: soundName)
                                                                content.badge = 1

																// Create notificaton identifier
                                                                let identifier = "LocalNotification-\(triggerComponents.month!)-\(triggerComponents.day!)-\(triggerComponents.hour!)-\(triggerComponents.minute!)"

																// Create notification request
                                                                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                                                                
																// Add notification
																center.add(request, withCompletionHandler: { (error) in
                                                                    if let error = error {
                                                                        print("Error adding notification: \(error.localizedDescription)")
                                                                    }
                                                                    else {
                                                                        print("Local notification added: \(date!.description(with: Locale.current))")
                                                                    }
                                                                })
                                                            }
                                                        }
														
														// Set the last year when notifications were updated.
														// Use the value to alert them if they loaded the app after a new year came out
														let notificationsYear = self.common.constants.notificationsYear()
														let latestAppVersion = self.common.constants.latestAppVersion()
														if notificationsYear > 0 && notificationsYear < latestAppVersion {
															self.common.showAlert("Notifications Updated", "Your push notifications have been updated to reflect the \(latestAppVersion) schedule.")
														}
														defaults.set(latestAppVersion, forKey: "notificationsYear")
														
														// Set the latest dataset version when notifications were updated
														// Use the value to alert them if they loaded the app after Chicago changed the schedule
														let latestDatasetVersion = self.common.constants.latestDatasetVersion()
														let userDatasetVersion = self.common.constants.userDatasetVersion()
														if userDatasetVersion > 0 && userDatasetVersion < latestDatasetVersion {
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
		
		let center = UNUserNotificationCenter.current()
		let calendar = Calendar.current
		let earlyDate = calendar.date(byAdding: .minute, value: 1,to: Date())
		
		let triggerComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: earlyDate!)
		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
		
		let content = UNMutableNotificationContent()
		content.title = "Sweep Alert"
		content.body = "Your section is being swept on 12/12 between 9 am and 2 pm"
		let soundName = UNNotificationSoundName("notification.m4r")
		content.sound = UNNotificationSound(named: soundName)
		content.badge = 1
		
		let identifier = "LocalNotification-\(triggerComponents.month!)-\(triggerComponents.day!)-\(triggerComponents.hour!)-\(triggerComponents.minute!)"
		
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
		
		center.add(request, withCompletionHandler: { (error) in
			if let error = error {
				//self.common.showAlert(self.constants.errorTitle, error.localizedDescription)
				print(error.localizedDescription)
			}
			else {
				print("Local test notification added: \(identifier)")
			}
		})
		
	}

	//MARK: Actions
	
	// Push notifications toggle switch event
	@IBAction func pushNotificationsTapped(_ sender: Any) {
		
		if pushNotificationsSwitch.isOn == true {
			
			defaults.set(true, forKey: "notificationsToggled")
			
			self.timePicker.isUserInteractionEnabled = true
			self.onPicker.isUserInteractionEnabled = true
			
			saveDefaultNotificationValues()
			
			self.getSchedule(true)
			
		}
		else {
			
			defaults.set(false, forKey: "notificationsToggled")
			
			self.timePicker.isUserInteractionEnabled = false
			self.onPicker.isUserInteractionEnabled = false
			
			UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
			
			print("Deleted user's local notifications")
			
		}
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
        saveDefaultNotificationValues()
        
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
            
            if let pg = overlay as? MKPolygon {
                
                let pr = MKPolygonRenderer(polygon: pg)
                pr.fillColor = .red
                pr.alpha = 0.4
                return pr
            }
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
}

