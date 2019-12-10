import UIKit
import UserNotifications
import CoreLocation
import CoreData

class NotificationsViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource/*, NotificationsModelDelegate*/ {
    
    @IBOutlet weak var textNotificationSwitch: UISwitch!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailNotificationSwitch: UISwitch!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    @IBOutlet weak var onPicker: UIPickerView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var addressLabel: UILabel!
    
    let current = UNUserNotificationCenter.current()
    let common = Common()
    let constants = Constants()
    //var schedule = ScheduleModel(address: "", ward: "", section: "", months: [MonthModel](), locationCoordinate: CLLocationCoordinate2D(), polygonCoordinates: [CLLocationCoordinate2D]())
    var schedule = ScheduleModel()
    var favoriteAddress = ""
    //let notificationModel = NotificationsModel()
    let defaults = UserDefaults.standard
    
    var removeFavoriteButton = UIBarButtonItem()
    
    let whenData = ["Day Of", "1 Day Prior", "2 Days Prior", "3 Days Prior", "4 Days Prior", "5 Days Prior", "6 Days Prior", "7 Days Prior"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.onPicker.delegate = self
        self.onPicker.dataSource = self
        
        timePicker.addTarget(self, action: #selector(timePickerChanged(picker:)), for: .valueChanged)
        
        self.tabBarController?.navigationItem.title = "Favorite"
        favoriteAddress = defaults.string(forKey: "favoriteAddress") ?? ""
        addressLabel.text = favoriteAddress
        
        if !favoriteAddress.isEmpty {
            
            self.pushNotificationsSwitch.isUserInteractionEnabled = true
            self.onPicker.isUserInteractionEnabled = true
            self.timePicker.isUserInteractionEnabled = true
            
            self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "star"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(removeFavorite))
            
            current.getNotificationSettings(completionHandler: { (settings) in
                if settings.authorizationStatus == .notDetermined {
                    print("notDetermined")
                } else if settings.authorizationStatus == .denied {
                    print("denied")
                } else if settings.authorizationStatus == .authorized {
                    print("authorized")
                    
                    DispatchQueue.main.async {
                        self.registerForPushNotifications()
                        self.pushNotificationsSwitch.isOn = true
                        
                    }
                }
            })
            
        }
        else {
            
            self.addressLabel.text = "Search for a sweep schedule and star an address to receive notifications"
            self.pushNotificationsSwitch.isOn = false
            self.pushNotificationsSwitch.isUserInteractionEnabled = false
            self.onPicker.isUserInteractionEnabled = false
            self.timePicker.isUserInteractionEnabled = false
            
        }
    }
    
    @objc func removeFavorite() {
        
        let alert = UIAlertController(title: "Delete favorite?", message: "You will no longer receive push notifications", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
            
            self.tabBarController?.navigationItem.rightBarButtonItem = nil
            
            print("Deleted favorite address: \(self.favoriteAddress)")
            
            self.defaults.set("", forKey: "favoriteAddress")
            self.favoriteAddress = ""
            self.addressLabel.text = ""
            self.pushNotificationsSwitch.isOn = false
            self.pushNotificationsSwitch.isUserInteractionEnabled = false
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            //UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            
            print("Deleted user's local notifications")
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func timePickerChanged(picker: UIDatePicker) {
        
        if self.pushNotificationsSwitch.isOn {
            self.registerForPushNotifications()
        }
    }
    
    @IBAction func pushNotificationsTapped(_ sender: Any) {
        
        if pushNotificationsSwitch.isOn == true {
            
            registerForPushNotifications()
            
            //            current.getNotificationSettings(completionHandler: { (settings) in
            //                if settings.authorizationStatus == .notDetermined {
            //
            //                } else if settings.authorizationStatus == .denied {
            //
            //                    //DispatchQueue.main.async {
            //
            //                    //UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            //                    //}
            //                } else if settings.authorizationStatus == .authorized {
            //
            //                }
            //            })
            //
        }
        else {
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            //UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            print("Deleted user's local notifications")
            
        }
    }
    
    func registerForPushNotifications() {
        
//        let calendar = Calendar.current
//        let currentYear = calendar.component(.year, from: Date())
//
//        let time = self.timePicker.date
//        let comp = calendar.dateComponents([.hour, .minute], from: time)
//        let hour = comp.hour!
//        let minute = comp.minute!
//        let when = whenData[onPicker.selectedRow(inComponent: 0)]
//
//        print(when)
//        print(hour)
//        print(minute)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            print("Deleted user's local notifications")
            
            let center = UNUserNotificationCenter.current()
            
            //            let dateComponents = DateComponents(year: 2019, month: 12, day: 8, hour: 20, minute: 13)
            //            let triggerDate = calendar.date(from: dateComponents)
            //            let triggerComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: triggerDate!)
            //            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            //
            //            let content = UNMutableNotificationContent()
            //            content.title = "Sweep Alert"
            //            content.body = "Your section is scheduled to be swept today. You may have to move your car to avoid being ticketed"
            //            content.sound = .default
            //
            //            let identifier = "LocalNotificationTest"
            //            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            //
            //            center.add(request, withCompletionHandler: { (error) in
            //                if let error = error {
            //
            //                    self.common.showAlert(self.constants.errorTitle, error.localizedDescription)
            //
            //                }
            //            })
            
            self.schedule.months.removeAll()
            //self.schedule.polygonCoordinates.removeAll()
            
            print("Address: \(self.favoriteAddress)")
            
            self.schedule.address = self.favoriteAddress
            
            // Get coordinates
            
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(self.favoriteAddress) { placemarks, error in
                
                if error != nil {
                    
                    //self.common.showAlert(self.constants.errorTitle, (error! as NSError).userInfo.debugDescription)
                    print((error! as NSError).userInfo.debugDescription)
                }
                
                if placemarks != nil {
                
                    let placemark = placemarks?.first
                    
                    var coordinates = CLLocationCoordinate2D()
                    coordinates.latitude = placemark?.location?.coordinate.latitude ?? 0
                    coordinates.longitude = placemark?.location?.coordinate.longitude ?? 0
                    self.schedule.locationCoordinate = coordinates
                    
                    //self.defaults.set(placemark?.location?.coordinate.latitude, forKey: "defaultLatitude")
                    //self.defaults.set(placemark?.location?.coordinate.longitude, forKey: "defaultLongitude")
                    
                    print("Latitude: \(self.schedule.locationCoordinate.latitude)")
                    print("Longitude: \(self.schedule.locationCoordinate.longitude)")
                    
                    let wardClient = SODAClient(domain: self.constants.SODADomain, token: self.constants.SODAToken)
                    
                    // Get ward and section JSON from City of Chicago
                    
                    let wardQuery = wardClient.query(dataset: self.constants.wardDataset)
                        .filter("intersects(\(self.constants.the_geom),'POINT(\(self.schedule.locationCoordinate.longitude) \(self.schedule.locationCoordinate.latitude))')")
                    
                    wardQuery.get { res in
                        switch res {
                        case .dataset (let data):
                            
                            if data.count > 0 {
                                
                                let ward = data[0][self.constants.ward] as? String ?? ""
                                let section = data[0][self.constants.section] as? String ?? ""
                                //let the_geom = data[0][self.constants.the_geom] as? [String: Any] ?? [:]
                                //let coordinatesWrapper = the_geom[self.constants.coordinates] as? NSMutableArray
                                //let coordinatesArray = coordinatesWrapper?[0] as? [[NSMutableArray]]
                                
//                                for(_, coordinate) in coordinatesArray!.enumerated() {
//
//                                    for item in coordinate {
//
//                                        var coordinate = CLLocationCoordinate2D()
//                                        coordinate.longitude = item[0] as? Double ?? 0
//                                        coordinate.latitude = item[1] as? Double ?? 0
//
//                                        self.schedule.polygonCoordinates.append(coordinate)
//
//                                    }
//                                }
                                
                                print("Ward: \(ward)")
                                print("Section: \(section)")
                                
                                self.schedule.ward = ward
                                self.schedule.section = String(section).trimmingCharacters(in: .whitespaces)
                                
                                if self.schedule.section.isEmpty {
                                    self.schedule.section = self.defaults.string(forKey: "favoriteSection") ?? ""
                                }
                                
                                // Get schedule JSON from City of Chicago
                                
                                let scheduleQuery = wardClient.query(dataset: self.constants.scheduleDataset)
                                    .filter("ward = '\(ward)' \(section != "" ? "AND section = '\(section)'" : "") ")
                                
                                scheduleQuery.get { res in
                                    switch res {
                                    case .dataset (let data):
                                        
                                        if data.count > 0 {
                                            
                                            // Populate schedule model to be used on schedule view
                                            
                                            for (_, item) in data.enumerated() {
                                                
                                                let monthName = item[self.constants.month_name] as? String ?? ""
                                                let monthNumber = item[self.constants.month_number] as? String ?? ""
                                                let dates = item[self.constants.dates] as? String ?? ""
                                                let datesArray = dates.components(separatedBy: ",")
                                                
                                                print("Month name: \(monthName)")
                                                print("Dates: \(datesArray)")
                                                
                                                //let month = MonthModel(name: "", number: "", dates: [DateModel]())
                                                let month = MonthModel()
                                                month.name = monthName
                                                month.number = monthNumber
                                                
                                                for day in datesArray {
                                                    
                                                    print("Date: \(day)")
                                                    
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
                                            
                                            let calendar = Calendar.current
                                            let currentYear = calendar.component(.year, from: Date())
                                            
                                            let time = self.timePicker.date
                                            let comp = calendar.dateComponents([.hour, .minute], from: time)
                                            let hour = comp.hour!
                                            let minute = comp.minute!
                                            let when = self.whenData[self.onPicker.selectedRow(inComponent: 0)]
                                            
                                            //print(when)
                                            //print(hour)
                                            //print(minute)
                                            
                                            for monthInSchedule in self.schedule.months {
                                                
                                                for dayInMonth in monthInSchedule.dates {
                                                    
                                                    let dateComponents = DateComponents(year: currentYear, month: Int(monthInSchedule.number), day: dayInMonth.date)
                                                    var date = Calendar.current.date(from: dateComponents)
                                                    
                                                    switch when {
                                                    case "1 Day Prior":
                                                        date = Calendar.current.date(byAdding: .day, value: -1, to: date!)
                                                    case "2 Days Prior":
                                                        date = Calendar.current.date(byAdding: .day, value: -2, to: date!)
                                                    case "3 Days Prior":
                                                        date = Calendar.current.date(byAdding: .day, value: -3, to: date!)
                                                    case "4 Days Prior":
                                                        date = Calendar.current.date(byAdding: .day, value: -4, to: date!)
                                                    case "5 Days Prior":
                                                        date = Calendar.current.date(byAdding: .day, value: -5, to: date!)
                                                    case "6 Days Prior":
                                                        date = Calendar.current.date(byAdding: .day, value: -6, to: date!)
                                                    case "7 Days Prior":
                                                        date = Calendar.current.date(byAdding: .day, value: -7, to: date!)
                                                    default:
                                                        break
                                                    }
                                                    
                                                    date = Calendar.current.date(bySetting: .hour, value: hour, of: date!)
                                                    date = Calendar.current.date(bySetting: .minute, value: minute, of: date!)
                                                    
                                                    let triggerComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: date!)
                                                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
                                                    
                                                    let content = UNMutableNotificationContent()
                                                    content.title = "Sweep Alert"
                                                    content.body = "Your section is being swept on \(monthInSchedule.number)/\(dayInMonth.date). You may have to move your vehicle to avoid getting a ticket"
                                                    content.sound = .default
                                                    
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
                                    
                                        }
                                    case .error (let err):
                                        
                                        //self.common.showAlert(self.constants.errorTitle, (err as NSError).userInfo.debugDescription)
                                        print((err as NSError).userInfo.debugDescription)
                                        
                                    }
                                }
                            }
                            else {
                                
                                //self.common.showAlert(self.constants.errorTitle, self.constants.notFound)
                                print(self.constants.notFound)
                                
                            }
                        case .error (let err):
                            
                            //self.common.showAlert(self.constants.errorTitle, (err as NSError).userInfo.debugDescription)
                            print((err as NSError).userInfo.debugDescription)
                            
                        }
                    }
                }
                else {
                    
                    //self.common.showAlert(self.constants.errorTitle, self.constants.notFound)
                    print(self.constants.notFound)
                }
            }
            
//            for monthInSchedule in self.schedule.months {
//
//                for dayInMonth in monthInSchedule.dates {
//
//                    let dateComponents = DateComponents(year: currentYear, month: Int(monthInSchedule.number), day: dayInMonth.date)
//                    var date = Calendar.current.date(from: dateComponents)
//
//                    switch when {
//                    case "1 Day Prior":
//                        date = Calendar.current.date(byAdding: .day, value: -1, to: date!)
//                    case "2 Days Prior":
//                        date = Calendar.current.date(byAdding: .day, value: -2, to: date!)
//                    case "3 Days Prior":
//                        date = Calendar.current.date(byAdding: .day, value: -3, to: date!)
//                    case "4 Days Prior":
//                        date = Calendar.current.date(byAdding: .day, value: -4, to: date!)
//                    case "5 Days Prior":
//                        date = Calendar.current.date(byAdding: .day, value: -5, to: date!)
//                    case "6 Days Prior":
//                        date = Calendar.current.date(byAdding: .day, value: -6, to: date!)
//                    case "7 Days Prior":
//                        date = Calendar.current.date(byAdding: .day, value: -7, to: date!)
//                    default:
//                        break
//                    }
//
//                    date = Calendar.current.date(bySetting: .hour, value: hour, of: date!)
//                    date = Calendar.current.date(bySetting: .minute, value: minute, of: date!)
//
//                    let triggerComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: date!)
//                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
//
//                    let content = UNMutableNotificationContent()
//                    content.title = "Sweep Alert"
//                    content.body = "Your section is being swept on \(monthInSchedule.number)/\(dayInMonth.date). You may have to move your vehicle to avoid getting a ticket"
//                    content.sound = .default
//
//                    let identifier = "LocalNotification-\(triggerComponents.month!)-\(triggerComponents.day!)-\(triggerComponents.hour!)-\(triggerComponents.minute!)"
//
//                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//
//                    center.add(request, withCompletionHandler: { (error) in
//                        if let error = error {
//                            self.common.showAlert(self.constants.errorTitle, error.localizedDescription)
//                        }
//                        else {
//                            print("Local notification added: \(identifier)")
//                        }
//                    })
//                }
//            }
        }
    }


    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return whenData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.pushNotificationsSwitch.isOn {
            self.registerForPushNotifications()
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
    
    //    @objc func addFavorite() {
    //
    //        //UserDefaults.standard.set(try? PropertyListEncoder().encode(schedule), forKey:"favoriteSchedule")
    //        //let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: schedule)
    //        //defaults.set(encodedData, forKey: "favoriteSchedule")
    //        //defaults.synchronize()
    //
    //        //As we know that container is set up in the AppDelegates so we need to refer that container.
    //        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    //
    //        //We need to create a context from this container
    //        let managedContext = appDelegate.persistentContainer.viewContext
    //
    //        //Prepare the request of type NSFetchRequest  for the entity
    //        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
    //
    //        do {
    //
    //            let result = try managedContext.fetch(fetchRequest)
    //
    //            if result.count == 0 {
    //
    //                print("Address added to favorites: \(self.schedule.address)")
    //
    //                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //
    //                let favorites = Favorites(context: context)
    //                favorites.address = self.schedule.address
    //
    //                // Search for address and only add it if it doesn't exist
    //
    //                (UIApplication.shared.delegate as! AppDelegate).saveContext()
    //            }
    //
    //        } catch {
    //
    //            print("Could not retrieve favorites from Core Data")
    //        }
    //
    //    }
    
    
    
    
    // MARK: Actions
    
    //    @IBAction func pushNotificationMessageTapped(_ sender: Any) {
    //
    //        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    //
    //    }
    
    //    @IBAction func removeFavoriteButton(_ sender: Any) {
    //    }
    
    
    
    //    @IBAction func emailNotificationTapped(_ sender: Any) {
    //
    //        if emailNotificationSwitch.isOn == true {
    //            emailTextField.layer.borderColor = UIColor(red: 48/255, green: 178/255, blue: 99/255, alpha: 1).cgColor
    //            emailTextField.layer.borderWidth = 1
    //            emailTextField.layer.cornerRadius = 7.0
    //        }
    //        else {
    //            emailTextField.layer.borderColor = UIColor.clear.cgColor
    //        }
    //    }
    //
    //    @IBAction func textNotificationTapped(_ sender: Any) {
    //
    //        if textNotificationSwitch.isOn == true {
    //            phoneNumberTextField.layer.borderColor = UIColor(red: 48/255, green: 178/255, blue: 99/255, alpha: 1).cgColor
    //            phoneNumberTextField.layer.borderWidth = 1
    //            phoneNumberTextField.layer.cornerRadius = 7.0
    //        }
    //        else {
    //            phoneNumberTextField.layer.borderColor = UIColor.clear.cgColor
    //        }
    //
    //    }
    
    //    @IBAction func saveTapped(_ sender: Any) {
    //
    //        let email = emailTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
    //        let when = whenData[onPicker.selectedRow(inComponent: 0)]
    //        let time = timePicker.date
    //        let active = emailNotificationSwitch.isOn ? 1 : 0
    //        let pushNotifications = pushNotificationsSwitch.isOn ? 1 : 0
    //
    //        // Get hour and minute
    //        let calendar = Calendar.current
    //        let comp = calendar.dateComponents([.hour, .minute], from: time)
    //        let hour = comp.hour!
    //        let minute = comp.minute!
    //
    //        print(userId)
    //        print(email)
    //        print(active)
    //        print(when)
    //        print(hour)
    //        print(minute)
    //
    //        if emailNotificationSwitch.isOn == true {
    //
    //            if email.isEmpty == true {
    //
    //                common.showAlert(self.constants.errorTitle, "Email required for email notifications")
    //                return
    //
    //            }
    //
    //            if email.isValidEmail == false {
    //
    //                common.showAlert(self.constants.errorTitle, "Not a valid email. Please try again")
    //                return
    //            }
    //
    //        }
    //
    //        defaults.set(email, forKey: "defaultEmail")
    //
    //        if !defaultEmail.isEmpty && defaultEmail != email {
    //
    //            // Delete old email notifications from db and add new
    //
    //        }
    //
    //        notificationModel.insertUpdateUser(id: userId, email: email, active: active, ward: schedule.ward, section: schedule.section, whenDay: when, whenHour: String(hour), whenMinute: String(minute), pushNotifications: pushNotifications)
    //
    //        self.common.showAlert(self.constants.successTitle, "Your notifications have been saved")
    //
    //        notificationModel.getUser(email)
    //        notificationModel.delegate = self
    //
    //    }
    
    //MARK: Methods
    
    //    func userDownloaded(user: UserModel) {
    //
    //        userId = user.id
    //        emailTextField.text = user.email
    //        onPicker.selectRow(whenData.lastIndex(of: user.whenDay)!, inComponent: 0, animated: false)
    //
    //        //setTimePickerValue(user)
    //        let calendar = Calendar.current
    //        let currentYear = calendar.component(.year, from: Foundation.Date())
    //
    //        let userComponents = DateComponents(year: currentYear,
    //                                            day: Int(user.whenDay),
    //                                            hour: Int(user.whenHour),
    //                                            minute: Int(user.whenMinute))
    //        let date = calendar.date(from: userComponents)!
    //        timePicker.setDate(date, animated: false)
    //
    //        if user.active {
    //            emailNotificationSwitch.isOn = true
    //        }
    //        else {
    //            emailNotificationSwitch.isOn = false
    //        }
    //
    //    }
    
    
    
    
    
    //    func getNotificationSettings() {
    //
    //        UNUserNotificationCenter.current().getNotificationSettings { settings in
    //
    //            print("Notification settings: \(settings)")
    //
    //            if settings.authorizationStatus == .authorized {
    //
    //                DispatchQueue.main.async {
    //
    //                    UIApplication.shared.registerForRemoteNotifications()
    //
    //                }
    //            }
    //            else if settings.authorizationStatus == .denied {
    //
    //            }
    //
    //        }
    //
    //    }
    
    
    
}

