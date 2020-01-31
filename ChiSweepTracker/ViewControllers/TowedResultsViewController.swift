import UIKit

class TowedResultsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		self.styleControls()
		
	}
    

	func styleControls() {
		
		// Make enter key close keyboard
		//self.addressTextField.delegate = self
		
		// Set the title or else the title is used from another tab
		self.navigationItem.title = "Towed Vehicle Results"
		
	}

}
