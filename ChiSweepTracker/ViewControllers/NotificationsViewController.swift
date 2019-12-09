import UIKit
import UserNotifications

class NotificationsViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, NotificationsModelDelegate {
    
    @IBOutlet weak var textNotificationSwitch: UISwitch!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailNotificationSwitch: UISwitch!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    @IBOutlet weak var pushNotificationsMessage: UIButton!
    @IBOutlet weak var onPicker: UIPickerView!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    let common = Common()
    let constants = Constants()
    var schedule = ScheduleModel()
    let notificationModel = NotificationsModel()
    let defaults = UserDefaults.standard
    
    var defaultEmail = ""
    var userId = ""
    let whenData = ["Day Of", "1 Day Prior", "2 Days Prior", "3 Days Prior", "4 Days Prior", "5 Days Prior", "6 Days Prior", "7 Days Prior"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.styleControls()
        
        self.getNotificationSettings()
        
        defaultEmail = defaults.string(forKey: "defaultEmail") ?? ""
        
        if !defaultEmail.isEmpty {
            notificationModel.getUser(defaultEmail)
            notificationModel.delegate = self
        }

    }

    
    // MARK: Actions
    
    @IBAction func pushNotificationMessageTapped(_ sender: Any) {
        
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        
    }
    
    @IBAction func pushNotificationsTapped(_ sender: Any) {
        
        if pushNotificationsSwitch.isOn == true {
        
            registerForPushNotifications()
            
        }
        else {
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            print("Deleted user's local notifications")
            
        }
    }
    
    @IBAction func emailNotificationTapped(_ sender: Any) {
        
        if emailNotificationSwitch.isOn == true {
            emailTextField.layer.borderColor = UIColor(red: 48/255, green: 178/255, blue: 99/255, alpha: 1).cgColor
            emailTextField.layer.borderWidth = 1
            emailTextField.layer.cornerRadius = 7.0
        }
        else {
            emailTextField.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    @IBAction func textNotificationTapped(_ sender: Any) {
        
        if textNotificationSwitch.isOn == true {
            phoneNumberTextField.layer.borderColor = UIColor(red: 48/255, green: 178/255, blue: 99/255, alpha: 1).cgColor
            phoneNumberTextField.layer.borderWidth = 1
            phoneNumberTextField.layer.cornerRadius = 7.0
        }
        else {
            phoneNumberTextField.layer.borderColor = UIColor.clear.cgColor
        }
        
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
        let email = emailTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let when = whenData[onPicker.selectedRow(inComponent: 0)]
        let time = timePicker.date
        let active = emailNotificationSwitch.isOn ? 1 : 0
        let pushNotifications = pushNotificationsSwitch.isOn ? 1 : 0
        
        // Get hour and minute
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: time)
        let hour = comp.hour!
        let minute = comp.minute!
        
        print(userId)
        print(email)
        print(active)
        print(when)
        print(hour)
        print(minute)
        
        if emailNotificationSwitch.isOn == true {
        
            if email.isEmpty == true {
            
                common.showAlert(self.constants.errorTitle, "Email required for email notifications")
                return
            
            }
            
            if email.isValidEmail == false {
                
                common.showAlert(self.constants.errorTitle, "Not a valid email. Please try again")
                return
            }
        
        }
        
        defaults.set(email, forKey: "defaultEmail")
        
        if !defaultEmail.isEmpty && defaultEmail != email {
            
            // Delete old email notifications from db and add new
            
        }
        
        notificationModel.insertUpdateUser(id: userId, email: email, active: active, ward: schedule.ward, section: schedule.section, whenDay: when, whenHour: String(hour), whenMinute: String(minute), pushNotifications: pushNotifications)
        
        self.common.showAlert(self.constants.successTitle, "Your notifications have been saved")
        
        notificationModel.getUser(email)
        notificationModel.delegate = self
        
    }
    
    //MARK: Methods
    
    func userDownloaded(user: UserModel) {
        
        userId = user.id
        emailTextField.text = user.email
        onPicker.selectRow(whenData.lastIndex(of: user.whenDay)!, inComponent: 0, animated: false)
        
        //setTimePickerValue(user)
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Foundation.Date())
        
        let userComponents = DateComponents(year: currentYear,
                                            day: Int(user.whenDay),
                                            hour: Int(user.whenHour),
                                            minute: Int(user.whenMinute))
        let date = calendar.date(from: userComponents)!
        timePicker.setDate(date, animated: false)
        
        if user.active {
            emailNotificationSwitch.isOn = true
        }
        else {
            emailNotificationSwitch.isOn = false
        }
        
    }
    
    func styleControls() {
        
        self.common.styleButton(saveButton, "save")
        
        //self.phoneNumberTextField.isUserInteractionEnabled = false
        //self.emailTextField.isUserInteractionEnabled = false
        
        phoneNumberTextField.layer.borderColor = UIColor(red: 48/255, green: 178/255, blue: 99/255, alpha: 1).cgColor
        emailTextField.layer.borderColor = UIColor(red: 48/255, green: 178/255, blue: 99/255, alpha: 1).cgColor
        
        self.pushNotificationsMessage.isHidden = true
        self.pushNotificationsSwitch.isOn = false
        
        self.onPicker.delegate = self
        self.onPicker.dataSource = self
        
        // Make enter key close keyboard
        self.phoneNumberTextField.delegate = self
        self.emailTextField.delegate = self
        
        timePicker.addTarget(self, action: #selector(timePickerChanged(picker:)), for: .valueChanged)

    }
    
    func registerForPushNotifications() {
        
        let date = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: date)

        let time = self.timePicker.date
        let comp = calendar.dateComponents([.hour, .minute], from: time)
        let hour = comp.hour!
        let minute = comp.minute!
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            
            let center = UNUserNotificationCenter.current()
            
//            let calendar = Calendar.current
//            
//            let dateComponents = DateComponents(year: 2019, month: 12, day: 7, hour: 22, minute: 40)
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
//                    self.common.showError(error.localizedDescription)
//                    
//                }
//            })
            
            for month in self.schedule.months {

                for day in month.dates {

                    let dateComponents = DateComponents(year: currentYear, month: month.number, day: day.date, hour: hour, minute: minute)
                    let triggerDate = calendar.date(from: dateComponents)
                    let triggerComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: triggerDate!)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

                    let content = UNMutableNotificationContent()
                    content.title = "Sweep Alert"
                    content.body = "Your section is being swept on \(month.number)/\(day.date). You may have to move your vehicle to avoid getting a ticket"
                    content.sound = .default

                    let identifier = "LocalNotification-\(month.name)-\(day.date)"
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                    
                    center.add(request, withCompletionHandler: { (error) in
                        if let error = error {
                            self.common.showAlert(self.constants.errorTitle, error.localizedDescription)
                        }
                        else {
                            print("Local notification added: \(identifier)")
                        }
                    })
                }
            }
        }
    }
    
    func getNotificationSettings() {
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            print("Notification settings: \(settings)")
            
            if settings.authorizationStatus == .authorized {
                
                DispatchQueue.main.async {
                
                    UIApplication.shared.registerForRemoteNotifications()
                    
                }
            }
            else if settings.authorizationStatus == .denied {
                    
            }
            
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return whenData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return whenData[row]
    }
    
    // Make enter key close keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            
        print(whenData[row])
        
    }
    
    @objc func timePickerChanged(picker: UIDatePicker) {
        
        let calendar = Calendar.current
        let time = picker.date
        let comp = calendar.dateComponents([.hour, .minute], from: time)
        print(comp.hour!)
        print(comp.minute!)
        //let hour = comp.hour!
        //let minute = comp.minute!
    }
    
}

