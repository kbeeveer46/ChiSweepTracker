import UIKit

class NotificationsViewController: UIViewController {
    
    @IBOutlet weak var textNotificationSwitch: UISwitch!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailNotificationSwitch: UISwitch!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberTextField.isUserInteractionEnabled = false
        emailTextField.isUserInteractionEnabled = false
        
        saveButton.backgroundColor = UIColor.init(red: 48/255, green: 178/255, blue: 99/255, alpha: 1)
        saveButton.layer.cornerRadius = 7.0
        saveButton.tintColor = .white
//        if #available(iOS 13.0, *) {
//            saveButton.leftImage(image: UIImage(systemName: "location.circle")!)
//        }
        
        
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
        }
        
    }

    @IBAction func saveTapped(_ sender: Any) {
        
        
        
    }
    
}
