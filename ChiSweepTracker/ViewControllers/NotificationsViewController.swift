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
        
        self.onPicker.delegate = self
        self.onPicker.dataSource = self
        
        loadDefaultNotificationValues()
    
        //let favoriteWard = defaults.string(forKey: "favoriteWard") ?? ""
        //let favoriteSection = defaults.string(forKey: "favoriteSection") ?? ""
        
        loadFavoriteMap()
        
        if !favoriteAddress.isEmpty {
            
            let notificationsToggled = self.defaults.bool(forKey: "notificationsToggled")
            self.pushNotificationsSwitch.isUserInteractionEnabled = true
            self.onPicker.isUserInteractionEnabled = notificationsToggled
            self.timePicker.isUserInteractionEnabled = notificationsToggled
            
            self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "calendar"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(viewSchedule))
            self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "star"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(removeFavorite))
            
            
//            if self.tabBarController == nil {
//
//                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "star"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(removeFavorite))
//
//            }
//            
            current.getNotificationSettings(completionHandler: { (settings) in
                if settings.authorizationStatus == .notDetermined {
                    print("notDetermined")
                } else if settings.authorizationStatus == .denied {
                    print("denied")
                } else if settings.authorizationStatus == .authorized {
                    print("authorized")
                    
                    DispatchQueue.main.async {
                        

                        self.pushNotificationsSwitch.isOn = notificationsToggled
                        
                        if self.pushNotificationsSwitch.isOn {
                            self.registerForPushNotifications()
                        }
                        
                    }
                }
            })
            
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
//            if self.tabBarController == nil
//            {
//                self.navigationItem.title = "No Favorite Address Saved"
//            }
            
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
            self.registerForPushNotifications()
        }
    }
    
    @IBAction func pushNotificationsTapped(_ sender: Any) {
        
        if pushNotificationsSwitch.isOn == true {
            
            self.defaults.set(true, forKey: "notificationsToggled")
            
            self.timePicker.isUserInteractionEnabled = true
            self.onPicker.isUserInteractionEnabled = true
            
            saveDefaultNotificationValues()
            
            registerForPushNotifications()
        
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
        
        self.tabBarController?.navigationItem.title = "Favorite Address"
        favoriteAddress = defaults.string(forKey: "favoriteAddress") ?? ""
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
    
    func removeDefaultNotificationValues() {
        
        self.defaults.set("", forKey: "notificationWhen")
        self.defaults.set(0, forKey: "notificationHour")
        self.defaults.set(0, forKey: "notificationMinute")
        
    }
    
    func registerForPushNotifications() {
        
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
                                // User opened the setting page
                            })
                        }
                    }
                    alertController.addAction(settingsAction)
                    
                    let cancelAction = UIAlertAction(title: "No", style: .cancel, handler:{ action in
                        
                        //self.pushNotificationsSwitch.isUserInteractionEnabled = false
                        self.timePicker.isUserInteractionEnabled = false
                        self.onPicker.isUserInteractionEnabled = false
                        
                        
                    })
                    alertController.addAction(cancelAction)

                    self.present(alertController, animated: true, completion: nil)
                
                }
            }
            else {
            
                // User's notifications are enabled in settings
                
                // Clear current notifications and re-add them in case they changed
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                
                #if DEBUG
                    self.sendTestNotifications()
                #endif
                
                print("Deleted user's local notifications")
                
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
                        
                        //print("Latitude: \(self.schedule.locationCoordinate.latitude)")
                        //print("Longitude: \(self.schedule.locationCoordinate.longitude)")
                        
                        let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
                        
                        // Get ward and section JSON from City of Chicago
                        
                        let wardQuery = wardClient.query(dataset: self.common.constants.wardDataset)
                            .filter("intersects(\(self.common.constants.the_geom),'POINT(\(self.schedule.locationCoordinate.longitude) \(self.schedule.locationCoordinate.latitude))')")
                        
                        wardQuery.get { res in
                            switch res {
                            case .dataset (let data):
                                
                                if data.count > 0 {
                                    
                                    let ward = data[0][self.common.constants.ward] as? String ?? ""
                                    let section = data[0][self.common.constants.section] as? String ?? ""
                                    let the_geom = data[0][self.common.constants.the_geom] as? [String: Any] ?? [:]
                                    let coordinatesWrapper = the_geom[self.common.constants.coordinates] as? NSMutableArray
                                    let coordinatesArray = coordinatesWrapper?[0] as? [[NSMutableArray]]
                                    
                                    //self.defaults.set(coordinatesArray, forKey: "defaultCoordinatesArray")
                                    //self.defaults.synchronize()
                                    
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
                                    
                                    let scheduleQuery = wardClient.query(dataset: self.common.constants.scheduleDataset)
                                        .filter("ward = '\(ward)' AND section = '\(self.schedule.section)'")
                                    
                                    scheduleQuery.get { res in
                                        switch res {
                                        case .dataset (let data):
                                            
                                            if data.count > 0 {
                                                
                                                // Populate schedule model to be used on schedule view
                                                
                                                for (_, item) in data.enumerated() {
                                                    
                                                    let monthName = item[self.common.constants.month_name] as? String ?? ""
                                                    let monthNumber = item[self.common.constants.month_number] as? String ?? ""
                                                    let dates = item[self.common.constants.dates] as? String ?? ""
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
                                                
                                                let center = UNUserNotificationCenter.current()
                                                
                                                let calendar = Calendar.current
                                                let currentYear = calendar.component(.year, from: Date())
                                                
                                                let time = self.timePicker.date
                                                let comp = calendar.dateComponents([.hour, .minute], from: time)
                                                let hour = comp.hour!
                                                let minute = comp.minute!
                                                let when = self.whenData[self.onPicker.selectedRow(inComponent: 0)]
                                                
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
                                        
                                            }
                                        case .error (let err):
                                            
                                            //self.common.showAlert(self.constants.errorTitle, (err as NSError).userInfo.debugDescription)
                                            print((err as NSError).userInfo.debugDescription)
                                            
                                        }
                                    }
                                }
                                else {
                                    
                                    //self.common.showAlert(self.constants.errorTitle, self.constants.notFound)
                                    print(self.common.constants.notFound)
                                    
                                }
                            case .error (let err):
                                
                                //self.common.showAlert(self.constants.errorTitle, (err as NSError).userInfo.debugDescription)
                                print((err as NSError).userInfo.debugDescription)
                                
                            }
                        }
                    }
                    else {
                        
                        //self.common.showAlert(self.constants.errorTitle, self.constants.notFound)
                        print(self.common.constants.notFound)
                    }
                }
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

    
    
    // MARK: Actions
    

    
    
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
    
    
    
}

