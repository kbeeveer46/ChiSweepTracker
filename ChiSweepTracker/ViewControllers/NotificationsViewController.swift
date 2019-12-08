import UIKit
import UserNotifications
import Crashlytics

class NotificationsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var textNotificationSwitch: UISwitch!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailNotificationSwitch: UISwitch!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    @IBOutlet weak var pushNotificationsMessage: UIButton!
    @IBOutlet weak var onPicker: UIPickerView!
    //@IBOutlet weak var timePicker: UIDatePicker!
    
    
    let common = Common()
    var schedule = Schedule()
    
    let onData = ["Day Of", "1 Day Prior", "2 Days Prior", "3 Days Prior", "4 Days Prior", "5 Days Prior", "6 Days Prior", "7 Days Prior"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleControls()
        
        getNotificationSettings()
        
        self.onPicker.delegate = self
        self.onPicker.dataSource = self
        
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
            
            //unregisterForPushNotifications()
            
            let alertController = UIAlertController(title: "Disable Notifications", message: "Open the device settings page to disable notifications", preferredStyle: .alert)
            
            //let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            //alertController.addAction(cancelAction)
            
            if #available(iOS 10.0, *) {
                
                let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                    
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                            
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                    }
                }
                
                alertController.addAction(openAction)
            }

            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func emailNotificationTapped(_ sender: Any) {
        
        if emailNotificationSwitch.isOn == true {
            emailTextField.isUserInteractionEnabled = true
            emailTextField.layer.borderColor = UIColor(red: 48/255, green: 178/255, blue: 99/255, alpha: 1).cgColor
            emailTextField.layer.borderWidth = 1
            emailTextField.layer.cornerRadius = 7.0
        }
        else {
            emailTextField.layer.borderColor = UIColor.clear.cgColor
            emailTextField.text = ""
            emailTextField.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func textNotificationTapped(_ sender: Any) {
        
        if textNotificationSwitch.isOn == true {
            phoneNumberTextField.isUserInteractionEnabled = true
            phoneNumberTextField.layer.borderColor = UIColor(red: 48/255, green: 178/255, blue: 99/255, alpha: 1).cgColor
            phoneNumberTextField.layer.borderWidth = 1
            phoneNumberTextField.layer.cornerRadius = 7.0
        }
        else {
            phoneNumberTextField.layer.borderColor = UIColor.clear.cgColor
            phoneNumberTextField.text = ""
            phoneNumberTextField.isUserInteractionEnabled = false
        }
        
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
        //Crashlytics.sharedInstance().crash()
        
    }
    
    //MARK: Methods
    
    func styleControls() {
        
         self.common.styleButton(saveButton, "save")
        
        self.phoneNumberTextField.isUserInteractionEnabled = false
        self.emailTextField.isUserInteractionEnabled = false
        
        self.pushNotificationsMessage.isHidden = true
        self.pushNotificationsSwitch.isOn = false
    }
    
    func registerForPushNotifications() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            
            //self.getNotificationSettings()
            
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
            
            let date = Foundation.Date()
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: date)

            //self.schedule.months.forEach { month in
            for month in self.schedule.months {

                //month.dates.forEach { day in
                for day in month.dates {

                    let calendar = Calendar.current
                    let dateComponents = DateComponents(year: currentYear, month: month.number, day: day.date, hour: 8, minute: 0)
                    let triggerDate = calendar.date(from: dateComponents)
                    let triggerComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: triggerDate!)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

                    let content = UNMutableNotificationContent()
                    content.title = "Sweep Alert"
                    content.body = "Your section is scheduled to be swept today. You may have to move your car to avoid being ticketed"
                    content.sound = .default

                    let identifier = "LocalNotification-\(month)-\(day)"
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                    center.add(request, withCompletionHandler: { (error) in
                        if let error = error {

                            self.common.showError(error.localizedDescription)

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
                    
                    self.pushNotificationsSwitch.isOn = true
                }
            }
            else if settings.authorizationStatus == .denied {
                    
                self.pushNotificationsSwitch.isOn = true
                self.pushNotificationsSwitch.isUserInteractionEnabled = false
                self.pushNotificationsMessage.isHidden = false
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return onData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return onData[row]
    }
}

