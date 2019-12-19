import UIKit
import MessageUI

class InfoViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var signsButton: UIButton!
    @IBOutlet weak var ticketButton: UIButton!
	@IBOutlet weak var contactButton: UIButton!
	
    let common = Common()
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.navigationItem.title = "Sweeping Info"
        
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil

        self.common.styleButton(infoButton, "sweeper", "007AFF")
        self.common.styleButton(signsButton, "warning", "FF7832")
        self.common.styleButton(ticketButton, "dollar_circle", "86A697")
		self.common.styleButton(contactButton, "mail", "BF1A2F")
    }

	@IBAction func contactButtonTapped(_ sender: Any) {
		
		if MFMailComposeViewController.canSendMail() {
			let mail = MFMailComposeViewController()
			mail.mailComposeDelegate = self
			mail.setToRecipients(["contact@chicagosweeptracker.info"])
			mail.setSubject("Chicago Sweep Tracker")
			present(mail, animated: true)
		} else {
			self.common.showAlert(self.common.constants.errorTitle, "Unable to find email app to send message")
		}
	}
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true)
	}
}
