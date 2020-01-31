import UIKit
import Firebase

let defaults = UserDefaults.standard

class Common {
    
    let constants = Constants()
    
	//MARK: Defaults
	
	// Shared
	
	func latestAppVersion() -> Int {
		return defaults.integer(forKey: "latestAppVersion")
	}
	
	func latestDatasetVersion() -> Int {
		return defaults.integer(forKey: "latestDatasetVersion")
	}
	
	func userDatasetVersion() -> Int {
		return defaults.integer(forKey: "userDatasetVersion")
	}
	
	func defaultAddress() -> String {
		return defaults.string(forKey: "defaultAddress") ?? ""
	}
	
	func defaultLongitude() -> Double {
		return defaults.double(forKey: "defaultLongitude")
	}
	
	func defaultLatitude() -> Double {
		return defaults.double(forKey: "defaultLatitude")
	}
	
	// SODA SDK
	
	// Schedule
	
	func dates() -> String {
		return defaults.string(forKey: "datesTitle") ?? ""
	}
	
	func month_number() -> String {
		return defaults.string(forKey: "monthNumberTitle") ?? ""
	}
	
	func month_name() -> String {
		return defaults.string(forKey: "monthNameTitle") ?? ""
	}
	
	func coordinates() -> String {
		return defaults.string(forKey: "coordinatesTitle") ?? ""
	}
	
	func section() -> String {
		return defaults.string(forKey: "sectionTitle") ?? ""
	}
	
	func ward() -> String {
		return defaults.string(forKey: "wardTitle") ?? ""
	}
	
	func the_geom() -> String {
		return defaults.string(forKey: "geomTitle") ?? ""
	}
	
	func scheduleDataset() -> String {
		return defaults.string(forKey: "scheduleDataset") ?? ""
	}
	
	func wardDataset() -> String {
		return defaults.string(forKey: "wardDataset") ?? ""
	}
	
	// Divvy
	
	func divvyDataset() -> String {
		return defaults.string(forKey: "divvyDataset") ?? ""
	}
	
	func divvyDocksInServiceTitle() -> String {
		return defaults.string(forKey: "divvyDocksInServiceTitle") ?? ""
	}
	
	func divvyLatitudeTitle() -> String {
		return defaults.string(forKey: "divvyLatitudeTitle") ?? ""
	}
	
	func divvyLongitudeTitle() -> String {
		return defaults.string(forKey: "divvyLongitudeTitle") ?? ""
	}
	
	func divvyStationNameTitle() -> String {
		return defaults.string(forKey: "divvyStationNameTitle") ?? ""
	}
	
	func divvyStatusTitle() -> String {
		return defaults.string(forKey: "divvyStatusTitle") ?? ""
	}
	
	// Towed vehicles
	
	func towedDataset() -> String {
		return defaults.string(forKey: "towedDataset") ?? ""
	}
	
	func towedColorTitle() -> String {
		return defaults.string(forKey: "towedColorTitle") ?? ""
	}
	
	func towedInventoryNumberTitle() -> String {
		return defaults.string(forKey: "towedInventoryNumberTitle") ?? ""
	}
	
	func towedMakeTitle() -> String {
		return defaults.string(forKey: "towedMakeTitle") ?? ""
	}
	
	func towedModelTitle() -> String {
		return defaults.string(forKey: "towedModelTitle") ?? ""
	}
	
	func towedPlateTitle() -> String {
		return defaults.string(forKey: "towedPlateTitle") ?? ""
	}
	
	func towedStateTitle() -> String {
		return defaults.string(forKey: "towedStateTitle") ?? ""
	}
	
	func towedStyleTitle() -> String {
		return defaults.string(forKey: "towedStyleTitle") ?? ""
	}
	
	func towedDateTitle() -> String {
		return defaults.string(forKey: "towedDateTitle") ?? ""
	}
	
	func towedToAddressTitle() -> String {
		return defaults.string(forKey: "towedToAddressTitle") ?? ""
	}
	
	func towedToPhoneTitle() -> String {
		return defaults.string(forKey: "towedToPhoneTitle") ?? ""
	}
	
	// Relocated vehicles
	
	func relocatedDataset() -> String {
		return defaults.string(forKey: "relocatedDataset") ?? ""
	}
	
	func relocatedColorTitle() -> String {
		return defaults.string(forKey: "relocatedColorTitle") ?? ""
	}
	
	func relocatedMakeTitle() -> String {
		return defaults.string(forKey: "relocatedMakeTitle") ?? ""
	}
	
	func relocatedPlateTitle() -> String {
		return defaults.string(forKey: "relocatedPlateTitle") ?? ""
	}
	
	func relocatedDateTitle() -> String {
		return defaults.string(forKey: "relocatedDateTitle") ?? ""
	}
	
	func relocatedFromLatitudeTitle() -> String {
		return defaults.string(forKey: "relocatedFromLatitudeTitle") ?? ""
	}
	
	func relocatedFromLongitudeTitle() -> String {
		return defaults.string(forKey: "relocatedFromLongitudeTitle") ?? ""
	}
	
	func relocatedReasonTitle() -> String {
		return defaults.string(forKey: "relocatedReasonTitle") ?? ""
	}
	
	func relocatedToAddressNumberTitle() -> String {
		return defaults.string(forKey: "relocatedToAddressNumberTitle") ?? ""
	}
	
	func relocatedToDirectionTitle() -> String {
		return defaults.string(forKey: "relocatedToDirectionTitle") ?? ""
	}
	
	func relocatedToStreetTitle() -> String {
		return defaults.string(forKey: "relocatedToStreetTitle") ?? ""
	}
	
	func relocatedStateTitle() -> String {
		return defaults.string(forKey: "relocatedStateTitle") ?? ""
	}
	
	// Favorites
	
	func favoriteAddress() -> String {
		return defaults.string(forKey: "favoriteAddress") ?? ""
	}
	
	func favoriteWard() -> String {
		return defaults.string(forKey: "favoriteWard") ?? ""
	}
	
	func favoriteSection() -> String {
		return defaults.string(forKey: "favoriteSection") ?? ""
	}
	
	func favoriteLatitude() -> Double {
		return defaults.double(forKey: "favoriteLatitude")
	}
	
	func favoriteLongitude() -> Double {
		return defaults.double(forKey: "favoriteLongitude")
	}
	
	func favoriteCoordinatesArray() -> [[NSArray]] {
		return defaults.object(forKey: "favoriteCoordinatesArray") as? [[NSArray]] ?? [[NSArray]]()
	}
	
	func showDivvyStations() -> Bool {
		return defaults.bool(forKey: "showDivvyStations")
	}
	
	func showTowedVehicles() -> Bool {
		return defaults.bool(forKey: "showTowedVehicles")
	}
	
	// Notifications
	
	func notificationWhen() -> String {
		return defaults.string(forKey: "notificationWhen") ?? ""
	}
	
	func notificationHour() -> Int {
		return defaults.integer(forKey: "notificationHour")
	}
	
	func notificationMinute() -> Int {
		return defaults.integer(forKey: "notificationMinute")
	}
	
	func notificationsToggled() -> Bool {
		return defaults.bool(forKey: "notificationsToggled")
	}
	
	func notificationsYear() -> Int {
		return defaults.integer(forKey: "notificationsYear")
	}
	
	// Settings
	
	func contactEmail() -> String {
		return defaults.string(forKey: "contactEmail") ?? "admin@chicagosweeptracker.info"
	}
	
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
		#else
		let schedulesDatabaseName = "Schedules"
		let updatesDatabaseName = "Updates"
		let settingsDatabaseName = "Settings"
		let divvysDatabaseName = "Divvys"
		let towedDatabaseName = "TowedVehicles"
		let relocatedDatabaseName = "RelocatedVehicles"
		#endif
	
		// SODA
		
		let SODAToken = "dM3SUsRUNwyTWQGy83lvBv4X3"
        let SODADomain = "data.cityofchicago.org"
        
		let streetSweepingBeginHour = 9
		let streetSweepingEndHour = 2
		
		// Strings
		
        let successTitle = "Success"
        let errorTitle = "Something went wrong..."
        let notFound = "Could not find sweep schedule. Address must reside in Chicago."
		
		let finishedScheduleMessage = "Sweeping has ended for _currentYear_. Check back next spring for the new schedule and to set up your notifications."
		let noInternetConnectionSearchMessage = "You must be connected to the Internet to find your sweep area."
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
						
						print("latestAppVersion: \(latestAppVersion)")
						print("wardDataset: \(wardDataset)")
						print("scheduleDataset: \(scheduleDataset)")
						print("coordinatesTitle: \(coordinatesTitle)")
						print("datesTitle: \(datesTitle)")
						print("geomTitle: \(geomTitle)")
						print("monthNameTitle: \(monthNameTitle)")
						print("monthNumberTitle: \(monthNumberTitle)")
						print("sectionTitle: \(sectionTitle)")
						print("wardTitle: \(wardTitle)")
						
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
								
								print("Latest dataset version: \(latestDatasetVersion)")
								print("User dataset version: \(self.userDatasetVersion())")
								
								defaults.set(latestDatasetVersion, forKey: "latestDatasetVersion")
								
								self.updateNotifications()
								
							} else {
								print("Cannot get dataset version from Firebase")
							}
						}
					}
				}
		}
		
		// Get settings data
		db.collection(self.constants.settingsDatabaseName)
			.limit(to: 1)
			.getDocuments() { (querySnapshot, err) in
				if let err = err {
					print("Could not get settings data from Firebase: \(err)")
				} else {
					for document in querySnapshot!.documents {
						
						let data = document.data()
						
						let contactEmail = data["contactEmail"] as! String
						
						defaults.set(contactEmail, forKey: "contactEmail")
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
						let divvyDocksInServiceTitle = data["docksInServiceTitle"] as! String
						let divvyLatitudeTitle = data["latitudeTitle"] as! String
						let divvyLongitudeTitle = data["longitudeTitle"] as! String
						let divvyStationNameTitle = data["stationNameTitle"] as! String
						let divvyStatusTitle = data["statusTitle"] as! String
						
						print("divvyDataset: \(divvyDataset)")
						print("divvyDocksInServiceTitle: \(divvyDocksInServiceTitle)")
						print("divvyLatitudeTitle: \(divvyLatitudeTitle)")
						print("divvyLongitudeTitle: \(divvyLongitudeTitle)")
						print("divvyStationNameTitle: \(divvyStationNameTitle)")
						print("divvyStatusTitle: \(divvyStatusTitle)")
						
						defaults.set(divvyDataset, forKey: "divvyDataset")
						defaults.set(divvyDocksInServiceTitle, forKey: "divvyDocksInServiceTitle")
						defaults.set(divvyLatitudeTitle, forKey: "divvyLatitudeTitle")
						defaults.set(divvyLongitudeTitle, forKey: "divvyLongitudeTitle")
						defaults.set(divvyStationNameTitle, forKey: "divvyStationNameTitle")
						defaults.set(divvyStatusTitle, forKey: "divvyStatusTitle")
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
						let relocatedReasonTitle = data["relocatedReasonTitle"] as! String
						let relocatedToAddressNumberTitle = data["relocatedToAddressNumberTitle"] as! String
						let relocatedToDirectionTitle = data["relocatedToDirectionTitle"] as! String
						let relocatedToStreetTitle = data["relocatedToStreetTitle"] as! String
						let relocatedStateTitle = data["stateTitle"] as! String

						print("relocatedDataset: \(relocatedDataset)")
						print("relocatedColorTitle: \(relocatedColorTitle)")
						print("relocatedMakeTitle: \(relocatedMakeTitle)")
						print("relocatedPlateTitle: \(relocatedPlateTitle)")
						print("relocatedDateTitle: \(relocatedDateTitle)")
						print("relocatedFromLatitudeTitle: \(relocatedFromLatitudeTitle)")
						print("relocatedFromLongitudeTitle: \(relocatedFromLongitudeTitle)")
						print("relocatedReasonTitle: \(relocatedReasonTitle)")
						print("relocatedToAddressNumberTitle: \(relocatedToAddressNumberTitle)")
						print("relocatedToDirectionTitle: \(relocatedToDirectionTitle)")
						print("relocatedToStreetTitle: \(relocatedToStreetTitle)")
						print("relocatedStateTitle: \(relocatedStateTitle)")
						
						defaults.set(relocatedDataset, forKey: "relocatedDataset")
						defaults.set(relocatedColorTitle, forKey: "relocatedColorTitle")
						defaults.set(relocatedMakeTitle, forKey: "relocatedMakeTitle")
						defaults.set(relocatedPlateTitle, forKey: "relocatedPlateTitle")
						defaults.set(relocatedDateTitle, forKey: "relocatedDateTitle")
						defaults.set(relocatedFromLatitudeTitle, forKey: "relocatedFromLatitudeTitle")
						defaults.set(relocatedFromLongitudeTitle, forKey: "relocatedFromLongitudeTitle")
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

						print("towedDataset: \(towedDataset)")
						print("towedColorTitle: \(towedColorTitle)")
						print("towedInventoryNumberTitle: \(towedInventoryNumberTitle)")
						print("towedMakeTitle: \(towedMakeTitle)")
						print("towedModelTitle: \(towedModelTitle)")
						print("towedPlateTitle: \(towedPlateTitle)")
						print("towedStateTitle: \(towedStateTitle)")
						print("towedStyleTitle: \(towedStyleTitle)")
						print("towedDateTitle: \(towedDateTitle)")
						print("towedToAddressTitle: \(towedToAddressTitle)")
						print("towedToPhoneTitle: \(towedToPhoneTitle)")
						
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
		
		completion("Finished getting data from Firebase")
	}
	
	func updateNotifications() {
		
		let favoriteAddress = self.favoriteAddress()
		let notificationsToggled = self.notificationsToggled()
		
		if !favoriteAddress.isEmpty && notificationsToggled == true {
			let notificationViewController = NotificationsViewController()
			notificationViewController.getSchedule(true, true)
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
	func styleButton(_ button: UIButton, _ image: String?,_ color: String?) {
		
		button.backgroundColor = .systemBlue
		if color != nil {
			button.backgroundColor = UIColor(hexString: "#\(color!)")
		}
		button.layer.cornerRadius = 7.0
		button.tintColor = .white
		
		if image != nil {
			button.leftImage(image: UIImage(named: image!)!, name: image)
		}
	}

}

// MARK: Extensions

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
	
	//iPad
	iPad2              = "iPad 2",
	iPad3              = "iPad 3",
	iPad4              = "iPad 4",
	iPadAir            = "iPad Air ",
	iPadAir2           = "iPad Air 2",
	iPadAir3           = "iPad Air 3",
	iPad5              = "iPad 5", //iPad 2017
	iPad6              = "iPad 6", //iPad 2018
	
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
	
	//Apple TV
	AppleTV            = "Apple TV",
	AppleTV_4K         = "Apple TV 4K",
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
			
			//Apple TV
			"AppleTV5,3" : .AppleTV,
			"AppleTV6,2" : .AppleTV_4K
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

