import UIKit
import CoreLocation
import MapKit

class SelectSectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {

    @IBOutlet weak var sectionTableView: UITableView!
	@IBOutlet weak var selectSectionMap: MKMapView!
	
    var schedule = ScheduleModel()
    let common = Common()
    var sections: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get all sections in ward so user can select a section before going to the schedule view
		self.getSections()
		
		// Load map with default lat and long from search
		self.loadSelectSectionMap()
            
    }
	
	func getSections() {
		
		// Use Chicago data portal API to get sweep sections from user's ward
		
		sections.removeAll()
		
		let ward = self.schedule.ward
		
		let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
		
		let scheduleQuery = wardClient.query(dataset: self.common.scheduleDataset())
			.filter("\(self.common.ward()) = '\(ward)'")
		
		scheduleQuery.get { res in
			switch res {
			case .dataset (let data):
				
				if data.count > 0 {
					
					for (_, item) in data.enumerated() {
						
						let section = item[self.common.section()] as? String ?? ""
						
						if !section.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
							
							if !self.sections.contains(where: { $0 == section}) {
								self.sections.append(section)
							}
						}
					}
					
					self.sectionTableView.dataSource = self
					self.sectionTableView.delegate = self
					self.sectionTableView.reloadData()
				}
			case .error (let err):
				print("Could not get sections from ward: \((err as NSError).userInfo.debugDescription)")
				self.common.showAlert(self.common.constants.errorTitle, "Unble to get sweep section data for ward \(ward) from the City of Chicago")
			}
		}
	}
    
	// Get schedule after user selects a section
    func getSchedule() {
        
        schedule.months.removeAll()
        
        let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
        
        let scheduleQuery = wardClient.query(dataset: self.common.scheduleDataset())
            .filter("\(self.common.ward()) = '\(self.schedule.ward)' \(self.schedule.section != "" ? "AND \(self.common.section()) = '\(self.schedule.section)'" : "") ")
			.limit(1)
		
        scheduleQuery.get { res in
            switch res {
            case .dataset (let data):
                
                if data.count > 0 {
                    
                    for (_, item) in data.enumerated() {
                        
                        let monthName = item[self.common.month_name()] as? String ?? ""
                        let monthNumber = item[self.common.month_number()] as? String ?? ""
                        let dates = item[self.common.dates()] as? String ?? ""
                        let datesArray = dates.components(separatedBy: ",")
                        
                        print("getSchedule month name: \(monthName)")
                        print("getSchedule dates: \(datesArray)")
                        
                        let month = MonthModel()
                        month.name = monthName
                        month.number = monthNumber
                        
                        for day in datesArray {
                            
                            print("getSchedule date: \(day)")
                            
                            if !day.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                
                                let date = DateModel()
                                date.date = Int(day) ?? 0
                                
                                if !month.dates.contains(where: { $0.date == Int(day) ?? 0}) {
                                    month.dates.append(date)
                                }
                            }
                        }
                        
                        self.schedule.months.append(month)
                        
                    }
                
                    // Segue to schedule view now that schedule model is populated
                    self.performSegue(withIdentifier: "viewScheduleSegue", sender: self)
            
                }
            case .error (let err):
				print("Unable to get schedule data from getSchedule with error: \((err as NSError).userInfo.debugDescription)")
                self.common.showAlert(self.common.constants.errorTitle, "Unable to get sweep schedule data from the City of Chicago")
            }
        }
    }
	
	// Load map using use default values from search
	func loadSelectSectionMap() {
		
		selectSectionMap.delegate = self
		
		let addressFromDefaults = defaults.string(forKey: "defaultAddress") ?? ""
		let longitudeFromDefaults = defaults.double(forKey: "defaultLongitude")
		let latitudeFromDefaults = defaults.double(forKey: "defaultLatitude")
		
		if longitudeFromDefaults != 0 && latitudeFromDefaults != 0 {
			
			let location: CLLocation = CLLocation(latitude: latitudeFromDefaults, longitude: longitudeFromDefaults)
			
			let annotation = MKPointAnnotation()
			annotation.title = addressFromDefaults
			annotation.coordinate = location.coordinate
			
			let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
			let region = MKCoordinateRegion(center: location.coordinate, span: span)
			
			selectSectionMap.removeAnnotations(selectSectionMap.annotations)
			selectSectionMap.addAnnotation(annotation)
			selectSectionMap.setRegion(region, animated: true)
		}
	}
    
    // Section table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionTableCell", for: indexPath)
        let sectionLabel = cell.viewWithTag(1) as! UILabel
        sectionLabel.text = "Ward \(schedule.ward) - Section \(self.sections[indexPath.row])"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        
        self.schedule.section = sections[row]
        
        // Get schedule and go to schedule view when a user selects a section
        getSchedule()
        
    }
    
    // Pass schedule model to schedule view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let scheduleViewController = segue.destination as? ScheduleViewController {
            scheduleViewController.schedule = schedule
        }
    }
}
