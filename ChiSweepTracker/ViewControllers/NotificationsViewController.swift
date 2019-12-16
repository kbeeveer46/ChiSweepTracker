import UIKit
import UserNotifications
import CoreLocation
import MapKit

class NotificationsViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, MKMapViewDelegate {
    
    @IBOutlet weak var textNotificationSwitch: UISwitch!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailNotificationSwitch: UISwitch!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    @IBOutlet weak var onPicker: UIPickerView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var favoriteMapView: MKMapView!
    
    let current = UNUserNotificationCenter.current()
    let common = Common()
    var schedule = ScheduleModel()
    var favoriteAddress = ""
    let defaults = UserDefaults.standard
    var removeFavoriteButton = UIBarButtonItem()
    let whenData = ["Day Of", "1 Day Prior", "2 Days Prior", "3 Days Prior", "4 Days Prior", "5 Days Prior", "6 Days Prior", "7 Days Prior"]
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
		// Set the title or else the title is used from another tab
		self.tabBarController?.navigationItem.title = "Favorite Address"
		
		// Set required properties for when picker
        self.onPicker.delegate = self
        self.onPicker.dataSource = self
        
        loadDefaultNotificationValues()
    
        loadFavoriteMap()
        
        if !favoriteAddress.isEmpty {
			
			// Get schedule so we have the most update to date version
			getSchedule(false)
			
			// Re-add local notifications in case the City of Chicago has changed the dates
			addNotifications()
        }
    }
	
	func addNotifications() {
		
		current.getNotificationSettings(completionHandler: { (settings) in
			if settings.authorizationStatus == .notDetermined {
				print("notDetermined")
			} else if settings.authorizationStatus == .denied {
				print("denied")
			} else if settings.authorizationStatus == .authorized {
				//print("authorized")
				
				DispatchQueue.main.async {
					
					let notificationsToggled = self.defaults.bool(forKey: "notificationsToggled")
					self.pushNotificationsSwitch.isOn = notificationsToggled
					
					if self.pushNotificationsSwitch.isOn {
						self.getSchedule(true)
					}
				}
			}
		})
		
	}
    
    @objc func viewSchedule() {
        
        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
            destinationViewController.schedule = self.schedule
            self.navigationController?.pushViewController(destinationViewController, animated: true)
        }
    }
    
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
            
            favoriteMapView.isHidden = false
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
        
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        
        let alert = UIAlertController(title: "Delete Favorite?", message: "You will no longer receive push notifications", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
            
            // TODO: Change this button to add it they remove favorite
            // No longer need to do this now that it's segueing to the seach tab bar
            //self.tabBarController?.navigationItem.rightBarButtonItem = nil
            //self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "star"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(removeFavorite))
            
            print("Deleted favorite address: \(self.favoriteAddress)")
            
            self.defaults.set("", forKey: "favoriteAddress")
            self.defaults.set("", forKey: "favoriteWard")
            self.defaults.set("", forKey: "favoriteSection")
            self.defaults.set(0.0, forKey: "favoriteLongitude")
            self.defaults.set(0.0, forKey: "favoriteLatitude")
            self.defaults.set(nil, forKey: "favoriteCoordinatesArray")
            self.defaults.set(false, forKey: "notificationsToggled")
            self.favoriteAddress = ""
            //self.pushNotificationsSwitch.isOn = false
            //self.pushNotificationsSwitch.isUserInteractionEnabled = false
            
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
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func timePickerChanged(picker: UIDatePicker) {
        
        saveDefaultNotificationValues()
        
        if self.pushNotificationsSwitch.isOn {
            self.getSchedule(true)
        }
    }
    
    @IBAction func pushNotificationsTapped(_ sender: Any) {
        
        if pushNotificationsSwitch.isOn == true {
            
            self.defaults.set(true, forKey: "notificationsToggled")
            
            self.timePicker.isUserInteractionEnabled = true
            self.onPicker.isUserInteractionEnabled = true
            
            saveDefaultNotificationValues()
            
            //registerForPushNotifications()
            self.getSchedule(true)
        
        }
        else {
            
            self.defaults.set(false, forKey: "notificationsToggled")
            
            self.timePicker.isUserInteractionEnabled = false
            self.onPicker.isUserInteractionEnabled = false
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            print("Deleted user's local notifications")
            
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
    
    func loadDefaultNotificationValues() {
        
        let when = self.defaults.object(forKey: "notificationWhen") as? String ?? ""
        let index = whenData.firstIndex(of: when) ?? 0
        let hour = self.defaults.integer(forKey: "notificationHour")
        let minute = self.defaults.integer(forKey: "notificationMinute")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        let date = dateFormatter.date(from: "\(hour):\(minute)")
        
        self.onPicker.selectRow(index, inComponent: 0, animated: false)
        self.timePicker.date = date!
        
        timePicker.addTarget(self, action: #selector(timePickerChanged(picker:)), for: .valueChanged)
        
        favoriteAddress = defaults.string(forKey: "favoriteAddress") ?? ""
		
		if !favoriteAddress.isEmpty {
			
			let notificationsToggled = self.defaults.bool(forKey: "notificationsToggled")
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
    
    func saveDefaultNotificationValues() {
        
        let time = self.timePicker.date
        let comp = Calendar.current.dateComponents([.hour, .minute], from: time)
        let hour = comp.hour!
        let minute = comp.minute!
        let when = self.whenData[self.onPicker.selectedRow(inComponent: 0)]
        
        self.defaults.set(when, forKey: "notificationWhen")
        self.defaults.set(hour, forKey: "notificationHour")
        self.defaults.set(minute, forKey: "notificationMinute")
        
    }
    
//    func removeDefaultNotificationValues() {
//
//        self.defaults.set("", forKey: "notificationWhen")
//        self.defaults.set(0, forKey: "notificationHour")
//        self.defaults.set(0, forKey: "notificationMinute")
//
//    }
    
	func getSchedule(_ registerForPushNotifications: Bool,
					 _ useDefaultNotificationValues: Bool = false,
					 _ notificationsUpdatedAfterNewVersionOrUpdate: Bool = false) {
        
		self.schedule.address = self.common.constants.favoriteAddress() //self.favoriteAddress
		
        print("Address: \(self.schedule.address)")
        
        // Get coordinates
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(self.schedule.address) { placemarks, error in
            
            if error != nil {
                
				print("getSchedule error: \((error! as NSError).userInfo.debugDescription)")
				
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
                
                //print("Latitude: \(self.schedule.locationCoordinate.latitude)")
                //print("Longitude: \(self.schedule.locationCoordinate.longitude)")
                
                let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
                
                // Get ward and section JSON from City of Chicago
                
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
                            
                            //print("Ward: \(ward)")
                            //print("Section: \(section)")
                            
                            self.schedule.ward = ward
                            self.schedule.section = String(section).trimmingCharacters(in: .whitespaces)
                            
                            if self.schedule.section.isEmpty {
                                self.schedule.section = self.defaults.string(forKey: "favoriteSection") ?? ""
                            }
                            
                            // Get schedule JSON from City of Chicago
                            
                            let scheduleQuery = wardClient.query(dataset: self.common.constants.scheduleDataset())
                                .filter("ward = '\(ward)' AND section = '\(self.schedule.section)'")
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        self.schedule.months.removeAll()
                                        
                                        // Populate schedule model to be used on schedule view
                                        
                                        for (_, item) in data.enumerated() {
                                            
                                            let monthName = item[self.common.constants.month_name()] as? String ?? ""
                                            let monthNumber = item[self.common.constants.month_number()] as? String ?? ""
                                            let dates = item[self.common.constants.dates()] as? String ?? ""
                                            let datesArray = dates.components(separatedBy: ",")
                                            
                                            //print("Month name: \(monthName)")
                                            //print("Dates: \(datesArray)")
                                            
                                            //let month = MonthModel(name: "", number: "", dates: [DateModel]())
                                            let month = MonthModel()
                                            month.name = monthName
                                            month.number = monthNumber
                                            
                                            for day in datesArray {
                                                
                                                //print("Date: \(day)")
                                                
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
										
										// Show schedule button in the top left in case it was hidden when the user didn't have an Internet connection
										self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "list"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(self.viewSchedule))
                                        
                                        if registerForPushNotifications == true {
                                            
                                            // Clear current notifications and re-add them in case they changed
                                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                            
                                            #if DEBUG
                                                //self.sendTestNotifications()
                                            #endif
                                            
                                            print("Deleted user's local notifications")
                                            
                                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                                            granted, error in
                                            
                                                print("Permission granted: \(granted)")
                                                
                                                if granted == false {
                                                    
                                                    // User's notifications are disabled in settings. Prompt them to open settings
                                                    DispatchQueue.main.async {
                                                        
                                                        self.pushNotificationsSwitch.isOn = false
                                                    
                                                        let alertController = UIAlertController (title: "Notifications Are Disabled", message: "Do you want to go to settings and enable notifications?", preferredStyle: .alert)

                                                        let settingsAction = UIAlertAction(title: "Yes", style: .default) { (_) -> Void in

                                                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                                                return
                                                            }

                                                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                                                    print("User opened the setting page")
                                                                })
                                                            }
                                                        }
                                                        alertController.addAction(settingsAction)
                                                        
                                                        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler:{ action in
                                                            
                                                            //self.pushNotificationsSwitch.isUserInteractionEnabled = false
                                                            self.timePicker.isUserInteractionEnabled = false
                                                            self.onPicker.isUserInteractionEnabled = false
                                                            self.defaults.set(false, forKey: "notificationsToggled")
                                                            
                                                        })
                                                        alertController.addAction(cancelAction)

                                                        self.present(alertController, animated: true, completion: nil)
                                                    
                                                    }
                                                    
                                                }
                                                else {
                                                    
                                                     DispatchQueue.main.async {
                                                    
                                                        let center = UNUserNotificationCenter.current()
                                                        
                                                        let calendar = Calendar.current
                                                        let currentYear = calendar.component(.year, from: Date())
                                                        
														let notificationWhenDefault = self.defaults.object(forKey: "notificationWhen") as? String ?? ""
														let notificationHourDefault = self.defaults.integer(forKey: "notificationHour")
														let notificationMinuteDefault = self.defaults.integer(forKey: "notificationMinute")
														
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
															let comp = calendar.dateComponents([.hour, .minute], from: time)
															hour = comp.hour!
															minute = comp.minute!
															when = self.whenData[self.onPicker.selectedRow(inComponent: 0)]
														}
														
                                                        for monthInSchedule in self.schedule.months {
                                                            
                                                            for dayInMonth in monthInSchedule.dates {
                                                                
                                                                let dateComponents = DateComponents(year: currentYear, month: Int(monthInSchedule.number), day: dayInMonth.date)
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
                                                                
                                                                date = calendar.date(bySetting: .hour, value: hour, of: date!)
                                                                date = calendar.date(bySetting: .minute, value: minute, of: date!)
                                                                
                                                                let triggerComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: date!)
                                                                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
                                                                
                                                                let content = UNMutableNotificationContent()
                                                                content.title = "Sweep Alert"
                                                                content.body = "Your area is being swept on \(monthInSchedule.number)/\(dayInMonth.date) between 9 am and 2 pm"
                                                                content.sound = .default
                                                                content.badge = 1
                                                                
                                                                let identifier = "LocalNotification-\(triggerComponents.month!)-\(triggerComponents.day!)-\(triggerComponents.hour!)-\(triggerComponents.minute!)"
                                                                
                                                                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                                                                
                                                                center.add(request, withCompletionHandler: { (error) in
                                                                    if let error = error {
                                                                        //self.common.showAlert(self.constants.errorTitle, error.localizedDescription)
                                                                        print(error.localizedDescription)
                                                                    }
                                                                    else {
                                                                        print("Local notification added: \(identifier)")
                                                                    }
                                                                })
                                                            }
                                                        }
													
														if notificationsUpdatedAfterNewVersionOrUpdate == true {
															
															//self.common.showAlert("Notifications Updated For \(self.common.constants.appVersion)!", "")
															
															self.defaults.set(self.common.constants.appVersion, forKey: "lastYearUserRefreshedNotifications")
															self.defaults.set(true, forKey: "hasUserRefreshedNotificationsAfterNewVersion")
															
															// Segue not working!!
															// Prompt the user if they want to view the new schedule details
//															let alert = UIAlertController(title: "Notifications Updated", message: "Would you like to view the new schedule?", preferredStyle: .alert)
//															alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
//
//																if let destinationViewController = UIApplication.shared.keyWindow?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
//																	destinationViewController.schedule = self.schedule
//																	UIApplication.shared.keyWindow?.rootViewController?.navigationController?.pushViewController(destinationViewController, animated: true)
//																}
//
//															}))
//															alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//															UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
															//
														}
													}
                                                }
                                            }
                                        }
                                    }
                                case .error (let err):
                                    
                                    //self.common.showAlert(self.constants.errorTitle, (err as NSError).userInfo.debugDescription)
                                    print((err as NSError).userInfo.debugDescription)
									self.tabBarController?.navigationItem.leftBarButtonItem = nil
                                    
                                }
                            }
                        }
                        else {
                            //self.common.showAlert(self.constants.errorTitle, self.constants.notFound)
                            print(self.common.constants.notFound)
							self.tabBarController?.navigationItem.leftBarButtonItem = nil
                        }
                    case .error (let err):
                        //self.common.showAlert(self.constants.errorTitle, (err as NSError).userInfo.debugDescription)
                        print((err as NSError).userInfo.debugDescription)
						self.tabBarController?.navigationItem.leftBarButtonItem = nil
                    }
                }
            }
            else {
                
                //self.common.showAlert(self.constants.errorTitle, self.constants.notFound)
                print(self.common.constants.notFound)
				self.tabBarController?.navigationItem.leftBarButtonItem = nil
            }
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
        
        saveDefaultNotificationValues()
        
        if self.pushNotificationsSwitch.isOn {
            //self.registerForPushNotifications()
            self.getSchedule(true)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return whenData[row]
    }
    
    // Make enter key close keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
    
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

