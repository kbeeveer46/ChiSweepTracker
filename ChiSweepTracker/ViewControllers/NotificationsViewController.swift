import UIKit
import UserNotifications
import Crashlytics

class NotificationsViewController: UIViewController {
    
    @IBOutlet weak var textNotificationSwitch: UISwitch!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailNotificationSwitch: UISwitch!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    @IBOutlet weak var pushNotificationsMessage: UIButton!
    
    let common = Common()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleControls()
        
        getNotificationSettings()
        
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
            
        }
        
    }
    
    func getNotificationSettings() {
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            print("Notification settings: \(settings)")
            
            if settings.authorizationStatus == .authorized {
            
                DispatchQueue.main.async {
                
                    UIApplication.shared.registerForRemoteNotifications()
                    
                    self.pushNotificationsSwitch.isOn = true
                    //self.pushNotificationsSwitch.isUserInteractionEnabled = false
                }
            }
            else if settings.authorizationStatus == .denied {
                    
                self.pushNotificationsSwitch.isOn = true
                self.pushNotificationsSwitch.isUserInteractionEnabled = false
                self.pushNotificationsMessage.isHidden = false
            }
            
            
        }
        
    }
    
}

