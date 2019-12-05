import UIKit

class NotificationsViewController: UIViewController {
    
    @IBOutlet weak var textNotificationSwitch: UISwitch!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailNotificationSwitch: UISwitch!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.backgroundColor = UIColor.init(red: 48/255, green: 178/255, blue: 99/255, alpha: 1)
        saveButton.layer.cornerRadius = 7.0
        saveButton.tintColor = .white
//        if #available(iOS 13.0, *) {
//            saveButton.leftImage(image: UIImage(systemName: "location.circle")!)
//        }
        
        
    }

    @IBAction func saveTapped(_ sender: Any) {
    }
    
}
