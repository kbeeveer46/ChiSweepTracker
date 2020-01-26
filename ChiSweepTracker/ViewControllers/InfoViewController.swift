import UIKit
import MessageUI

class InfoViewController: UIViewController, MFMailComposeViewControllerDelegate {

	// Controls
    @IBOutlet weak var infoButton: UIButton!
	@IBOutlet weak var infoButtonHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var signsButton: UIButton!
	@IBOutlet weak var signsButtonHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var ticketButton: UIButton!
	@IBOutlet weak var ticketButtonHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var contactButton: UIButton!
	@IBOutlet weak var contactButtonHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var infoStackView: UIStackView!
	
	// Classes
    let common = Common()
    
	// MARK: Methods
	
    override func viewWillAppear(_ animated: Bool) {
        
		// Set title
        self.tabBarController?.navigationItem.title = "Sweeping Info"
        
		// Clear top navigation items
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil

		// Style buttons
        self.common.styleButton(infoButton, "sweeper", "007AFF")
        self.common.styleButton(signsButton, "warning", "FF7832")
        self.common.styleButton(ticketButton, "dollar_circle", "008577")
		self.common.styleButton(contactButton, "mail", "BF1A2F")
		
		// Initialize controls per device
		initializeControlsPerDevice()
		
    }
	
	func initializeControlsPerDevice() {
		
		switch UIDevice().type {
		case .iPhoneSE:
			infoButton.titleLabel?.font = .systemFont(ofSize: 13)
			infoButtonHeightConstraint.constant = 115
			
			signsButton.titleLabel?.font = .systemFont(ofSize: 13)
			signsButtonHeightConstraint.constant = 145
			
			ticketButton.titleLabel?.font = .systemFont(ofSize: 13)
			ticketButtonHeightConstraint.constant = 100
			
			contactButton.titleLabel?.font = .systemFont(ofSize: 13)
			contactButtonHeightConstraint.constant = 55
			
			infoStackView.spacing = 6
			
		default:
			break
		}
	}
	
	// Close email client after message is sent
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true)
	}
	
	// MARK: Methods
	
	@IBAction func contactButtonTapped(_ sender: Any) {
		
		// Open email client and prompt user to send email
		if MFMailComposeViewController.canSendMail() {
			
			// Create mail object
			let mail = MFMailComposeViewController()
			
			// Set mail properties
			mail.mailComposeDelegate = self
			mail.setToRecipients([self.common.contactEmail()])
			mail.setSubject("Chicago Sweep Tracker")
			
			// Open email client using mail object
			present(mail, animated: true)
			
		}
		else {
			
			// Show error message if no email client is found
			self.common.showAlert(self.common.constants.errorTitle, "Unable to find email app to send message")
		}
	}
}


