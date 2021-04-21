import UIKit
import MapKit
import Firebase

let defaults = UserDefaults.standard

class Common {
    
    let constants = Constants()
    
	//MARK: Defaults
	
	// Shared
	
	func latestAppVersion() -> Int { return defaults.integer(forKey: "latestAppVersion")}
	func latestDatasetVersion() -> Int {return defaults.integer(forKey: "latestDatasetVersion")}
	func userDatasetVersion() -> Int {return defaults.integer(forKey: "userDatasetVersion")}
	
	func defaultAddress() -> String {return defaults.string(forKey: "defaultAddress") ?? ""}
	func defaultLongitude() -> Double {return defaults.double(forKey: "defaultLongitude")}
	func defaultLatitude() -> Double {return defaults.double(forKey: "defaultLatitude")}
	func defaultCoordinatesArray() -> [[NSArray]] {return defaults.object(forKey: "defaultCoordinatesArray") as! [[NSArray]]}
    func selectedAnnotationLongitude() -> Double {return defaults.double(forKey: "selectedAnnotationLongitude")}
    func selectedAnnotationLatitude() -> Double {return defaults.double(forKey: "selectedAnnotationLatitude")}
        
	// SODA SDK
	
	// Schedule
	
	func dates() -> String {return defaults.string(forKey: "datesTitle") ?? ""}
	func monthNumberTitle() -> String {return defaults.string(forKey: "monthNumberTitle") ?? ""}
	func monthNameTitle() -> String {return defaults.string(forKey: "monthNameTitle") ?? ""}
	func coordinatesTitle() -> String {return defaults.string(forKey: "coordinatesTitle") ?? ""}
	func sectionTitle() -> String {return defaults.string(forKey: "sectionTitle") ?? ""}
	func wardTitle() -> String {return defaults.string(forKey: "wardTitle") ?? ""}
	func geomTitle() -> String {return defaults.string(forKey: "geomTitle") ?? ""}
	func scheduleDataset() -> String {return defaults.string(forKey: "scheduleDataset") ?? ""}
	func wardDataset() -> String {return defaults.string(forKey: "wardDataset") ?? ""}
	
	// Divvy
	
	func divvyDataset() -> String {return defaults.string(forKey: "divvyDataset") ?? ""}
	func divvyIdTitle() -> String {return defaults.string(forKey: "divvyIdTitle") ?? ""}
	func divvyDocksInServiceTitle() -> String {return defaults.string(forKey: "divvyDocksInServiceTitle") ?? ""}
	func divvyLatitudeTitle() -> String {return defaults.string(forKey: "divvyLatitudeTitle") ?? ""}
	func divvyLongitudeTitle() -> String {return defaults.string(forKey: "divvyLongitudeTitle") ?? ""}
	func divvyStationNameTitle() -> String {return defaults.string(forKey: "divvyStationNameTitle") ?? ""}
	func divvyStatusTitle() -> String {return defaults.string(forKey: "divvyStatusTitle") ?? ""}
	
	func divvyJSONUrl() -> String {return defaults.string(forKey: "divvyJSONUrl") ?? ""}
	func divvyJSONBikesAvailableTitle() -> String {return defaults.string(forKey: "divvyJSONBikesAvailableTitle") ?? ""}
	func divvyJSONEBikesAvailableTitle() -> String {return defaults.string(forKey: "divvyJSONEBikesAvailableTitle") ?? ""}
	func divvyJSONDocksAvailableTitle() -> String {return defaults.string(forKey: "divvyJSONDocksAvailableTitle") ?? ""}
	func divvyJSONDataTitle() -> String {return defaults.string(forKey: "divvyJSONDataTitle") ?? ""}
	func divvyJSONStationsTitle() -> String {return defaults.string(forKey: "divvyJSONStationsTitle") ?? ""}
	func divvyJSONIdTitle() -> String {return defaults.string(forKey: "divvyJSONIdTitle") ?? ""}
	func divvyJSONLastUpdatedTitle() -> String {return defaults.string(forKey: "divvyJSONLastUpdatedTitle") ?? ""}
	
	// Towed vehicles
	
	func towedDataset() -> String {return defaults.string(forKey: "towedDataset") ?? ""}
	func towedColorTitle() -> String {return defaults.string(forKey: "towedColorTitle") ?? ""}
	func towedInventoryNumberTitle() -> String {return defaults.string(forKey: "towedInventoryNumberTitle") ?? ""}
	func towedMakeTitle() -> String {return defaults.string(forKey: "towedMakeTitle") ?? ""}
	func towedModelTitle() -> String {return defaults.string(forKey: "towedModelTitle") ?? ""}
	func towedPlateTitle() -> String {return defaults.string(forKey: "towedPlateTitle") ?? ""}
	func towedStateTitle() -> String {return defaults.string(forKey: "towedStateTitle") ?? ""}
	func towedStyleTitle() -> String {return defaults.string(forKey: "towedStyleTitle") ?? ""}
	func towedDateTitle() -> String {return defaults.string(forKey: "towedDateTitle") ?? ""}
	func towedToAddressTitle() -> String {return defaults.string(forKey: "towedToAddressTitle") ?? ""}
	func towedToPhoneTitle() -> String {return defaults.string(forKey: "towedToPhoneTitle") ?? ""}
	
	// Relocated vehicles
	
	func relocatedDataset() -> String {return defaults.string(forKey: "relocatedDataset") ?? ""}
	func relocatedColorTitle() -> String {return defaults.string(forKey: "relocatedColorTitle") ?? ""}
	func relocatedMakeTitle() -> String {return defaults.string(forKey: "relocatedMakeTitle") ?? ""}
	func relocatedPlateTitle() -> String {return defaults.string(forKey: "relocatedPlateTitle") ?? ""}
	func relocatedDateTitle() -> String {return defaults.string(forKey: "relocatedDateTitle") ?? ""}
	func relocatedFromLatitudeTitle() -> String {return defaults.string(forKey: "relocatedFromLatitudeTitle") ?? ""}
	func relocatedFromLongitudeTitle() -> String {return defaults.string(forKey: "relocatedFromLongitudeTitle") ?? ""}
	func relocatedFromAddressNumberTitle() -> String {return defaults.string(forKey: "relocatedFromAddressNumberTitle") ?? ""}
	func relocatedFromDirectionTitle() -> String {return defaults.string(forKey: "relocatedFromDirectionTitle") ?? ""}
	func relocatedFromStreetTitle() -> String {return defaults.string(forKey: "relocatedFromStreetTitle") ?? ""}
	func relocatedReasonTitle() -> String {return defaults.string(forKey: "relocatedReasonTitle") ?? ""}
	func relocatedToAddressNumberTitle() -> String {return defaults.string(forKey: "relocatedToAddressNumberTitle") ?? ""}
	func relocatedToDirectionTitle() -> String {return defaults.string(forKey: "relocatedToDirectionTitle") ?? ""}
	func relocatedToStreetTitle() -> String {return defaults.string(forKey: "relocatedToStreetTitle") ?? ""}
	func relocatedStateTitle() -> String {return defaults.string(forKey: "relocatedStateTitle") ?? ""}
	
	// Favorites
	
	func favoriteAddress() -> String {return defaults.string(forKey: "favoriteAddress") ?? ""}
	//func favoriteWard() -> String {return defaults.string(forKey: "favoriteWard") ?? ""}
	//func favoriteSection() -> String {return defaults.string(forKey: "favoriteSection") ?? ""}
	//func favoriteLatitude() -> Double {return defaults.double(forKey: "favoriteLatitude")}
	//func favoriteLongitude() -> Double {return defaults.double(forKey: "favoriteLongitude")}
	//func favoriteCoordinatesArray() -> [[NSArray]] {return defaults.object(forKey: "favoriteCoordinatesArray") as? [[NSArray]] ?? [[NSArray]]()}
	func showDivvyStations() -> Bool {return defaults.bool(forKey: "showDivvyStations")}
	func showTowedVehicles() -> Bool {return defaults.bool(forKey: "showTowedVehicles")}
    func favoriteAddresses() -> [[String]] {return defaults.object(forKey: "favoriteAddresses") as? [[String]] ?? [[String]](repeating: [String](repeating: "", count: 5), count: 50)}
    // favoriteAddresses[0] = address
    // favoriteAddresses[1] = notifications toggled
    // favoriteAddresses[2] = when
    // favoriteAddresses[3] = hour
    // favoriteAddresses[4] = minute
    // favoriteAddresses[5] = ward
    // favoriteAddresses[6] = section
    
	// Notifications
	
	func notificationWhen() -> String {return defaults.string(forKey: "notificationWhen") ?? ""}
	func notificationHour() -> Int {return defaults.integer(forKey: "notificationHour")}
	func notificationMinute() -> Int {return defaults.integer(forKey: "notificationMinute")}
	func notificationsToggled() -> Bool {return defaults.bool(forKey: "notificationsToggled")}
	func notificationsYear() -> Int {return defaults.integer(forKey: "notificationsYear")}
    func notificationOneSignalPlayerId() -> String {return defaults.string(forKey: "notificationOneSignalPlayerId") ?? ""}
    func notificationsOneSignalIsSubscribed() -> Bool {return defaults.bool(forKey: "notificationsOneSignalIsSubscribed")}
	
	// Updates
	
	func updatesLastViewDate() -> String {return defaults.string(forKey: "updatesLastViewDate") ?? ""}
	
	// Settings
	
	//func contactEmail() -> String {return defaults.string(forKey: "contactEmail") ?? "admin@chicagosweeptracker.info"}
	
	//MARK: Constants
	
    class Constants {
        
		// Databases
		
		#if DEBUG
		let schedulesDatabaseName = "Schedules_Dev"
		let updatesDatabaseName = "Updates_Dev"
		let settingsDatabaseName = "Settings_Dev"
		let divvysDatabaseName = "Divvys_Dev"
		let towedDatabaseName = "TowedVehicles_Dev"
		let relocatedDatabaseName = "RelocatedVehicles_Dev"
		let newsDatabaseName = "News_Dev"
		let infoDatabaseName = "Info_Dev"
        let notificationsDatabaseName = "Notifications_Dev"
		#else
		let schedulesDatabaseName = "Schedules"
		let updatesDatabaseName = "Updates"
		let settingsDatabaseName = "Settings"
		let divvysDatabaseName = "Divvys"
		let towedDatabaseName = "TowedVehicles"
		let relocatedDatabaseName = "RelocatedVehicles"
		let newsDatabaseName = "News"
		let infoDatabaseName = "Info"
        let notificationsDatabaseName = "Notifications"
		#endif
	
		// SODA
		
		let SODAToken = "dM3SUsRUNwyTWQGy83lvBv4X3"
        let SODADomain = "data.cityofchicago.org"
		
		// Strings
		
        let errorTitle = "Something went wrong..."
        let notFound = "Unable to find sweep schedule. Address must reside in Chicago."
		
		let finishedScheduleMessage = "Sweeping has ended for _currentYear_."
		let beginScheduleMessage = "Sweeping will begin on April 1st in _amount_ day(s)."
		let noInternetConnectionSearchMessage = "Unable to find sweep schedule. This may be caused by not having an internet connection or the Chicago API may be down for scheduled maintenance. Please try again in a few hours."
		
		// Colors
		let systemRed = "#ff3b30"
		let systemBlue = "#007aff"
		let divvy = "#3fb5e7"
		let background = "#f2f2f2"
    }
	
	//MARK: Methods
	
	func getDataFromDatabase(completion: @escaping (_ message: String) -> Void) {
		
		let db = Firestore.firestore()
		
		// Get schedule data
		db.collection(self.constants.schedulesDatabaseName)
			.order(by: "year", descending: true)
			.limit(to: 1)
			.getDocuments() { (querySnapshot, err) in
				if let err = err {
					fatalError("Could not get Chicago data from Firebase: \(err)")
				} else {
					for document in querySnapshot!.documents {
						
						let data = document.data()
						let latestAppVersion = data["year"] as! Int
						let wardDataset = data["wardDataset"] as! String
						let scheduleDataset = data["scheduleDataset"] as! String
						let coordinatesTitle = data["coordinatesTitle"] as! String
						let datesTitle = data["datesTitle"] as! String
						let geomTitle = data["geomTitle"] as! String
						let monthNameTitle = data["monthNameTitle"] as! String
						let monthNumberTitle = data["monthNumberTitle"] as! String
						let sectionTitle = data["sectionTitle"] as! String
						let wardTitle = data["wardTitle"] as! String
						
						defaults.set(latestAppVersion, forKey: "latestAppVersion")
						defaults.set(wardDataset, forKey: "wardDataset")
						defaults.set(scheduleDataset, forKey: "scheduleDataset")
						defaults.set(coordinatesTitle, forKey: "coordinatesTitle")
						defaults.set(datesTitle, forKey: "datesTitle")
						defaults.set(geomTitle, forKey: "geomTitle")
						defaults.set(monthNameTitle, forKey: "monthNameTitle")
						defaults.set(monthNumberTitle, forKey: "monthNumberTitle")
						defaults.set(sectionTitle, forKey: "sectionTitle")
						defaults.set(wardTitle, forKey: "wardTitle")
						
						// Get data set version
						let docRef = db.collection(self.constants.updatesDatabaseName).document(String(self.latestAppVersion()))
						
						docRef.getDocument { (document, error) in
							if let document = document, document.exists {
								
								let data = document.data()
								let latestDatasetVersion = data!["version"]!
								
								defaults.set(latestDatasetVersion, forKey: "latestDatasetVersion")
								
								self.updateNotifications()
								
							} else {
								print("Cannot get dataset version from Firebase")
							}
						}
					}
				}
		}
		
		// Get Divvys data
		db.collection(self.constants.divvysDatabaseName)
			.limit(to: 1)
			.getDocuments() { (querySnapshot, err) in
				if let err = err {
					print("Could not get Divvys data from Firebase: \(err)")
				} else {
					for document in querySnapshot!.documents {
						
						let data = document.data()
						
						let divvyDataset = data["divvyDataset"] as! String
						let divvyIdTitle = data["idTitle"] as! String
						let divvyDocksInServiceTitle = data["docksInServiceTitle"] as! String
						let divvyLatitudeTitle = data["latitudeTitle"] as! String
						let divvyLongitudeTitle = data["longitudeTitle"] as! String
						let divvyStationNameTitle = data["stationNameTitle"] as! String
						let divvyStatusTitle = data["statusTitle"] as! String
						
						let divvyJSONUrl = data["divvyJSONUrl"] as! String
						let divvyJSONBikesAvailableTitle = data["divvyJSONBikesAvailableTitle"] as! String
						let divvyJSONEBikesAvailableTitle = data["divvyJSONEBikesAvailableTitle"] as! String
						let divvyJSONDocksAvailableTitle = data["divvyJSONDocksAvailableTitle"] as! String
						let divvyJSONDataTitle = data["divvyJSONDataTitle"] as! String
						let divvyJSONStationsTitle = data["divvyJSONStationsTitle"] as! String
						let divvyJSONIdTitle = data["divvyJSONIdTitle"] as! String
						let divvyJSONLastUpdatedTitle = data["divvyJSONLastUpdatedTitle"] as! String
						
						defaults.set(divvyDataset, forKey: "divvyDataset")
						defaults.set(divvyIdTitle, forKey: "divvyIdTitle")
						defaults.set(divvyDocksInServiceTitle, forKey: "divvyDocksInServiceTitle")
						defaults.set(divvyLatitudeTitle, forKey: "divvyLatitudeTitle")
						defaults.set(divvyLongitudeTitle, forKey: "divvyLongitudeTitle")
						defaults.set(divvyStationNameTitle, forKey: "divvyStationNameTitle")
						defaults.set(divvyStatusTitle, forKey: "divvyStatusTitle")
						
						defaults.set(divvyJSONUrl, forKey: "divvyJSONUrl")
						defaults.set(divvyJSONBikesAvailableTitle, forKey: "divvyJSONBikesAvailableTitle")
						defaults.set(divvyJSONEBikesAvailableTitle, forKey: "divvyJSONEBikesAvailableTitle")
						defaults.set(divvyJSONDocksAvailableTitle, forKey: "divvyJSONDocksAvailableTitle")
						defaults.set(divvyJSONDataTitle, forKey: "divvyJSONDataTitle")
						defaults.set(divvyJSONStationsTitle, forKey: "divvyJSONStationsTitle")
						defaults.set(divvyJSONIdTitle, forKey: "divvyJSONIdTitle")
						defaults.set(divvyJSONLastUpdatedTitle, forKey: "divvyJSONLastUpdatedTitle")
					}
				}
		}
		
		// Get relocated vehicles data
		db.collection(self.constants.relocatedDatabaseName)
			.limit(to: 1)
			.getDocuments() { (querySnapshot, err) in
				if let err = err {
					print("Could not get relocated vehicle data from Firebase: \(err)")
				} else {
					for document in querySnapshot!.documents {
						
						let data = document.data()
						
						let relocatedDataset = data["relocatedDataset"] as! String
						let relocatedColorTitle = data["colorTitle"] as! String
						let relocatedMakeTitle = data["makeTitle"] as! String
						let relocatedPlateTitle = data["plateTitle"] as! String
						let relocatedDateTitle = data["relocatedDateTitle"] as! String
						let relocatedFromLatitudeTitle = data["relocatedFromLatitudeTitle"] as! String
						let relocatedFromLongitudeTitle = data["relocatedFromLongitudeTitle"] as! String
						let relocatedFromAddressNumberTitle = data["relocatedFromAddressNumberTitle"] as! String
						let relocatedFromDirectionTitle = data["relocatedFromDirectionTitle"] as! String
						let relocatedFromStreetTitle = data["relocatedFromStreetTitle"] as! String
						let relocatedReasonTitle = data["relocatedReasonTitle"] as! String
						let relocatedToAddressNumberTitle = data["relocatedToAddressNumberTitle"] as! String
						let relocatedToDirectionTitle = data["relocatedToDirectionTitle"] as! String
						let relocatedToStreetTitle = data["relocatedToStreetTitle"] as! String
						let relocatedStateTitle = data["stateTitle"] as! String
						
						defaults.set(relocatedDataset, forKey: "relocatedDataset")
						defaults.set(relocatedColorTitle, forKey: "relocatedColorTitle")
						defaults.set(relocatedMakeTitle, forKey: "relocatedMakeTitle")
						defaults.set(relocatedPlateTitle, forKey: "relocatedPlateTitle")
						defaults.set(relocatedDateTitle, forKey: "relocatedDateTitle")
						defaults.set(relocatedFromLatitudeTitle, forKey: "relocatedFromLatitudeTitle")
						defaults.set(relocatedFromLongitudeTitle, forKey: "relocatedFromLongitudeTitle")
						defaults.set(relocatedFromAddressNumberTitle, forKey: "relocatedFromAddressNumberTitle")
						defaults.set(relocatedFromDirectionTitle, forKey: "relocatedFromDirectionTitle")
						defaults.set(relocatedFromStreetTitle, forKey: "relocatedFromStreetTitle")
						defaults.set(relocatedReasonTitle, forKey: "relocatedReasonTitle")
						defaults.set(relocatedToAddressNumberTitle, forKey: "relocatedToAddressNumberTitle")
						defaults.set(relocatedToDirectionTitle, forKey: "relocatedToDirectionTitle")
						defaults.set(relocatedToStreetTitle, forKey: "relocatedToStreetTitle")
						defaults.set(relocatedStateTitle, forKey: "relocatedStateTitle")
					}
				}
		}
		
		// Get towed vehicles data
		db.collection(self.constants.towedDatabaseName)
			.limit(to: 1)
			.getDocuments() { (querySnapshot, err) in
				if let err = err {
					print("Could not get towed vehicle data from Firebase: \(err)")
				} else {
					for document in querySnapshot!.documents {
						
						let data = document.data()
						
						let towedDataset = data["towedDataset"] as! String
						let towedColorTitle = data["colorTitle"] as! String
						let towedInventoryNumberTitle = data["inventoryNumberTitle"] as! String
						let towedMakeTitle = data["makeTitle"] as! String
						let towedModelTitle = data["modelTitle"] as! String
						let towedPlateTitle = data["plateTitle"] as! String
						let towedStateTitle = data["stateTitle"] as! String
						let towedStyleTitle = data["styleTitle"] as! String
						let towedDateTitle = data["towedDateTitle"] as! String
						let towedToAddressTitle = data["towedToAddressTitle"] as! String
						let towedToPhoneTitle = data["towedToPhoneTitle"] as! String
						
						defaults.set(towedDataset, forKey: "towedDataset")
						defaults.set(towedColorTitle, forKey: "towedColorTitle")
						defaults.set(towedInventoryNumberTitle, forKey: "towedInventoryNumberTitle")
						defaults.set(towedMakeTitle, forKey: "towedMakeTitle")
						defaults.set(towedModelTitle, forKey: "towedModelTitle")
						defaults.set(towedPlateTitle, forKey: "towedPlateTitle")
						defaults.set(towedStateTitle, forKey: "towedStateTitle")
						defaults.set(towedStyleTitle, forKey: "towedStyleTitle")
						defaults.set(towedDateTitle, forKey: "towedDateTitle")
						defaults.set(towedToAddressTitle, forKey: "towedToAddressTitle")
						defaults.set(towedToPhoneTitle, forKey: "towedToPhoneTitle")
					}
				}
		}
		
		let lastUpdatesViewDateString = self.updatesLastViewDate()
		if !lastUpdatesViewDateString.isEmpty {
		
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "M/dd/yyyy H:m:ss"
			dateFormatter.locale = .current
			let lastUpdatesViewDate = dateFormatter.date(from: lastUpdatesViewDateString)
		
			db.collection(self.constants.newsDatabaseName)
				.whereField("date", isGreaterThan: lastUpdatesViewDate!)
				.limit(to: 5)
				.getDocuments() { (querySnapshot, err) in
					if let err = err {
						print("Could not get updates from Firebase: \(err)")
					} else {
							
						let badgeCount = querySnapshot!.documents.count
						
						if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
							if let navigationController = rootViewController as? UINavigationController {
								if let tabBarController = navigationController.viewControllers[0] as? UITabBarController {
									tabBarController.tabBar.items?.last!.badgeValue = badgeCount > 0 ? "\(badgeCount)" : nil
								}
							}
						}
					}
			}
		}
		
		completion("Finished getting data from Firebase")
	}
	
    func deleteNotificationsFromDatabase(_ address: String, completion: @escaping (_ message: Bool) -> Void)
    {
        // Delete notification from database
        
        let db = Firestore.firestore()
        
        db.collection(self.constants.notificationsDatabaseName)
            .whereField("playerId", isEqualTo: self.notificationOneSignalPlayerId())
            .whereField("address", isEqualTo: address)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Could not get notifications from Firebase: \(err)")
                } else {
                                                
                    for document in querySnapshot!.documents {
                        document.reference.delete();
                    }
                    
                    completion(true)
                }
        }
    }
    
	func updateNotifications() {
		
		//let favoriteAddress = self.favoriteAddress()
		//let notificationsToggled = self.notificationsToggled()
		
        let favoriteViewController = FavoriteViewController()
        let favoriteAddresses = self.favoriteAddresses()
        let addresses = favoriteAddresses.filter { $0[0] != "" }
        
        for (_, element) in addresses.enumerated() {
            
            let address = element[0]
            let notificationsToggled = Bool(element[1])
            let notificationsWhen = element[2]
            let notificationsHour = Int(element[3]) ?? 0
            let notificationsMinute = Int(element[4]) ?? 0
            
            if notificationsToggled == true {
                favoriteViewController.getSchedule(true, true, address, notificationsWhen, notificationsHour, notificationsMinute)
            }
        }
        
//		if !favoriteAddress.isEmpty && notificationsToggled == true {
//			let favoriteViewController = FavoriteViewController()
//			favoriteViewController.getSchedule(true, true)
//		}
	}
    
    func goToScheduleFromNotification(_ address: String) {
        
        let schedule = ScheduleModel()
        
        // Set schedule address
        schedule.address = address
        
        // Get coordinates from address
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            
            // No internet connection will cause an error
            if error != nil {
                //self.common.showAlert(self.common.constants.errorTitle, self.common.constants.noInternetConnectionSearchMessage)
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
                schedule.locationCoordinate = coordinates
                
                // Create SODA client using domain and token
                let wardClient = SODAClient(domain: self.constants.SODADomain, token: self.constants.SODAToken)
                
                // Query SODA API to get ward and section
                let wardQuery = wardClient.query(dataset: self.wardDataset())
                    .filter("intersects(\(self.geomTitle()),'POINT(\(schedule.locationCoordinate.longitude) \(schedule.locationCoordinate.latitude))')")
                    .limit(1)
                
                wardQuery.get { res in
                    switch res {
                    case .dataset (let data):
                        
                        if data.count > 0 {
                            
                            // Get values from json query
                            let ward = data[0][self.wardTitle()] as? String ?? ""
                            let section = data[0][self.sectionTitle()] as? String ?? ""
                            let the_geom = data[0][self.geomTitle()] as? [String: Any] ?? [:]
                            let coordinatesWrapper = the_geom[self.coordinatesTitle()] as? NSMutableArray
                            let coordinatesArray = coordinatesWrapper?[0] as? [[NSMutableArray]]
                            
                            // Loop through coordinates array
                            for(_, coordinate) in coordinatesArray!.enumerated() {
                                
                                // Loop through each pair of coordinates
                                for item in coordinate {
                                    
                                    // Create coorindate from lat and long in array
                                    var coordinate = CLLocationCoordinate2D()
                                    coordinate.longitude = item[0] as? Double ?? 0
                                    coordinate.latitude = item[1] as? Double ?? 0
                                    
                                    // Add coordinates to schedule polygon coordinates
                                    schedule.polygonCoordinates.append(coordinate)
                                    
                                }
                            }
                            
                            // Set schedule ward and section
                            schedule.ward = ward
                            schedule.section = String(section).trimmingCharacters(in: .whitespaces)
                            
                            // Query SODA API to get months and days
                            let scheduleQuery = wardClient.query(dataset: self.scheduleDataset())
                                .filter("\(self.wardTitle()) = '\(ward)' \(section != "" ? "AND \(self.sectionTitle()) = '\(section)'" : "") ")
                                .orderAscending(self.monthNumberTitle())
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        // Loop through months
                                        for (_, item) in data.enumerated() {
                                            
                                            // Get values from json data
                                            let monthName = item[self.monthNameTitle()] as? String ?? ""
                                            let monthNumber = item[self.monthNumberTitle()] as? String ?? ""
                                            let dates = item[self.dates()] as? String ?? ""
                                            let datesArray = dates.components(separatedBy: ",").sorted {$0.localizedStandardCompare($1) == .orderedAscending}
                                            
                                            // Create month object
                                            let month = MonthModel()
                                            month.name = monthName
                                            month.number = monthNumber
                                            
                                            // Loop through dates
                                            for day in datesArray {
                                                                                                
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
                                            schedule.months.append(month)
                                            
                                        }
                                                                                
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        if let destinationViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
                                            destinationViewController.schedule = schedule
                                            
                                            let navigationController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
                                            
                                            if let tabBarController = navigationController.viewControllers[0] as? UITabBarController {
                                                tabBarController.selectedIndex = 0
                                            }
                                            
                                            navigationController.pushViewController(destinationViewController, animated: true)
                                        }
                                
                                    }
                                case .error (let err):
                                    print("searchForSchedule Unable to get schedule data from the City of Chicago: \(err.localizedDescription)")
                                }
                            }
                        }
                        else {
                        }
                    case .error (let err):
                        print("searchForSchedule Unable to get ward data from the City of Chicago: \(err.localizedDescription)")
                    }
                }
            }
            else {
            }
        }
    }
	
	// Alert with custom title and message
	func showAlert(_ title: String, _ message: String) {
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		
		var rootViewController = UIApplication.shared.keyWindow?.rootViewController
		
		if let navigationController = rootViewController as? UINavigationController {
			rootViewController = navigationController.viewControllers.first
		}
		
		rootViewController?.present(alert, animated: true, completion: nil)
		
		return
		
	}
	
	// Style button with image and background color
	func styleButton(_ button: UIButton, _ image: String?, _ color: String? = nil) {
		
		button.backgroundColor = .systemBlue
		if color != nil {
			button.backgroundColor = UIColor(hexString: "\(color!)")
		}
		button.layer.cornerRadius = 7.0
		button.tintColor = .white
		
		if image != nil {
			button.leftImage(image: UIImage(named: image!)!, name: image)
		}
	}

	func UTCToLocal(date:String) -> String {
		
		let dateFormatter = DateFormatter()
		//dateFormatter.dateFormat = "MM/dd/yyyy"
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		
		let dt = dateFormatter.date(from: date)
		dateFormatter.timeZone = TimeZone.current
		dateFormatter.dateFormat = "MM/dd/yyyy"
		
		return dateFormatter.string(from: dt!)
	}
    
}

// MARK: Extensions

extension UIImage {
	
	func imageWithSize(scaledToSize newSize: CGSize) -> UIImage {
		
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
		self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
		let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return newImage
	}
	
}

// Capitalize first lett of month name
extension String {
    
	func capitalizingFirstLetter() -> String {
		return prefix(1).capitalized + dropFirst()
	}
	
	mutating func capitalizeFirstLetter() {
		self = self.capitalizingFirstLetter()
	}
}

extension Date {
	
	func daysBetween(date: Date) -> Int {
		return Date.daysBetween(start: self, end: date)
	}
	
	static func daysBetween(start: Date, end: Date) -> Int {
		let calendar = Calendar.current
		
		// Replace the hour (time) of both dates with 00:00
		let date1 = calendar.startOfDay(for: start)
		let date2 = calendar.startOfDay(for: end)
		
		let a = calendar.dateComponents([.day], from: date1, to: date2)
		return a.value(for: .day)!
	}
	
	var month: String {
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMMM"
		return dateFormatter.string(from: self)
		
	}
	
	static func getFormattedDate(_ date: String,_ inputFormat: String,_ outputFormat: String = "MM/dd/yyyy") -> String {
		
		let dateFormatterGet = DateFormatter()
		dateFormatterGet.dateFormat = inputFormat //"yyyy-MM-dd'T'HH:mm:ss.SSS"
		
		let dateFormatterPrint = DateFormatter()
		dateFormatterPrint.dateFormat = outputFormat //"MM/dd/yyyy"
		dateFormatterPrint.timeZone = TimeZone.current
		
		let date: Date? = dateFormatterGet.date(from: date)
		
		if (date == nil) {
			return ""
		}
		
		return dateFormatterPrint.string(from: date!);
	}
}

// Enable the use of hex strings to color views
extension UIColor {
	
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
		
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
		
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
		
    }
	
    func toHexString() -> String {
		
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
		
    }
}

public extension UIButton {
    
    // Add image on left of button
    func leftImage(image: UIImage, name: String?) {
        self.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image.size.width)
    }
}

public enum Model : String {
	
	//Simulator
	case simulator     = "simulator/sandbox",
	
	//iPod
	iPod1              = "iPod 1",
	iPod2              = "iPod 2",
	iPod3              = "iPod 3",
	iPod4              = "iPod 4",
	iPod5              = "iPod 5",
    iPod6              = "iPod 6",
    iPod7              = "iPod 7",
	
	//iPad
	iPad2              = "iPad 2",
	iPad3              = "iPad 3",
	iPad4              = "iPad 4",
	iPadAir            = "iPad Air ",
	iPadAir2           = "iPad Air 2",
	iPadAir3           = "iPad Air 3",
	iPad5              = "iPad 5", //iPad 2017
	iPad6              = "iPad 6", //iPad 2018
    iPad7              = "iPad 7", //iPad 2019
    iPad8              = "iPad 8", //iPad 2020
	
	//iPad Mini
	iPadMini           = "iPad Mini",
	iPadMini2          = "iPad Mini 2",
	iPadMini3          = "iPad Mini 3",
	iPadMini4          = "iPad Mini 4",
	iPadMini5          = "iPad Mini 5",
	
	//iPad Pro
	iPadPro9_7         = "iPad Pro 9.7\"",
	iPadPro10_5        = "iPad Pro 10.5\"",
	iPadPro11          = "iPad Pro 11\"",
	iPadPro12_9        = "iPad Pro 12.9\"",
	iPadPro2_12_9      = "iPad Pro 2 12.9\"",
	iPadPro3_12_9      = "iPad Pro 3 12.9\"",
	
	//iPhone
	iPhone4            = "iPhone 4",
	iPhone4S           = "iPhone 4S",
	iPhone5            = "iPhone 5",
	iPhone5S           = "iPhone 5S",
	iPhone5C           = "iPhone 5C",
	iPhone6            = "iPhone 6",
	iPhone6Plus        = "iPhone 6 Plus",
	iPhone6S           = "iPhone 6S",
	iPhone6SPlus       = "iPhone 6S Plus",
	iPhoneSE           = "iPhone SE",
	iPhone7            = "iPhone 7",
	iPhone7Plus        = "iPhone 7 Plus",
	iPhone8            = "iPhone 8",
	iPhone8Plus        = "iPhone 8 Plus",
	iPhoneX            = "iPhone X",
	iPhoneXS           = "iPhone XS",
	iPhoneXSMax        = "iPhone XS Max",
	iPhoneXR           = "iPhone XR",
	iPhone11           = "iPhone 11",
	iPhone11Pro        = "iPhone 11 Pro",
	iPhone11ProMax     = "iPhone 11 Pro Max",
    iPhoneSE2          = "iPhone SE 2nd gen",
    iPhone12Mini       = "iPhone 12 Mini",
    iPhone12           = "iPhone 12",
    iPhone12Pro        = "iPhone 12 Pro",
    iPhone12ProMax     = "iPhone 12 Pro Max",

	unrecognized       = "?unrecognized?"
}

public extension UIDevice {
	
	var type: Model {
		var systemInfo = utsname()
		uname(&systemInfo)
		let modelCode = withUnsafePointer(to: &systemInfo.machine) {
			$0.withMemoryRebound(to: CChar.self, capacity: 1) {
				ptr in String.init(validatingUTF8: ptr)
			}
		}
		
		let modelMap : [String: Model] = [
			
			//Simulator
			"i386"      : .simulator,
			"x86_64"    : .simulator,
			
			//iPod
			"iPod1,1"   : .iPod1,
			"iPod2,1"   : .iPod2,
			"iPod3,1"   : .iPod3,
			"iPod4,1"   : .iPod4,
			"iPod5,1"   : .iPod5,
            "iPod7,1"   : .iPod6,
            "iPod9,1"   : .iPod7,
			
			//iPad
			"iPad2,1"   : .iPad2,
			"iPad2,2"   : .iPad2,
			"iPad2,3"   : .iPad2,
			"iPad2,4"   : .iPad2,
			"iPad3,1"   : .iPad3,
			"iPad3,2"   : .iPad3,
			"iPad3,3"   : .iPad3,
			"iPad3,4"   : .iPad4,
			"iPad3,5"   : .iPad4,
			"iPad3,6"   : .iPad4,
			"iPad4,1"   : .iPadAir,
			"iPad4,2"   : .iPadAir,
			"iPad4,3"   : .iPadAir,
			"iPad5,3"   : .iPadAir2,
			"iPad5,4"   : .iPadAir2,
			"iPad6,11"  : .iPad5, //iPad 2017
			"iPad6,12"  : .iPad5,
			"iPad7,5"   : .iPad6, //iPad 2018
			"iPad7,6"   : .iPad6,
            "iPad7,11"  : .iPad7, //iPad 2019
            "iPad7,12"  : .iPad7,
            "iPad11,6"  : .iPad8, //iPad 2020
            "iPad11,7"  : .iPad8,
			
			//iPad Mini
			"iPad2,5"   : .iPadMini,
			"iPad2,6"   : .iPadMini,
			"iPad2,7"   : .iPadMini,
			"iPad4,4"   : .iPadMini2,
			"iPad4,5"   : .iPadMini2,
			"iPad4,6"   : .iPadMini2,
			"iPad4,7"   : .iPadMini3,
			"iPad4,8"   : .iPadMini3,
			"iPad4,9"   : .iPadMini3,
			"iPad5,1"   : .iPadMini4,
			"iPad5,2"   : .iPadMini4,
			"iPad11,1"  : .iPadMini5,
			"iPad11,2"  : .iPadMini5,
			
			//iPad Pro
			"iPad6,3"   : .iPadPro9_7,
			"iPad6,4"   : .iPadPro9_7,
			"iPad7,3"   : .iPadPro10_5,
			"iPad7,4"   : .iPadPro10_5,
			"iPad6,7"   : .iPadPro12_9,
			"iPad6,8"   : .iPadPro12_9,
			"iPad7,1"   : .iPadPro2_12_9,
			"iPad7,2"   : .iPadPro2_12_9,
			"iPad8,1"   : .iPadPro11,
			"iPad8,2"   : .iPadPro11,
			"iPad8,3"   : .iPadPro11,
			"iPad8,4"   : .iPadPro11,
			"iPad8,5"   : .iPadPro3_12_9,
			"iPad8,6"   : .iPadPro3_12_9,
			"iPad8,7"   : .iPadPro3_12_9,
			"iPad8,8"   : .iPadPro3_12_9,
			
			//iPad Air
			"iPad11,3"  : .iPadAir3,
			"iPad11,4"  : .iPadAir3,
			
			//iPhone
			"iPhone3,1" : .iPhone4,
			"iPhone3,2" : .iPhone4,
			"iPhone3,3" : .iPhone4,
			"iPhone4,1" : .iPhone4S,
			"iPhone5,1" : .iPhone5,
			"iPhone5,2" : .iPhone5,
			"iPhone5,3" : .iPhone5C,
			"iPhone5,4" : .iPhone5C,
			"iPhone6,1" : .iPhone5S,
			"iPhone6,2" : .iPhone5S,
			"iPhone7,1" : .iPhone6Plus,
			"iPhone7,2" : .iPhone6,
			"iPhone8,1" : .iPhone6S,
			"iPhone8,2" : .iPhone6SPlus,
			"iPhone8,4" : .iPhoneSE,
			"iPhone9,1" : .iPhone7,
			"iPhone9,3" : .iPhone7,
			"iPhone9,2" : .iPhone7Plus,
			"iPhone9,4" : .iPhone7Plus,
			"iPhone10,1" : .iPhone8,
			"iPhone10,4" : .iPhone8,
			"iPhone10,2" : .iPhone8Plus,
			"iPhone10,5" : .iPhone8Plus,
			"iPhone10,3" : .iPhoneX,
			"iPhone10,6" : .iPhoneX,
			"iPhone11,2" : .iPhoneXS,
			"iPhone11,4" : .iPhoneXSMax,
			"iPhone11,6" : .iPhoneXSMax,
			"iPhone11,8" : .iPhoneXR,
			"iPhone12,1" : .iPhone11,
			"iPhone12,3" : .iPhone11Pro,
			"iPhone12,5" : .iPhone11ProMax,
            "iPhone12,8" : .iPhoneSE2,
            "iPhone13,1" : .iPhone12Mini,
            "iPhone13,2" : .iPhone12,
            "iPhone13,3" : .iPhone12Pro,
            "iPhone13,4" : .iPhone12ProMax
		]
		
		if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
			if model == .simulator {
				if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
					if let simModel = modelMap[String.init(validatingUTF8: simModelCode)!] {
						return simModel
					}
				}
			}
			return model
		}
		return Model.unrecognized
	}
}

