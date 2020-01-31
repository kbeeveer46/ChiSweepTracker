import UIKit

class TowedSearchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
	
	// Controls
	@IBOutlet weak var searchTowedVehiclesButton: UIButton!
	@IBOutlet weak var makePicker: UIPickerView!
	@IBOutlet weak var modelPicker: UIPickerView!
	@IBOutlet weak var colorPicker: UIPickerView!
	@IBOutlet weak var statePicker: UIPickerView!
	@IBOutlet weak var licensePlateTextField: UITextField!
	@IBOutlet weak var towedSearchStackView: UIStackView!
	
	// Classes
	let common = Common()
	
	// Shared
	var makes: [String] = []
	var models: [String] = []
	var colors: [String] = []
	var states: [String] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.styleControls()
		
		self.getTowedVehicleData()
		
		// Initialize controls per device
		initializeControlsPerDevice()

    }
	
	// Change constraints and sizes per device
	func initializeControlsPerDevice() {
		
		switch UIDevice().type {
		case .iPhoneSE:
			towedSearchStackView.spacing = 12
		default:
			break
		}
	}
    
	func getTowedVehicleData() {

		// Create SODA client
		let towedClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)

		// Create SODA query
		let towedQuery = towedClient.query(dataset: self.common.towedDataset()).limit(10000)

		towedQuery.get { res in
			switch res {
			case .dataset (let data):

				if data.count > 0 {
					
					self.makes.removeAll()
					self.models.removeAll()
					self.colors.removeAll()
					self.states.removeAll()

					// Loop through towed vehicle data
					for (_, item) in data.enumerated() {

						// Get values for each towed vehicle
						let towedDate = item[self.common.towedDateTitle()] as? String ?? ""
						let make = item[self.common.towedMakeTitle()] as? String ?? ""
						let model = item[self.common.towedModelTitle()] as? String ?? ""
						let style = item[self.common.towedStyleTitle()] as? String ?? ""
						let color = item[self.common.towedColorTitle()] as? String ?? ""
						let plate = item[self.common.towedPlateTitle()] as? String ?? ""
						let state = item[self.common.towedStateTitle()] as? String ?? ""
						let towedToAddress = item[self.common.towedToAddressTitle()] as? String ?? ""
						let towedToPhone = item[self.common.towedToPhoneTitle()] as? String ?? ""

						if !self.makes.contains(where: { $0 == make}) && make != "" {
							self.makes.append(make)
						}
						
						if !self.models.contains(where: { $0 == model}) && model != "" {
							self.models.append(model)
						}
						
						if !self.colors.contains(where: { $0 == color}) && color != "" {
							self.colors.append(color)
						}
						
						if !self.states.contains(where: { $0 == state}) && state != "" {
							self.states.append(state)
						}
					}
					
					self.makes = self.makes.sorted()
					self.models = self.models.sorted()
					self.colors = self.colors.sorted()
					self.states = self.states.sorted()
					
					// Set required properties for pickers
					self.makePicker.dataSource = self
					self.makePicker.delegate = self
					
					self.modelPicker.dataSource = self
					self.modelPicker.delegate = self
					
					self.colorPicker.dataSource = self
					self.colorPicker.delegate = self
					
					self.statePicker.dataSource = self
					self.statePicker.delegate = self
				}
			case .error (let err):
				print((err as NSError).userInfo.debugDescription)
			}
		}
	}

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		
		if pickerView.tag == 1 {
			return makes.count + 1
		}
		else if pickerView.tag == 2 {
			return models.count + 1
		}
		else if pickerView.tag == 3 {
			return colors.count + 1
		}
		else if pickerView.tag == 4 {
			return states.count + 1
		}
		else {
			return 0
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
			
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		
		if pickerView.tag == 1 {
			return row == 0 ? "Select..." : makes[row - 1]
		}
		else if pickerView.tag == 2 {
			return row == 0 ? "Select..." : models[row - 1]
		}
		else if pickerView.tag == 3 {
			return row == 0 ? "Select..." : colors[row - 1]
		}
		else if pickerView.tag == 4 {
			return row == 0 ? "Select..." : states[row - 1]
		}
		else {
			return ""
		}
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
		
		var towedVehicles = [TowedVehicleModel]()
		let selectedMake = self.makePicker.selectedRow(inComponent: 0) > 0 ? self.makes[self.makePicker.selectedRow(inComponent: 0) - 1].uppercased() : ""
		let selectedModel = self.modelPicker.selectedRow(inComponent: 0) > 0 ? self.models[self.modelPicker.selectedRow(inComponent: 0) - 1].uppercased() : ""
		let selectedColor = self.colorPicker.selectedRow(inComponent: 0) > 0 ? self.colors[self.colorPicker.selectedRow(inComponent: 0) - 1].uppercased() : ""
		let selectedState = self.statePicker.selectedRow(inComponent: 0) > 0 ? self.states[self.statePicker.selectedRow(inComponent: 0) - 1].uppercased() : ""
		let plate = licensePlateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
		
		if (selectedMake == "") {
			self.common.showAlert(self.common.constants.errorTitle, "Please select a Make")
			return
		}
		
		var filter = selectedMake != "" ? "\(self.common.towedMakeTitle()) = '\(selectedMake)'" : ""
		    filter += selectedModel != "" ? " AND \(self.common.towedModelTitle()) = '\(selectedModel)'" : ""
		    filter += selectedColor != "" ? " AND \(self.common.towedColorTitle()) = '\(selectedColor)'" : ""
		    filter += selectedState != "" ? " AND \(self.common.towedStateTitle()) = '\(selectedState)'" : ""
			filter += plate! != "" ? " AND lower(\(self.common.towedPlateTitle())) = '\(plate!)'" : ""
		
		// Create SODA client
		let towedClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
		
		// Create SODA query
		let towedQuery = towedClient.query(dataset: self.common.towedDataset())
			.filter(filter)
			.orderAscending(self.common.towedMakeTitle())
		    .limit(10000)
			//.orderAscending(self.common.towedStateTitle())
			//.orderAscending(self.common.towedPlateTitle())
			
		towedQuery.get { res in
			switch res {
			case .dataset (let data):
				
				if data.count > 0 {
					
					// Loop through towed vehicle data
					for (_, item) in data.enumerated() {
						
						// Get values for each towed vehicle
						var towedDate = item[self.common.towedDateTitle()] as? String ?? ""
						let make = item[self.common.towedMakeTitle()] as? String ?? ""
						let model = item[self.common.towedModelTitle()] as? String ?? ""
						let style = item[self.common.towedStyleTitle()] as? String ?? ""
						let color = item[self.common.towedColorTitle()] as? String ?? ""
						let plate = item[self.common.towedPlateTitle()] as? String ?? ""
						let state = item[self.common.towedStateTitle()] as? String ?? ""
						let inventoryNumber = item[self.common.towedInventoryNumberTitle()] as? String ?? ""
						let towedToAddress = item[self.common.towedToAddressTitle()] as? String ?? ""
						let towedToPhone = item[self.common.towedToPhoneTitle()] as? String ?? ""
						
						towedDate = Date.getFormattedDate(towedDate)
						
						let vehicle = TowedVehicleModel()
						vehicle.towDate = towedDate
						vehicle.make = make
						vehicle.model = model
						vehicle.style = style
						vehicle.color = color
						vehicle.plateNumber = plate
						vehicle.state = state
						vehicle.towedToAddress = towedToAddress
						vehicle.towedToPhone = towedToPhone
						vehicle.inventoryNumber = inventoryNumber
						towedVehicles.append(vehicle)
					}
					
					// Segue to towed result view
					if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "TowedResultsViewController") as? TowedResultsViewController {
						destinationViewController.towedVehicles = towedVehicles
						self.navigationController?.pushViewController(destinationViewController, animated: true)
					}
				}
				else {
					self.common.showAlert("Search Completed", "No vehicles matching your searh criteria were found.")
				}
			case .error (let err):
				print((err as NSError).userInfo.debugDescription)
			}
		}
	}
	

}
