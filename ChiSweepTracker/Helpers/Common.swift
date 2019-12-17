import UIKit
import Firebase

// TODO: Try to use a global schedule varible
//var schedule = ScheduleModel()

let defaults = UserDefaults.standard

class Common {
    
    let constants = Constants()
    
    class Constants {
        
		// UPDATE THIS VALUE WITH NEW APP VERSION //
		//let appVersion = 2020
		
		let appStoreId = "1490793712"

		#if DEBUG
		let schedulesDatabaseName = "Schedules_Dev"
		let updatesDatabaseName = "Updates_Dev"
		#else
		let schedulesDatabaseName = "Schedules"
		let updatesDatabaseName = "Updates"
		#endif

//		func initialAppVersion() -> Int {
//			return self.defaults.integer(forKey: "initialAppVersion")
//		}
		
//		func userDatasetVersion() -> Int {
//			return self.defaults.integer(forKey: "userDatasetVersion")
//		}
//		
		func latestAppVersion() -> Int {
			return defaults.integer(forKey: "latestAppVersion")
		}
		
		func latestDatasetVersion() -> Int {
			return defaults.integer(forKey: "latestDatasetVersion")
		}
		
		func userDatasetVersion() -> Int {
			return defaults.integer(forKey: "userDatasetVersion")
		}
		
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
        
		func favoriteAddress() -> String {
			return defaults.string(forKey: "favoriteAddress") ?? ""
		}
		
		func notificationsToggled() -> Bool {
			return defaults.bool(forKey: "notificationsToggled")
		}
		
		func notificationsYear() -> Int {
			return defaults.integer(forKey: "notificationsYear")
		}
		
		//		func hasUserRefreshedNotificationsAfterNewVersion() -> Bool {
		//			return defaults.bool(forKey: "hasUserRefreshedNotificationsAfterNewVersion")
		//		}
		
		//		func lastYearUserRefreshedNotifications() -> Int {
		//			return defaults.integer(forKey: "lastYearUserRefreshedNotifications")
		//		}
		
		//		func hasUserRefreshedNotificationsAfterNewDataset() -> Bool {
		//			return defaults.bool(forKey: "hasUserRefreshedNotificationsAfterNewDataset")
		//		}
		//
		//		func lastVersionUserRefreshedNewDatasetNotifications() -> Int {
		//			return defaults.integer(forKey: "lastVersionUserRefreshedNewDatasetNotifications")
		//		}
		
        
        let SODAToken = "dM3SUsRUNwyTWQGy83lvBv4X3"
        let SODADomain = "data.cityofchicago.org"
        
        // MARK: Alerts
        
        let successTitle = "Success"
        let errorTitle = "Something went wrong..."
        let notFound = "Could not find sweep area. Address must reside in Chicago."

    }
	
	func getCityOfChicagoValuesFromDatabase(completion: @escaping (_ message: String) -> Void) {
		
		let db = Firestore.firestore()
		db.collection(self.constants.schedulesDatabaseName)
			.order(by: "year", descending: true)
			.limit(to: 1)
			.getDocuments() { (querySnapshot, err) in
				if let err = err {
					//print("Could not get getCityOfChicagoValuesFromDatabase data from Firebase: \(err)")
					fatalError("Could not get getCityOfChicagoValuesFromDatabase default data from Firebase: \(err)")
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
						
						let docRef = db.collection(self.constants.updatesDatabaseName).document(String(self.constants.latestAppVersion()))
						
						docRef.getDocument { (document, error) in
							if let document = document, document.exists {
								let data = document.data()
								let latestDatasetVersion = data!["version"]!
								print("Latest dataset version: \(latestDatasetVersion)")
								print("User dataset version: \(self.constants.userDatasetVersion())")
								defaults.set(latestDatasetVersion, forKey: "latestDatasetVersion")
							} else {
								print("Cannot get dataset version from Firebase")
							}
						}
						
						self.updateNotifications()
					}
				}
		}
		
		
		
		completion("Finished calling getCityOfChicagoValuesFromDatabase")
	}
	
	func updateNotifications() {
		
		let favoriteAddress = self.constants.favoriteAddress()
		let notificationsToggled = self.constants.notificationsToggled()
		
		if !favoriteAddress.isEmpty && notificationsToggled == true {
			
			let notificationViewController = NotificationsViewController()
			notificationViewController.getSchedule(true, true)
			
		}
	}
	
	@objc func openAppStore() {
		
		// Send user to app store to update app
		if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(self.constants.appStoreId)"),
			UIApplication.shared.canOpenURL(url){
			UIApplication.shared.open(url, options: [:]) { (opened) in
				if(opened){
					print("App Store Opened")
				}
			}
		} else {
			print("Can't Open URL on Simulator")
		}
	}
	
	// Alert with custom title and message
	public func showAlert(_ title: String, _ message: String) {
		
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
	public func styleButton(_ button: UIButton, _ image: String?,_ color: String?) {
		
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
        
        if name == "finished" || name == "new" {
            self.setImage(image, for: .normal)
        } else {
            self.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image.size.width)
    }
}

