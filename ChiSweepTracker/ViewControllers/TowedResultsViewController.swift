import UIKit

class TowedResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

	// Controls
	@IBOutlet weak var towedVehiclesTableView: UITableView!
	
	// Shared
	var towedVehicles = [VehicleModel]()
		
	// MARK: Methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Set required properties for table view
		self.towedVehiclesTableView.dataSource = self
		self.towedVehiclesTableView.delegate = self
		
		// Set the title
		self.navigationItem.title = "Search Results (\(towedVehicles.count))"
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return towedVehicles.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// Get cell from table view
		let cell = tableView.dequeueReusableCell(withIdentifier: "towedVehicleTableCell", for: indexPath)
		
		// Get labels from cell
		let makeLabel = cell.viewWithTag(1) as! UILabel
		let modelLabel = cell.viewWithTag(2) as! UILabel
		let colorLabel = cell.viewWithTag(3) as! UILabel
		let stateLabel = cell.viewWithTag(4) as! UILabel
		let plateLabel = cell.viewWithTag(5) as! UILabel
		let dateLabel = cell.viewWithTag(6) as! UILabel
		let toAddressLabel = cell.viewWithTag(7) as! UILabel
		let toPhoneLabel = cell.viewWithTag(8) as! UILabel
		let inventoryNumberLabel = cell.viewWithTag(9) as! UILabel
		
		// Set text value for labels
		makeLabel.text = self.towedVehicles[indexPath.row].make
		modelLabel.text = self.towedVehicles[indexPath.row].model
		colorLabel.text = self.towedVehicles[indexPath.row].color
		stateLabel.text = self.towedVehicles[indexPath.row].state
		plateLabel.text = self.towedVehicles[indexPath.row].plate
		dateLabel.text = self.towedVehicles[indexPath.row].towedDate
		toAddressLabel.text = self.towedVehicles[indexPath.row].towedToAddress
		toPhoneLabel.text = self.towedVehicles[indexPath.row].towedToPhone
		inventoryNumberLabel.text = self.towedVehicles[indexPath.row].inventoryNumber
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		// Get selected towed vehicle and go to towed vehicle detail view
		
		let row = indexPath.row
		
		let towedVehicle = towedVehicles[row]
		
		// Segue to towed detail view
		if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "TowedDetailViewController") as? TowedDetailViewController {
			destinationViewController.towedVehicle = towedVehicle
			self.navigationController?.pushViewController(destinationViewController, animated: true)
		}
		
	}

}
