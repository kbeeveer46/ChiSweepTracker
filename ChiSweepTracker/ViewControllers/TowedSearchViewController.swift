import UIKit

class TowedSearchViewController: UIViewController {
	
	@IBOutlet weak var searchTowedVehiclesButton: UIButton!
	
	// Classes
	let common = Common()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.styleControls()
    }
    

	func styleControls() {
		
		// Make enter key close keyboard
		//self.addressTextField.delegate = self
		
		// Set the title or else the title is used from another tab
		self.navigationItem.title = "Search For Towed Vehicles"
		
		// Style and add images to buttons
		self.common.styleButton(searchTowedVehiclesButton, "search_circle", "007AFF")
		
	}
	
	@IBAction func searchTowedVehiclesTapped(_ sender: Any) {
		
		// Segue to towed result view
		if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "TowedResultsViewController") as? TowedResultsViewController {
			//destinationViewController.schedule = self.schedule
			self.navigationController?.pushViewController(destinationViewController, animated: true)
		}
		
	}
	

}
