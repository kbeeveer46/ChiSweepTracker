import UIKit

class TowedResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

	// Controls
	@IBOutlet weak var towedVehiclesTableView: UITableView!
	
	// Shared
	var towedVehicles = [TowedVehicleModel]()
		
    override func viewDidLoad() {
        super.viewDidLoad()

		self.styleControls()
		
		// Set required properties for table view
		self.towedVehiclesTableView.dataSource = self
		self.towedVehiclesTableView.delegate = self
		
	}
    

	func styleControls() {
		
		// Make enter key close keyboard
		//self.addressTextField.delegate = self
		
		// Set the title or else the title is used from another tab
		self.navigationItem.title = "Towed Vehicle Results"
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return towedVehicles.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// Get cell from table view
		let cell = tableView.dequeueReusableCell(withIdentifier: "towedVehicleTableCell", for: indexPath)
		
		// Get make label from cell
		let makeLabel = cell.viewWithTag(1) as! UILabel
		let modelLabel = cell.viewWithTag(2) as! UILabel
		let colorLabel = cell.viewWithTag(3) as! UILabel
		let stateLabel = cell.viewWithTag(4) as! UILabel
		let plateLabel = cell.viewWithTag(5) as! UILabel
		let dateLabel = cell.viewWithTag(6) as! UILabel
		let toAddressLabel = cell.viewWithTag(7) as! UILabel
		let toPhoneLabel = cell.viewWithTag(8) as! UILabel
		
		// Set section label text with ward and section number
		makeLabel.text = self.towedVehicles[indexPath.row].make
		modelLabel.text = self.towedVehicles[indexPath.row].model
		colorLabel.text = self.towedVehicles[indexPath.row].color
		stateLabel.text = self.towedVehicles[indexPath.row].state
		plateLabel.text = self.towedVehicles[indexPath.row].plateNumber
		dateLabel.text = self.towedVehicles[indexPath.row].towDate
		toAddressLabel.text = self.towedVehicles[indexPath.row].towedToAddress
		toPhoneLabel.text = self.towedVehicles[indexPath.row].towedToPhone
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		// Get schedule and go to schedule view when a user selects a section
		
		let row = indexPath.row
		
		//self.schedule.section = sections[row]
		
		//getSchedule()
		
	}

}
