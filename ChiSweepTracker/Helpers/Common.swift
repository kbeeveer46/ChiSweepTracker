import MapKit

let userDefaults = UserDefaults(suiteName: "group.com.kylebeverforden.chisweeptracker.defaults")

public class Common {
    
    // MARK: Shared
    let constants = Constants()
    let defaults = Defaults()
    
    //MARK: Methods
    
    // This runs every time the app is opened after gettin the latest dataset number and app version from the database.
    // It will alert the user if the schedule has been released for the year or if there have been any updates to the schedule
    func displayNewOrUpdatedScheduleAlerts() {
        
        let latestDatasetVersion = defaults.latestDatasetVersion()
        let userDatasetVersion = defaults.userDatasetVersion()
        
        let notificationsYear = defaults.notificationsYear()
        let latestAppVersion = defaults.latestAppVersion()
        
        // Set the latest dataset version when notifications were updated
        // Use the value to alert them if they loaded the app after Chicago changed the schedule
        if userDatasetVersion != 0 && userDatasetVersion < latestDatasetVersion && notificationsYear == latestAppVersion {
            self.showAlert("Schedule Updated", "Chicago has changed the \(latestAppVersion) schedule and your push notifications have been automatically updated if you have them enabled.")
        }
        userDefaults!.set(latestDatasetVersion, forKey: "userDatasetVersion")
        
        // Set the last year when notifications were updated.
        // Use the value to alert them if they loaded the app after a new year came out
        if notificationsYear != 0 && notificationsYear < latestAppVersion {
            self.showAlert("Schedule Released", "Chicago has released the \(latestAppVersion) schedule and your push notifications have been automatically updated if you have them enabled.")
        }
        userDefaults!.set(latestAppVersion, forKey: "notificationsYear")
        
    }
    
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
                
                // Get lat and long from placemark
                let latitude = placemark?.location?.coordinate.latitude ?? 0
                let longitude = placemark?.location?.coordinate.longitude ?? 0
                                
                // Create SODA client using domain and token
                let wardClient = SODAClient(domain: self.constants.SODADomain, token: self.constants.SODAToken)
                
                // Query SODA API to get ward and section
                let wardQuery = wardClient.query(dataset: self.defaults.wardDataset())
                    .filter("intersects(\(self.defaults.geomTitle()),'POINT(\(longitude) \(latitude))')")
                    .limit(1)
                
                wardQuery.get { res in
                    switch res {
                    case .dataset (let data):
                        
                        if data.count > 0 {
                            
                            // Get values from json query
                            let ward = data[0][self.defaults.wardTitle()] as? String ?? ""
                            let section = data[0][self.defaults.sectionTitle()] as? String ?? ""
                            
                            // Query SODA API to get months and days
                            let scheduleQuery = wardClient.query(dataset: self.defaults.scheduleDataset())
                                .filter("\(self.defaults.wardTitle()) = '\(ward)' \(section != "" ? "AND \(self.defaults.sectionTitle()) = '\(section)'" : "") ")
                                .orderAscending(self.defaults.monthNumberTitle())
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        // Loop through months
                                        for (_, item) in data.enumerated() {
                                            
                                            // Get values from json data
                                            let monthName = item[self.defaults.monthNameTitle()] as? String ?? ""
                                            let monthNumber = item[self.defaults.monthNumberTitle()] as? String ?? ""
                                            let dates = item[self.defaults.dates()] as? String ?? ""
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
                                                    dateComponents.year = self.defaults.latestAppVersion()
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
                let wardQuery = wardClient.query(dataset: self.defaults.wardDataset())
                    .filter("intersects(\(self.defaults.geomTitle()),'POINT(\(schedule.locationCoordinate.longitude) \(schedule.locationCoordinate.latitude))')")
                    .limit(1)
                
                wardQuery.get { res in
                    switch res {
                    case .dataset (let data):
                        
                        if data.count > 0 {
                            
                            // Get values from json query
                            let ward = data[0][self.defaults.wardTitle()] as? String ?? ""
                            let section = data[0][self.defaults.sectionTitle()] as? String ?? ""
                            let the_geom = data[0][self.defaults.geomTitle()] as? [String: Any] ?? [:]
                            let coordinatesWrapper = the_geom[self.defaults.coordinatesTitle()] as? NSMutableArray
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
                            let scheduleQuery = wardClient.query(dataset: self.defaults.scheduleDataset())
                                .filter("\(self.defaults.wardTitle()) = '\(ward)' \(section != "" ? "AND \(self.defaults.sectionTitle()) = '\(section)'" : "") ")
                                .orderAscending(self.defaults.monthNumberTitle())
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        // Loop through months
                                        for (_, item) in data.enumerated() {
                                            
                                            // Get values from json data
                                            let monthName = item[self.defaults.monthNameTitle()] as? String ?? ""
                                            let monthNumber = item[self.defaults.monthNumberTitle()] as? String ?? ""
                                            let dates = item[self.defaults.dates()] as? String ?? ""
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
    // This can go away after changing all the buttons to card views (towed vehicle search page)
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

extension String {
    
    // Capitalize first lett of month name
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




