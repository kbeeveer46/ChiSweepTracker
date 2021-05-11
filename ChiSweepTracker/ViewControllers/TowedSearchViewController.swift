import UIKit

class TowedSearchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
	
	// MARK: Controls
	@IBOutlet weak var searchTowedVehiclesButton: UIButton!
	@IBOutlet weak var searchTowedVehiclesButtonPaddingConstraint: NSLayoutConstraint!
	@IBOutlet weak var makePicker: UIPickerView!
	@IBOutlet weak var modelPicker: UIPickerView!
	@IBOutlet weak var colorPicker: UIPickerView!
	@IBOutlet weak var statePicker: UIPickerView!
	@IBOutlet weak var licensePlateTextField: UITextField!
	@IBOutlet weak var licensePlateTextFieldWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var towedSearchStackView: UIStackView!
	@IBOutlet weak var makeImageView: UIImageView!
	@IBOutlet weak var modelImageView: UIImageView!
	@IBOutlet weak var colorImageView: UIImageView!
	@IBOutlet weak var stateImageView: UIImageView!
	@IBOutlet weak var plateImageView: UIImageView!
	
	// MARK: Classes
	let common = Common()

	// MARK: Shared
	var makes: [String] = []
	var models: [String] = []
	var colors: [String] = []
	var states: [String] = []
	
	// MARK: Methods
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Initialize controls
		self.initializeControls()
        
        // Initialize controls per device
        self.initializeControlsPerDevice()
		
		// Get towed vehicle data to populate pickers
		self.getTowedVehicleData()
		
	}
	
	// Change constraints and sizes per device
	func initializeControlsPerDevice() {
		
		switch UIDevice().type {
		case .iPhoneSE:
			towedSearchStackView.spacing = 0
			searchTowedVehiclesButtonPaddingConstraint.constant = 7
			makeImageView.isHidden = true
			modelImageView.isHidden = true
			colorImageView.isHidden = true
			stateImageView.isHidden = true
			plateImageView.isHidden = true
			licensePlateTextFieldWidthConstraint.constant = 190
		default:
			break
		}
	}
    
	func getTowedVehicleData() {

		// Create SODA client
		let towedClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)

		// Create SODA query
        let towedQuery = towedClient.query(dataset: self.common.defaults.towedDataset()).limit(500)

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
						let make = item[self.common.defaults.towedMakeTitle()] as? String ?? ""
						let model = item[self.common.defaults.towedModelTitle()] as? String ?? ""
						let color = item[self.common.defaults.towedColorTitle()] as? String ?? ""
						let state = item[self.common.defaults.towedStateTitle()] as? String ?? ""

						if !self.makes.contains(where: { $0.uppercased() == make.uppercased()}) && make != "" {
							self.makes.append(make.uppercased())
						}
						
						if !self.models.contains(where: { $0.uppercased() == model.uppercased()}) && model != "" {
							self.models.append(model.uppercased())
						}
						
						if !self.colors.contains(where: { $0.uppercased() == color.uppercased()}) && color != "" {
							self.colors.append(color.uppercased())
						}
						
						if !self.states.contains(where: { $0.uppercased() == state.uppercased()}) && state != "" {
							self.states.append(state.uppercased())
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

    func initializeControls() {
        
        // Make enter key close keyboard
        self.licensePlateTextField.delegate = self
        
        // Set the title or else the title is used from another tab
        self.navigationItem.title = "Search For Towed Vehicles"
        
        // Style and add images to button
        self.common.styleButton(searchTowedVehiclesButton, "search_circle")
        
    }
    
    // Make enter key close keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK: Action methods
    
    @IBAction func searchTowedVehiclesTapped(_ sender: Any) {
        
        // Add haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        
        var towedVehicles = [VehicleModel]()
        
        // Get selected values from controls
        let selectedMake = self.makePicker.selectedRow(inComponent: 0) > 0 ? self.makes[self.makePicker.selectedRow(inComponent: 0) - 1] : ""
        let selectedModel = self.modelPicker.selectedRow(inComponent: 0) > 0 ? self.models[self.modelPicker.selectedRow(inComponent: 0) - 1] : ""
        let selectedColor = self.colorPicker.selectedRow(inComponent: 0) > 0 ? self.colors[self.colorPicker.selectedRow(inComponent: 0) - 1] : ""
        let selectedState = self.statePicker.selectedRow(inComponent: 0) > 0 ? self.states[self.statePicker.selectedRow(inComponent: 0) - 1] : ""
        let plate = licensePlateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased().replacingOccurrences(of: " ", with: "")
        
        // Create filter to be used in query
        var filter = selectedMake != "" ? "\(self.common.defaults.towedMakeTitle()) = '\(selectedMake)'" : ""
        filter += selectedModel != "" ? " \(filter != "" ? " AND" : "") upper(\(self.common.defaults.towedModelTitle())) = '\(selectedModel)'" : ""
        filter += selectedColor != "" ? " \(filter != "" ? " AND" : "") upper(\(self.common.defaults.towedColorTitle())) = '\(selectedColor)'" : ""
        filter += selectedState != "" ? " \(filter != "" ? " AND" : "") upper(\(self.common.defaults.towedStateTitle())) = '\(selectedState)'" : ""
        filter += plate! != "" ? " \(filter != "" ? " AND" : "") upper(\(self.common.defaults.towedPlateTitle())) like '%\(plate!)%'" : ""
        
        // Create SODA client
        let towedClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
        
        // Create SODA query
        let towedQuery = towedClient.query(dataset: self.common.defaults.towedDataset())
            .filter(filter)
            .orderAscending(self.common.defaults.towedMakeTitle())
            .limit(500)
        
        towedQuery.get { res in
            switch res {
            case .dataset (let data):
                
                if data.count > 0 {
                    
                    // Loop through towed vehicle data
                    for (_, item) in data.enumerated() {
                        
                        // Get values for each towed vehicle
                        var towedDate = item[self.common.defaults.towedDateTitle()] as? String ?? ""
                        let make = item[self.common.defaults.towedMakeTitle()] as? String ?? ""
                        let model = item[self.common.defaults.towedModelTitle()] as? String ?? ""
                        let style = item[self.common.defaults.towedStyleTitle()] as? String ?? ""
                        let color = item[self.common.defaults.towedColorTitle()] as? String ?? ""
                        let plate = item[self.common.defaults.towedPlateTitle()] as? String ?? ""
                        let state = item[self.common.defaults.towedStateTitle()] as? String ?? ""
                        let inventoryNumber = item[self.common.defaults.towedInventoryNumberTitle()] as? String ?? ""
                        let towedToAddress = item[self.common.defaults.towedToAddressTitle()] as? String ?? ""
                        let towedToPhone = item[self.common.defaults.towedToPhoneTitle()] as? String ?? ""
                        
                        // Change date to MM/dd/yyyy
                        towedDate = Date.getFormattedDate(towedDate, "yyyy-MM-dd'T'HH:mm:ss.SSS")
                        
                        let vehicle = VehicleModel()
                        vehicle.towedDate = towedDate
                        vehicle.make = make
                        vehicle.model = model
                        vehicle.style = style
                        vehicle.color = color
                        vehicle.plate = plate
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
                    self.common.showAlert("Search Completed", "No vehicles matching your search criteria were found.")
                }
            case .error (let err):
                print((err as NSError).userInfo.debugDescription)
            }
        }
    }
    
    // MARK: Picker view methods
    
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
	
}
