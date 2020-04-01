import UIKit
import MessageUI
import StoreKit

class InfoViewController: UIViewController {

	// Controls
    @IBOutlet weak var infoButton: UIButton!
	@IBOutlet weak var infoButtonHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var signsButton: UIButton!
	@IBOutlet weak var signsButtonHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var ticketButton: UIButton!
	@IBOutlet weak var ticketButtonHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var infoStackView: UIStackView!
	@IBOutlet weak var rateButton: UIButton!
	@IBOutlet weak var rateButtonHeightConstraint: NSLayoutConstraint!
	
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
		self.common.styleButton(rateButton, "star_rate", "BF1A2F")
		
		// Initialize controls per device
		initializeControlsPerDevice()
		
    }
	
	func initializeControlsPerDevice() {
		
		switch UIDevice().type {
		case .iPhoneSE:
			
			infoButton.titleLabel?.font = .systemFont(ofSize: 13)
			infoButtonHeightConstraint.constant = 105
			
			signsButton.titleLabel?.font = .systemFont(ofSize: 13)
			signsButtonHeightConstraint.constant = 135
			
			ticketButton.titleLabel?.font = .systemFont(ofSize: 13)
			ticketButtonHeightConstraint.constant = 100
			
			rateButton.titleLabel?.font = .systemFont(ofSize: 13)
			rateButtonHeightConstraint.constant = 65
			
		case .iPhone6S,
			 .iPhone7,
			 .iPhone8,
			 .iPhoneX:
			
			infoButtonHeightConstraint.constant = 120
			signsButtonHeightConstraint.constant = 160
			
		default:
			break
		}
	}
	
	// MARK: Actions
	
	@IBAction func rateButtonTapped(_ sender: Any) {
	
		if #available(iOS 10.3, *) {
			SKStoreReviewController.requestReview()
		} else {
			// Fallback on earlier versions
		}
	}
}


