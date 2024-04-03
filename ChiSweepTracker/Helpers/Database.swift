import Alamofire

public class Database {
    
    // Classes
    let common = Common()
    
    // Shared
    let userDefaults = UserDefaults(suiteName: "group.com.kylebeverforden.chisweeptracker.defaults")
    
    //MARK: Addresses
    
    func getAddresses(address: String = "", completion: @escaping (_ message: [AddressModel]) -> ()) {
        
        var addresses = [AddressModel]()
        var parameters = [String: String]()
        let urlTo = self.common.constants.websiteURL + "/get-address-data.php"
        
        if address.isEmpty {
            parameters = ["tableName": self.common.constants.addressesDatabaseName, "uuid": self.common.defaults.deviceUUID()]
        }
        else {
            parameters = ["tableName": self.common.constants.addressesDatabaseName, "uuid": self.common.defaults.deviceUUID(), "address": address]
        }
        
        AF.request(urlTo, parameters: parameters).validate().responseData() { response in
            switch response.result {
            case .failure(let error):
                print(error)
                completion(addresses)
            case .success:
                if let value = response.data {
                    
                    let json =  (try? JSONSerialization.jsonObject(with: value)) as! [[String: String]]
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "M/dd/yyyy"
                    
                    for item in json.enumerated() {
                        
                        let address = AddressModel()
                        address.address = item.element["address"]!
                        address.notificationsEnabled = item.element["notificationsEnabled"]!
                        address.notificationsWhen = item.element["notificationsWhen"]!
                        address.notificationsHour = item.element["notificationsHour"]!
                        address.notificationsMinute = item.element["notificationsMinute"]!
                        
                        let nextSweepDay = item.element["nextSweepDay"]!
                        if !nextSweepDay.isEmpty {
                            address.nextSweepDay = dateFormatter.date(from: nextSweepDay)!
                        }
                        
                        addresses.append(address)
                    }
                    
                    completion(addresses)
                }
            }
        }
    }
    
    func deleteAddressFromDatabase(address: String, deleteAddressResult: @escaping (Bool) -> Void) {
        let urlTo = self.common.constants.websiteURL + "/delete-address.php"
        let parameters = ["tableName": self.common.constants.addressesDatabaseName,
                          "uuid": self.common.defaults.deviceUUID(),
                          "address": address] as [String : Any]
        
        AF.request(urlTo, method: .post, parameters: parameters).validate().response() { response in
            switch response.result {
            case .failure(let error):
                print(error)
                deleteAddressResult(false)
            case .success:
                self.deleteNotificationsFromDatabase(address, completion: {completion in
                    deleteAddressResult(completion)
                })
            }
        }
    }
    
    func insertAddressIntoDatabase(address: String, notificationsEnabled: Int, notificationsWhen: String, notificationsHour: Int, notificationsMinute: Int, completion: @escaping (Bool) -> Void) {
        
        self.common.getNextSweepDay(address: address, completion: { date in
            
            var nextSweepDayFormatted = ""
            
            if date != nil {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: date!)
                nextSweepDayFormatted = "\(components.month!)/\(components.day!)/\(components.year!)"
            }
            
            let urlTo = self.common.constants.websiteURL + "/insert-address.php"
            let parameters = ["tableName": self.common.constants.addressesDatabaseName,
                              "uuid": self.common.defaults.deviceUUID(),
                              "address": address,
                              "notificationsWhen": notificationsWhen,
                              "notificationsHour": notificationsHour,
                              "notificationsMinute": notificationsMinute,
                              "notificationsEnabled": notificationsEnabled,
                              "nextSweepDay": nextSweepDayFormatted] as [String : Any]
            
            AF.request(urlTo, method: .post, parameters: parameters).validate().response() { response in
                switch response.result {
                case .failure(let error):
                    print(error)
                    completion(false)
                case .success:
                    completion(true)
                }
            }
        })
    }
    
    func updateAddress(address: String, notificationsWhen: String, notificationsHour: Int, notificationsMinute: Int, notificationsEnabled: Int) {
        let urlTo = self.common.constants.websiteURL + "/update-address.php"
        let parameters = ["tableName": self.common.constants.addressesDatabaseName,
                          "uuid": self.common.defaults.deviceUUID(),
                          "address": address,
                          "notificationsWhen": notificationsWhen,
                          "notificationsHour": notificationsHour,
                          "notificationsMinute": notificationsMinute,
                          "notificationsEnabled": notificationsEnabled] as [String : Any]
        
        AF.request(urlTo, method: .post, parameters: parameters).validate().response() { response in
            //switch response.result {
            //case .failure(let error):
            //    print(error)
            //case .success:
            //    completion(true)
            //}
        }
    }
    
    func updateAddressesNextSweepDay(address: String, day: String) {
        let urlTo = self.common.constants.websiteURL + "/update-address-next-sweep-day.php"
        let parameters = ["tableName": self.common.constants.addressesDatabaseName,
                          "nextSweepDay": day,
                          "uuid": self.common.defaults.deviceUUID(),
                          "address": address] as [String : Any]
        
        AF.request(urlTo, method: .post, parameters: parameters).validate().response() { response in
            //switch response.result {
            //case .failure(let error):
            //    print(error)
            //    completion(false)
            //case .success:
            //    completion(true)
            //}
        }
    }
    
    func migrateOldUsersToUseDatabase(completion: @escaping (Bool) -> Void) {
        
        let favoriteAddress = self.common.defaults.favoriteAddress()
        
        if favoriteAddress != "" {
            
            // insert address into database
            self.insertAddressIntoDatabase(address: favoriteAddress,
                                           notificationsEnabled: self.common.defaults.notificationsToggled() ? 1 : 0,
                                           notificationsWhen: self.common.defaults.notificationWhen() != "" ? self.common.defaults.notificationWhen() : "Day Of Sweep",
                                           notificationsHour: self.common.defaults.notificationHour(),
                                           notificationsMinute: self.common.defaults.notificationMinute(),
                                           completion: { result in
                                            
                                            if result {
                                            
                                                // Clear the old favorite address default so this migration code doesn't run again. This default field is no longer being used.
                                                self.userDefaults!.set("", forKey: "favoriteAddress")
                                                completion(true)
                                                
                                            }
                                            else {
                                                completion(false)
                                            }
            })
        }
        else {
            completion(true)
        }
    }
    
    //MARK: Notifications
    
    func insertNotificatinIntoDatabase(address: String, notificationTime: String, sweepDay: String) {
        
        if self.common.defaults.notificationOneSignalPlayerId() != "" {
            
            let urlTo = self.common.constants.websiteURL + "/insert-notification.php"
            let parameters = ["tableName": self.common.constants.notificationsDatabaseName,
                              "playerId": self.common.defaults.notificationOneSignalPlayerId().uppercased(),
                              "address": address,
                              "notificationTime": notificationTime,
                              "sweepDay": sweepDay] as [String : Any]
            
            AF.request(urlTo, method: .post, parameters: parameters).validate().response() { response in
                //switch response.result {
                //case .failure(let error):
                //    print(error)
                //    completion(false)
                //case .success:
                //    completion(true)
                //}
            }
        }
    }
    
    func deleteNotificationsFromDatabase(_ address: String, completion: @escaping (Bool) -> Void) {
        let urlTo = self.common.constants.websiteURL + "/delete-notification.php"
        let parameters = ["playerId": self.common.defaults.notificationOneSignalPlayerId(),
                          "address": address,
                          "tableName": self.common.constants.notificationsDatabaseName] as [String : String]
        
        AF.request(urlTo, method: .post, parameters: parameters).validate().response() { response in
            switch response.result {
            case .failure(let error):
                print(error)
                completion(false)
            case .success:
                completion(true)
            }
        }
    }
    
    func updateNotificationsAndSweepDayInDatabase() {
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let favoriteViewController = FavoriteViewController()
        
        migrateOldUsersToUseDatabase(completion: { completion in
            
            self.getAddresses(completion: { addresses in
                
                for address in addresses {
                    
                    // Update next sweep day
                    self.common.getNextSweepDay(address: address.address, completion: { date in
                        
                        var nextSweepDayFormatted = ""
                        
                        if date != nil {
                            let calendar = Calendar.current
                            let components = calendar.dateComponents([.year, .month, .day], from: date!)
                            nextSweepDayFormatted = "\(components.month!)/\(components.day!)/\(components.year!)"
                        }
                        
                        self.updateAddressesNextSweepDay(address: address.address, day: nextSweepDayFormatted)
                    })
                    
                    // Update notifications
                    let notificationsToggled = address.notificationsEnabled == "1" ? true : false
                    let notificationsWhen = address.notificationsWhen
                    let notificationsHour = Int(address.notificationsHour)
                    let notificationsMinute = Int(address.notificationsMinute)
                    
                    self.deleteNotificationsFromDatabase(address.address, completion: {completion in
                        if notificationsToggled == true {
                            favoriteViewController.getScheduleAndAddNotifications(true, true, address.address, notificationsWhen, notificationsHour!, notificationsMinute!)
                        }
                    })
                }
            })
        })
    }
    
    //MARK: Misc
    
    func getValuesFromDatabase(completion: @escaping (_ message: String) -> Void) {
        
        self.userDefaults!.setValue(true, forKey: "gettingValuesFromDatabase")
        
        // Get schedule data
        AF.request(self.common.constants.websiteURL + "/get-schedule-data.php", parameters: ["tableName": self.common.constants.schedulesDatabaseName]).validate().responseData() { response in
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
                    
                    self.userDefaults!.set(latestAppVersion, forKey: "latestAppVersion")
                    self.userDefaults!.set(wardDataset, forKey: "wardDataset")
                    self.userDefaults!.set(scheduleDataset, forKey: "scheduleDataset")
                    self.userDefaults!.set(coordinatesTitle, forKey: "coordinatesTitle")
                    self.userDefaults!.set(datesTitle, forKey: "datesTitle")
                    self.userDefaults!.set(geomTitle, forKey: "geomTitle")
                    self.userDefaults!.set(monthNameTitle, forKey: "monthNameTitle")
                    self.userDefaults!.set(monthNumberTitle, forKey: "monthNumberTitle")
                    self.userDefaults!.set(sectionTitle, forKey: "sectionTitle")
                    self.userDefaults!.set(wardTitle, forKey: "wardTitle")
                    
                    AF.request(self.common.constants.websiteURL + "/get-update-data.php", parameters: ["tableName": self.common.constants.updatesDatabaseName, "year": String(self.common.defaults.latestAppVersion())]).validate().responseData() { response in
                        switch response.result {
                        case .failure(let error):
                            print(error)
                        case .success:
                            if let value = response.data {
                                
                                let json = (try? JSONSerialization.jsonObject(with: value)) as! [[String: String]]
                                let update = json.first!
                                
                                let latestDatasetVersionString = update["version"]
                                let latestDatasetVersion = Int(latestDatasetVersionString!)
                                
                                self.userDefaults!.set(latestDatasetVersion, forKey: "latestDatasetVersion")
                                
                                DispatchQueue.main.async {
                                    self.updateNotificationsAndSweepDayInDatabase()
                                    self.common.displayNewOrUpdatedScheduleAlerts()
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Get Divvys data
        AF.request(self.common.constants.websiteURL + "/get-data.php", parameters: ["tableName": self.common.constants.divvysDatabaseName]).validate().responseData() { response in
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
                    let divvyJSONScootersAvailableTitle = divvy["divvyJSONScootersAvailableTitle"]
                    let divvyJSONDocksAvailableTitle = divvy["divvyJSONDocksAvailableTitle"]
                    let divvyJSONDataTitle = divvy["divvyJSONDataTitle"]
                    let divvyJSONStationsTitle = divvy["divvyJSONStationsTitle"]
                    let divvyJSONIdTitle = divvy["divvyJSONIdTitle"]
                    let divvyJSONLastUpdatedTitle = divvy["divvyJSONLastUpdatedTitle"]
                    
                    self.userDefaults!.set(divvyDataset, forKey: "divvyDataset")
                    self.userDefaults!.set(divvyIdTitle, forKey: "divvyIdTitle")
                    self.userDefaults!.set(divvyDocksInServiceTitle, forKey: "divvyDocksInServiceTitle")
                    self.userDefaults!.set(divvyLatitudeTitle, forKey: "divvyLatitudeTitle")
                    self.userDefaults!.set(divvyLongitudeTitle, forKey: "divvyLongitudeTitle")
                    self.userDefaults!.set(divvyStationNameTitle, forKey: "divvyStationNameTitle")
                    self.userDefaults!.set(divvyStatusTitle, forKey: "divvyStatusTitle")
                    
                    self.userDefaults!.set(divvyJSONUrl, forKey: "divvyJSONUrl")
                    self.userDefaults!.set(divvyJSONBikesAvailableTitle, forKey: "divvyJSONBikesAvailableTitle")
                    self.userDefaults!.set(divvyJSONEBikesAvailableTitle, forKey: "divvyJSONEBikesAvailableTitle")
                    self.userDefaults!.set(divvyJSONScootersAvailableTitle, forKey: "divvyJSONScootersAvailableTitle")
                    self.userDefaults!.set(divvyJSONDocksAvailableTitle, forKey: "divvyJSONDocksAvailableTitle")
                    self.userDefaults!.set(divvyJSONDataTitle, forKey: "divvyJSONDataTitle")
                    self.userDefaults!.set(divvyJSONStationsTitle, forKey: "divvyJSONStationsTitle")
                    self.userDefaults!.set(divvyJSONIdTitle, forKey: "divvyJSONIdTitle")
                    self.userDefaults!.set(divvyJSONLastUpdatedTitle, forKey: "divvyJSONLastUpdatedTitle")
                    
                }
            }
        }
        
        // Get relocated vehicles data
        AF.request(self.common.constants.websiteURL + "/get-data.php", parameters: ["tableName": self.common.constants.relocatedDatabaseName]).validate().responseData() { response in
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
                    
                    self.userDefaults!.set(relocatedDataset, forKey: "relocatedDataset")
                    self.userDefaults!.set(relocatedColorTitle, forKey: "relocatedColorTitle")
                    self.userDefaults!.set(relocatedMakeTitle, forKey: "relocatedMakeTitle")
                    self.userDefaults!.set(relocatedPlateTitle, forKey: "relocatedPlateTitle")
                    self.userDefaults!.set(relocatedDateTitle, forKey: "relocatedDateTitle")
                    self.userDefaults!.set(relocatedFromLatitudeTitle, forKey: "relocatedFromLatitudeTitle")
                    self.userDefaults!.set(relocatedFromLongitudeTitle, forKey: "relocatedFromLongitudeTitle")
                    self.userDefaults!.set(relocatedFromAddressNumberTitle, forKey: "relocatedFromAddressNumberTitle")
                    self.userDefaults!.set(relocatedFromDirectionTitle, forKey: "relocatedFromDirectionTitle")
                    self.userDefaults!.set(relocatedFromStreetTitle, forKey: "relocatedFromStreetTitle")
                    self.userDefaults!.set(relocatedReasonTitle, forKey: "relocatedReasonTitle")
                    self.userDefaults!.set(relocatedToAddressNumberTitle, forKey: "relocatedToAddressNumberTitle")
                    self.userDefaults!.set(relocatedToDirectionTitle, forKey: "relocatedToDirectionTitle")
                    self.userDefaults!.set(relocatedToStreetTitle, forKey: "relocatedToStreetTitle")
                    self.userDefaults!.set(relocatedStateTitle, forKey: "relocatedStateTitle")
                }
            }
        }
        
        // Get towed vehicles data
        AF.request(self.common.constants.websiteURL + "/get-data.php", parameters: ["tableName": self.common.constants.towedDatabaseName]).validate().responseData() { response in
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
                    
                    self.userDefaults!.set(towedDataset, forKey: "towedDataset")
                    self.userDefaults!.set(towedColorTitle, forKey: "towedColorTitle")
                    self.userDefaults!.set(towedInventoryNumberTitle, forKey: "towedInventoryNumberTitle")
                    self.userDefaults!.set(towedMakeTitle, forKey: "towedMakeTitle")
                    self.userDefaults!.set(towedModelTitle, forKey: "towedModelTitle")
                    self.userDefaults!.set(towedPlateTitle, forKey: "towedPlateTitle")
                    self.userDefaults!.set(towedStateTitle, forKey: "towedStateTitle")
                    self.userDefaults!.set(towedStyleTitle, forKey: "towedStyleTitle")
                    self.userDefaults!.set(towedDateTitle, forKey: "towedDateTitle")
                    self.userDefaults!.set(towedToAddressTitle, forKey: "towedToAddressTitle")
                    self.userDefaults!.set(towedToPhoneTitle, forKey: "towedToPhoneTitle")
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
        //            getRequest(self.common.constants.websiteURL + "/get-news-data.php", parameters: ["tableName": self.common.constants.newsDatabaseName]) { responseObject, error in
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
    
}
