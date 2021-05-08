import UIKit
import MapKit
import Alamofire

let defaults = UserDefaults.standard

class Common {
    
    let constants = Constants()
    
    //MARK: Defaults
    
    // Shared
    
    func deviceUUID() -> String { return defaults.string(forKey: "deviceUUID") ?? ""}
    func latestAppVersion() -> Int { return defaults.integer(forKey: "latestAppVersion")}
    func latestDatasetVersion() -> Int {return defaults.integer(forKey: "latestDatasetVersion")}
    func userDatasetVersion() -> Int {return defaults.integer(forKey: "userDatasetVersion")}
    func enableMultipleAddresses() -> Bool {return defaults.bool(forKey: "enableMultipleAddresses")}
    func gettingValuesFromDatabase() -> Bool {return defaults.bool(forKey: "gettingValuesFromDatabase")}
    
    func defaultAddress() -> String {return defaults.string(forKey: "defaultAddress") ?? ""}
    func defaultLongitude() -> Double {return defaults.double(forKey: "defaultLongitude")}
    func defaultLatitude() -> Double {return defaults.double(forKey: "defaultLatitude")}
    func defaultCoordinatesArray() -> [[NSArray]] {return defaults.object(forKey: "defaultCoordinatesArray") as! [[NSArray]]}
    func selectedAnnotationLongitude() -> Double {return defaults.double(forKey: "selectedAnnotationLongitude")}
    func selectedAnnotationLatitude() -> Double {return defaults.double(forKey: "selectedAnnotationLatitude")}
        
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
    func showDivvyStations() -> Bool {return defaults.bool(forKey: "showDivvyStations")}
    func showTowedVehicles() -> Bool {return defaults.bool(forKey: "showTowedVehicles")}
    
    // Notifications
    
    func notificationWhen() -> String {return defaults.string(forKey: "notificationWhen") ?? ""}
    func notificationHour() -> Int {return defaults.integer(forKey: "notificationHour")}
    func notificationMinute() -> Int {return defaults.integer(forKey: "notificationMinute")}
    func notificationsToggled() -> Bool {return defaults.bool(forKey: "notificationsToggled")}
    func notificationsYear() -> Int {return defaults.integer(forKey: "notificationsYear")}
    func notificationOneSignalPlayerId() -> String {return defaults.string(forKey: "notificationOneSignalPlayerId") ?? ""}
    
    // Updates
    
    func updatesLastViewDate() -> String {return defaults.string(forKey: "updatesLastViewDate") ?? ""}
    
    //MARK: Constants
    
    class Constants {
        
        // Database tables
        #if DEBUG
        let debugMode = true
        let addressesDatabaseName = "addresses_dev"
        let schedulesDatabaseName = "schedules_dev"
        let updatesDatabaseName = "updates_dev"
        let divvysDatabaseName = "divvys_dev"
        let towedDatabaseName = "towed_vehicles_dev"
        let relocatedDatabaseName = "relocated_vehicles_dev"
        let newsDatabaseName = "news_dev"
        let infoDatabaseName = "info_dev"
        let notificationsDatabaseName = "notifications_dev"
        #else
        let debugMode = false
        let addressesDatabaseName = "addresses"
        let schedulesDatabaseName = "schedules"
        let updatesDatabaseName = "updates"
        let divvysDatabaseName = "divvys"
        let towedDatabaseName = "towed_vehicles"
        let relocatedDatabaseName = "relocated_vehicles"
        let newsDatabaseName = "news"
        let infoDatabaseName = "info"
        let notificationsDatabaseName = "notifications"
        #endif
        
        // One Signal
        let OneSignalAppId = "2a6b2ed6-b4a7-4da0-8917-899cef558a0a"
        
        // Multiple addresses in-app purchase
        let multipleAddressIAPurchase = "com.kylebeverforden.chisweeptracker.savemultipleaddresses"
        
        // SODA
        let SODAToken = "dM3SUsRUNwyTWQGy83lvBv4X3"
        let SODADomain = "data.cityofchicago.org"
        
        // Strings
        let websiteURL = "https://chicagosweeptracker.info"
        
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
    
    func displayNewOrUpdatedScheduleAlerts() {
        
        let latestDatasetVersion = self.latestDatasetVersion()
        let userDatasetVersion = self.userDatasetVersion()
        let notificationsYear = self.notificationsYear()
        let latestAppVersion = self.latestAppVersion()
        
        // Set the latest dataset version when notifications were updated
        // Use the value to alert them if they loaded the app after Chicago changed the schedule
        if userDatasetVersion != 0 && userDatasetVersion < latestDatasetVersion && notificationsYear == latestAppVersion {
            
            // Create dataset updated alert
            let datasetUpdatedAlert = UIAlertController(title: "Notifications Updated", message: "Chicago has changed the \(latestAppVersion) schedule and your push notifications have been automatically updated if you have them enabled.", preferredStyle: .alert)
            
            // Create and add OK option for dataset updated alert
            datasetUpdatedAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            var rootViewController = UIApplication.shared.keyWindow?.rootViewController
            
            if let navigationController = rootViewController as? UINavigationController {
                rootViewController = navigationController.viewControllers.first
            }
            
            // Present dataset updated alert
            rootViewController?.present(datasetUpdatedAlert, animated: true, completion: nil)
            
        }
        defaults.set(latestDatasetVersion, forKey: "userDatasetVersion")
        
        // Set the last year when notifications were updated.
        // Use the value to alert them if they loaded the app after a new year came out
        if notificationsYear != 0 && notificationsYear < latestAppVersion {
            self.showAlert("Notifications Updated", "Chicago has released the \(latestAppVersion) schedule and your push notifications have been automatically updated if you have them enabled.")
        }
        defaults.set(latestAppVersion, forKey: "notificationsYear")
        
    }
    
    func deleteNotificationsFromDatabase(_ address: String, _ tableName: String, completion: @escaping (_ message: Bool) -> Void) {
        let urlTo = self.constants.websiteURL + "/delete-notification.php"
        let parameters = ["playerId": self.notificationOneSignalPlayerId(),
                          "address": address,
                          "tableName": tableName] as [String : String]
        
        AF.request(urlTo, method: .post, parameters: parameters).validate().response() { response in
            completion(true)
        }
    }
    
    func getAddresses(address: String = "", completion: @escaping (_ message: [AddressModel]) -> ()) {
        
        var addresses = [AddressModel]()
        var parameters = [String: String]()
        let urlTo = self.constants.websiteURL + "/get-address-data.php"
        
        if address == "" {
            parameters = ["tableName": self.constants.addressesDatabaseName, "uuid": self.deviceUUID()]
        }
        else {
            parameters = ["tableName": self.constants.addressesDatabaseName, "uuid": self.deviceUUID(), "address": address]
        }
        
        AF.request(urlTo, parameters: parameters).validate().responseJSON() { response in
            switch response.result {
            case .failure(let error):
                print(error)
                completion(addresses)
            case .success:
                if let value = response.data {
                    
                    let json =  (try? JSONSerialization.jsonObject(with: value)) as! [[String: String]]
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "M/dd/yyyy"
//                    dateFormatter.dateStyle = .short
//                    dateFormatter.timeStyle = .none
//                    dateFormatter.timeZone = TimeZone(abbreviation: "CDT")
                    
                    for item in json.enumerated() {
                        
                        let address = AddressModel()
                        address.address = item.element["address"]!
                        address.notificationsEnabled = item.element["notificationsEnabled"]!
                        address.notificationsWhen = item.element["notificationsWhen"]!
                        address.notificationsHour = item.element["notificationsHour"]!
                        address.notificationsMinute = item.element["notificationsMinute"]!
                        
                        let nextSweepDay = item.element["nextSweepDay"]!
                        if nextSweepDay != "" {
                            address.nextSweepDay = dateFormatter.date(from: nextSweepDay)!
                        }
                        
                        addresses.append(address)
                    }
                    
                    completion(addresses)
                }
            }
        }
    }
    
//    func getAddressNotificationCount(uuid: String, completion: @escaping (_ message: Int) -> ()) {
//        
//        let urlTo = self.constants.websiteURL + "/get-address-notification-count.php"
//        let parameters = ["tableName": self.constants.addressesDatabaseName, "uuid": self.deviceUUID()]
//
//        AF.request(urlTo, parameters: parameters).validate().responseJSON() { response in
//            switch response.result {
//            case .failure(let error):
//                print(error)
//                completion(0)
//            case .success(let count as Int):
//                completion(count)
//            default:
//                completion(0)
//            }
//        }
//    }
    
    
    func getNextSweepDay(address: String, completion: @escaping (Date?) -> ()) {
        
        let schedule = ScheduleModel()
        var sweepDates = [Date]()
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentDay = Calendar.current.component(.day, from: Date())

        //schedule.address = address
        
        // Get coordinates from address
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            
            // No internet connection will cause an error
            if error != nil {
                completion(nil)
            }
            
            if placemarks != nil {
            
                // Get first placemark in list
                let placemark = placemarks?.first
                
                // Create coorindates from placemark
                var coordinates = CLLocationCoordinate2D()
                coordinates.latitude = placemark?.location?.coordinate.latitude ?? 0
                coordinates.longitude = placemark?.location?.coordinate.longitude ?? 0
                
                // Set schedule location coordinates
                //schedule.locationCoordinate = coordinates
                                
                // Create SODA client using domain and token
                let wardClient = SODAClient(domain: self.constants.SODADomain, token: self.constants.SODAToken)
                
                // Query SODA API to get ward and section
                let wardQuery = wardClient.query(dataset: self.wardDataset())
                    .filter("intersects(\(self.geomTitle()),'POINT(\(coordinates.longitude) \(coordinates.latitude))')")
                    .limit(1)
                
                wardQuery.get { res in
                    switch res {
                    case .dataset (let data):
                        
                        if data.count > 0 {
                            
                            // Get values from json query
                            let ward = data[0][self.wardTitle()] as? String ?? ""
                            let section = data[0][self.sectionTitle()] as? String ?? ""
                            
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
                                             
                                        for month in schedule.months {
                                            
                                            for date in month.dates {
                                            
                                                if Int(month.number)! > currentMonth ||
                                                    Int(month.number) == currentMonth && date.date >= currentDay {
                                                
                                                    // Specify date components
                                                    var dateComponents = DateComponents()
                                                    dateComponents.year = self.latestAppVersion()
                                                    dateComponents.month = Int(month.number)
                                                    dateComponents.day = date.date

                                                    // Create date from components
                                                    let userCalendar = Calendar(identifier: .gregorian)
                                                    let sweepDay = userCalendar.date(from: dateComponents)
                                                    sweepDates.append(sweepDay!)
                                                    
                                                }
                                            }
                                        }
                                        
                                        if let nextSweepDay = sweepDates.min() {
                                            completion(nextSweepDay)
                                        }
                                        else {
                                            completion(nil)
                                        }
                                    }
                                    else {
                                        completion(nil)
                                    }
                                case .error (let err):
                                    print("searchForSchedule Unable to get schedule data from the City of Chicago: \(err.localizedDescription)")
                                    completion(nil)
                                }
                            }
                        }
                    case .error (let err):
                        print("searchForSchedule Unable to get ward data from the City of Chicago: \(err.localizedDescription)")
                        completion(nil)
                    }
                }
            }
            else {
                completion(nil)
            }
        }
    }
    
    func deleteAddressFromDatabase(address: String, deleteAddressResult: @escaping (Bool) -> Void) {
        let urlTo = self.constants.websiteURL + "/delete-address.php"
        let parameters = ["tableName": self.constants.addressesDatabaseName,
                          "uuid": self.deviceUUID(),
                          "address": address] as [String : Any]
        
        AF.request(urlTo, method: .post, parameters: parameters).validate().response() { response in
            self.deleteNotificationsFromDatabase(address, self.constants.notificationsDatabaseName, completion: {completion in
                deleteAddressResult(completion)
            })
        }
    }
    
    func insertAddressIntoDatabase(address: String,
                                   notificationsEnabled: Int,
                                   notificationsWhen: String,
                                   notificationsHour: Int,
                                   notificationsMinute: Int,
                                   completion: @escaping (Bool) -> Void) {
        
        self.getNextSweepDay(address: address, completion: { date in
            
            var nextSweepDayFormatted = ""
            
            if date != nil {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: date!)
                nextSweepDayFormatted = "\(components.month!)/\(components.day!)/\(components.year!)"
            }
        
            let urlTo = self.constants.websiteURL + "/insert-address.php"
            let parameters = ["tableName": self.constants.addressesDatabaseName,
                              "uuid": self.deviceUUID(),
                              "address": address,
                              "notificationsWhen": notificationsWhen,
                              "notificationsHour": notificationsHour,
                              "notificationsMinute": notificationsMinute,
                              "notificationsEnabled": notificationsEnabled,
                              "nextSweepDay": nextSweepDayFormatted] as [String : Any]
            
            AF.request(urlTo, method: .post, parameters: parameters).validate().response() { response in
                completion(true)
            }
        })
    }
    
    func getValuesFromDatabase(completion: @escaping (_ message: String) -> Void) {
        
        defaults.setValue(true, forKey: "gettingValuesFromDatabase")
        
        // Get schedule data
        AF.request(self.constants.websiteURL + "/get-schedule-data.php", parameters: ["tableName": self.constants.schedulesDatabaseName]).validate().responseJSON() { response in
            switch response.result {
            case .failure(let error):
                print(error)
            case .success:
                if let value = response.data {
                    
                    let json = (try? JSONSerialization.jsonObject(with: value)) as! [[String: String]]
                    let schedule = json.first!
                    
                    let latestAppVersionString = schedule["year"]
                    let latestAppVersion = Int(latestAppVersionString!)
                    let wardDataset = schedule["wardDataset"]
                    let scheduleDataset = schedule["scheduleDataset"]
                    let coordinatesTitle = schedule["coordinatesTitle"]
                    let datesTitle = schedule["datesTitle"]
                    let geomTitle = schedule["geomTitle"]
                    let monthNameTitle = schedule["monthNameTitle"]
                    let monthNumberTitle = schedule["monthNumberTitle"]
                    let sectionTitle = schedule["sectionTitle"]
                    let wardTitle = schedule["wardTitle"]
                    
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
                    
                    AF.request(self.constants.websiteURL + "/get-update-data.php", parameters: ["tableName": self.constants.updatesDatabaseName, "year": String(self.latestAppVersion())]).validate().responseJSON() { response in
                        switch response.result {
                        case .failure(let error):
                            print(error)
                        case .success:
                            if let value = response.data {
                                
                                let json = (try? JSONSerialization.jsonObject(with: value)) as! [[String: String]]
                                let update = json.first!
                                
                                let latestDatasetVersionString = update["version"]
                                let latestDatasetVersion = Int(latestDatasetVersionString!)
                                
                                defaults.set(latestDatasetVersion, forKey: "latestDatasetVersion")
                                
                                DispatchQueue.main.async {
                                    self.updateNotifications()
                                    self.displayNewOrUpdatedScheduleAlerts()
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Get Divvys data
        AF.request(self.constants.websiteURL + "/get-divvy-data.php", parameters: ["tableName": self.constants.divvysDatabaseName]).validate().responseJSON() { response in
            switch response.result {
            case .failure(let error):
                print(error)
            case .success:
                if let value = response.data {
                    
                    let json = (try? JSONSerialization.jsonObject(with: value)) as! [[String: String]]
                    let divvy = json.first!
                    
                    let divvyDataset = divvy["divvyDataset"]
                    let divvyIdTitle = divvy["idTitle"]
                    let divvyDocksInServiceTitle = divvy["docksInServiceTitle"]
                    let divvyLatitudeTitle = divvy["latitudeTitle"]
                    let divvyLongitudeTitle = divvy["longitudeTitle"]
                    let divvyStationNameTitle = divvy["stationNameTitle"]
                    let divvyStatusTitle = divvy["statusTitle"]
                    
                    let divvyJSONUrl = divvy["divvyJSONUrl"]
                    let divvyJSONBikesAvailableTitle = divvy["divvyJSONBikesAvailableTitle"]
                    let divvyJSONEBikesAvailableTitle = divvy["divvyJSONEBikesAvailableTitle"]
                    let divvyJSONDocksAvailableTitle = divvy["divvyJSONDocksAvailableTitle"]
                    let divvyJSONDataTitle = divvy["divvyJSONDataTitle"]
                    let divvyJSONStationsTitle = divvy["divvyJSONStationsTitle"]
                    let divvyJSONIdTitle = divvy["divvyJSONIdTitle"]
                    let divvyJSONLastUpdatedTitle = divvy["divvyJSONLastUpdatedTitle"]
                    
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
        AF.request(self.constants.websiteURL + "/get-data.php", parameters: ["tableName": self.constants.relocatedDatabaseName]).validate().responseJSON() { response in
            switch response.result {
            case .failure(let error):
                print(error)
            case .success:
                if let value = response.data {
                    
                    let json = (try? JSONSerialization.jsonObject(with: value)) as! [[String: String]]
                    let relocated = json.first!
                    
                    let relocatedDataset = relocated["relocatedDataset"]
                    let relocatedColorTitle = relocated["colorTitle"]
                    let relocatedMakeTitle = relocated["makeTitle"]
                    let relocatedPlateTitle = relocated["plateTitle"]
                    let relocatedDateTitle = relocated["relocatedDateTitle"]
                    let relocatedFromLatitudeTitle = relocated["relocatedFromLatitudeTitle"]
                    let relocatedFromLongitudeTitle = relocated["relocatedFromLongitudeTitle"]
                    let relocatedFromAddressNumberTitle = relocated["relocatedFromAddressNumberTitle"]
                    let relocatedFromDirectionTitle = relocated["relocatedFromDirectionTitle"]
                    let relocatedFromStreetTitle = relocated["relocatedFromStreetTitle"]
                    let relocatedReasonTitle = relocated["relocatedReasonTitle"]
                    let relocatedToAddressNumberTitle = relocated["relocatedToAddressNumberTitle"]
                    let relocatedToDirectionTitle = relocated["relocatedToDirectionTitle"]
                    let relocatedToStreetTitle = relocated["relocatedToStreetTitle"]
                    let relocatedStateTitle = relocated["stateTitle"]
                    
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
        AF.request(self.constants.websiteURL + "/get-data.php", parameters: ["tableName": self.constants.towedDatabaseName]).validate().responseJSON() { response in
            switch response.result {
            case .failure(let error):
                print(error)
            case .success:
                if let value = response.data {
                    
                    let json = (try? JSONSerialization.jsonObject(with: value)) as! [[String: String]]
                    let towed = json.first!
                    
                    let towedDataset = towed["towedDataset"]
                    let towedColorTitle = towed["colorTitle"]
                    let towedInventoryNumberTitle = towed["inventoryNumberTitle"]
                    let towedMakeTitle = towed["makeTitle"]
                    let towedModelTitle = towed["modelTitle"]
                    let towedPlateTitle = towed["plateTitle"]
                    let towedStateTitle = towed["stateTitle"]
                    let towedStyleTitle = towed["styleTitle"]
                    let towedDateTitle = towed["towedDateTitle"]
                    let towedToAddressTitle = towed["towedToAddressTitle"]
                    let towedToPhoneTitle = towed["towedToPhoneTitle"]
                    
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
        
        //        let lastUpdatesViewDateString = self.updatesLastViewDate()
        //        if !lastUpdatesViewDateString.isEmpty {
        //
        //            let dateFormatter = DateFormatter()
        //            //dateFormatter.locale = .current
        //            dateFormatter.timeZone = .current
        //            //dateFormatter.dateFormat = "M/dd/yyyy H:m:ss"
        //
        //            getRequest(self.constants.websiteURL + "/get-news-data.php", parameters: ["tableName": self.constants.newsDatabaseName]) { responseObject, error in
        //                guard let response = responseObject, error == nil else {
        //                    print(error ?? "Unknown error")
        //                    return
        //                }
        //
        //                if response.count > 0 {
        //
        //                    var newCount = 0
        //
        //                    for update in response.enumerated() {
        //
        //                        let date = update.element["date"] as! String
        //                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //                        let dateFormattedDate = dateFormatter.date(from: date)
        //                        let dateFormattedString = dateFormatter.string(from: dateFormattedDate!)
        //
        //                        dateFormatter.dateFormat = "M/dd/yyyy HH:mm:ss"
        //
        //                        let lastUpdatesViewDate = dateFormatter.date(from: lastUpdatesViewDateString)!
        //                        let lastUpdatesViewDateString2 = dateFormatter.string(from: lastUpdatesViewDate)
        //
        //                        print(date)
        //                        print(dateFormattedDate!)
        //                        print(dateFormattedString)
        //                        print(lastUpdatesViewDate)
        //                        print(lastUpdatesViewDateString2)
        //
        //
        //
        //
        //                        //if dateFormatted > lastUpdatesViewDate {
        //                            newCount += 1
        //                        //}
        //                    }
        //
        //                    DispatchQueue.main.async {
        //                        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
        //                            if let navigationController = rootViewController as? UINavigationController {
        //                                if let tabBarController = navigationController.viewControllers[0] as? UITabBarController {
        //                                    tabBarController.tabBar.items?.last!.badgeValue = newCount > 0 ? "\(newCount)" : nil
        //                                }
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        
        
        completion("Finished getting data from database")
    }
    
    // Do not remove. This code is required for old users migrating to the new app with multiple address
    func migrateOldUsersToUseDatabase(completion: @escaping (_ completion: Bool) -> Void) {
    
        let favoriteAddress = self.favoriteAddress()
        
        if favoriteAddress != "" {
                
            // insert address into database
            self.insertAddressIntoDatabase(address: favoriteAddress,
                                           notificationsEnabled: self.notificationsToggled() ? 1 : 0,
                                           notificationsWhen: self.notificationWhen(),
                                           notificationsHour: self.notificationHour(),
                                           notificationsMinute: self.notificationMinute(),
                                           completion: { result in
                                            
                                            // Clear the old favorite address default so this migration code doesn't run again. This default field is no longer being used.
                                            defaults.set("", forKey: "favoriteAddress")
                                            completion(true)
                                           
                                           })
        }
        else {
            completion(true)
        }
    }
    
    func updateNotifications() {
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let favoriteViewController = FavoriteViewController()
        
        migrateOldUsersToUseDatabase(completion: { completion in
            
            let urlTo = self.constants.websiteURL + "/get-address-data.php"
            let parameters = ["tableName": self.constants.addressesDatabaseName, "uuid": self.deviceUUID()]
            
            AF.request(urlTo, parameters: parameters).validate().responseJSON() { response in
                switch response.result {
                case .failure(let error):
                    print(error)
                case .success:
                    if let value = response.data {
                        
                        let json =  (try? JSONSerialization.jsonObject(with: value)) as! [[String: String]]
                        
                        for item in json.enumerated() {
                            
                            let address = item.element["address"]!
                            let notificationsToggledString = item.element["notificationsEnabled"]!
                            let notificationsToggled = notificationsToggledString == "1" ? true : false
                            let notificationsWhen = item.element["notificationsWhen"]!
                            let notificationsHour = Int(item.element["notificationsHour"]!)
                            let notificationsMinute = Int(item.element["notificationsMinute"]!)
                            
                            self.deleteNotificationsFromDatabase(address, self.constants.notificationsDatabaseName, completion: {completion in
                                if notificationsToggled == true {
                                    favoriteViewController.getSchedule(true, true, address, notificationsWhen, notificationsHour!, notificationsMinute!)
                                }
                            })
                        }
                    }
                }
            }
        })
    }
    
    // This is run when a sweep notification is opened. It redirects the user to the schedule page
    func goToScheduleFromNotification(_ address: String) {
        
        let schedule = ScheduleModel()
        schedule.address = address
        
        // Get coordinates from address
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            
            // No internet connection will cause an error
            if error != nil {
                print(error?.localizedDescription ?? "")
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
    
    //    func UTCToLocal(date:String) -> String {
    //
    //        let dateFormatter = DateFormatter()
    //        //dateFormatter.dateFormat = "MM/dd/yyyy"
    //        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    //
    //        let dt = dateFormatter.date(from: date)
    //        dateFormatter.timeZone = TimeZone.current
    //        dateFormatter.dateFormat = "MM/dd/yyyy"
    //
    //        return dateFormatter.string(from: dt!)
    //    }
    
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
    
//    public var removeTimeStamp : Date? {
//        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
//            return nil
//        }
//        return date
//    }
    
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




