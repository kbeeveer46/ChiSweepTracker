import UIKit
import CoreLocation
import MapKit
import THLabel

class SelectSectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {

	// Controls
    @IBOutlet weak var sectionTableView: UITableView!
	@IBOutlet weak var selectSectionMap: MKMapView!
	@IBOutlet weak var selectSectionMapHeightConstraint: NSLayoutConstraint!
	
	// Classes
    var schedule = ScheduleModel()
    let common = Common()
	
	// Shared
    var sections: [String] = []
	
	// MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get all sections in ward so user can select a section before going to the schedule view
		self.getSections()
		
		// Load map with default lat and long from search
		self.loadSelectSectionMap()
		
		// Initialize controls per device
		self.initializeControlsPerDevice()
            
    }
	
	func initializeControlsPerDevice() {
		
		switch UIDevice().type {
		case .iPhoneSE:
			selectSectionMapHeightConstraint.constant = 175
		default:
			break
		}
		
	}
	
	func getSections() {
		
		// Use Chicago data portal API to get sweep sections from user's ward
		
		// Clear sections from schedule so there are no duplicates
		sections.removeAll()
		
		// Get ward from schedule
		let ward = self.schedule.ward
		
		// Create SODA client using domain and token
		let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
		
		// Query SODA API to get sections
		let scheduleQuery = wardClient.query(dataset: self.common.scheduleDataset())
			.filter("\(self.common.wardTitle()) = '\(ward)'")
		
		scheduleQuery.get { res in
			switch res {
			case .dataset (let data):
				
				if data.count > 0 {
					
					// Loop through json data
					for (_, item) in data.enumerated() {
						
						// Get section
						let section = item[self.common.sectionTitle()] as? String ?? ""
						
						// Add section to sections list
						if !section.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
							
							if !self.sections.contains(where: { $0 == section}) {
								self.sections.append(section)
							}
						}
					}
					
					// Set required properties for table view
					self.sectionTableView.backgroundColor = UIColor(hexString: self.common.constants.background)
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
        
		// Clear months from schedule to make sure there aren't duplicates
        schedule.months.removeAll()
        
		// Create SODA client using domain and token
        let sodaClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
        
		// Query SODA API to get schedule
        let scheduleQuery = sodaClient.query(dataset: self.common.scheduleDataset())
            .filter("\(self.common.wardTitle()) = '\(self.schedule.ward)' \(self.schedule.section != "" ? "AND \(self.common.sectionTitle()) = '\(self.schedule.section)'" : "") ")
			.orderAscending(self.common.monthNumberTitle())
		
        scheduleQuery.get { res in
            switch res {
            case .dataset (let data):
                
                if data.count > 0 {
                    
					// Loop through months
                    for (_, item) in data.enumerated() {
                        
						// Get values from json data
                        let monthName = item[self.common.monthNameTitle()] as? String ?? ""
                        let monthNumber = item[self.common.monthNumberTitle()] as? String ?? ""
                        let dates = item[self.common.dates()] as? String ?? ""
                        let datesArray = dates.components(separatedBy: ",").sorted {$0.localizedStandardCompare($1) == .orderedAscending}
                        
                        //print("getSchedule month name: \(monthName)")
                        //print("getSchedule dates: \(datesArray)")
                        
						// Create month object
                        let month = MonthModel()
                        month.name = monthName
                        month.number = monthNumber
                        
						// Loop through dates
                        for day in datesArray {
                            
                            //print("getSchedule date: \(day)")
                            
							// Add date to month
                            if !day.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                
                                let date = DateModel()
                                date.date = Int(day) ?? 0
                                
                                if !month.dates.contains(where: { $0.date == Int(day) ?? 0}) {
                                    month.dates.append(date)
                                }
                            }
                        }
                        
						// Add month to schedule
                        self.schedule.months.append(month)
                        
                    }
                
                    // Segue to schedule view now that schedule model is populated
					if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
						destinationViewController.schedule = self.schedule
						self.navigationController?.pushViewController(destinationViewController, animated: true)
					}
					return
            
                }
            case .error (let err):
				print("Unable to get schedule data from getSchedule with error: \((err as NSError).userInfo.debugDescription)")
                self.common.showAlert(self.common.constants.errorTitle, "Unable to get sweep schedule data from the City of Chicago")
            }
        }
    }
	
	// Load map using use default values from search
	func loadSelectSectionMap() {
		
		// Set required properties for map
		selectSectionMap.delegate = self
		
		// Get default values
		let addressFromDefaults = self.common.defaultAddress()
		let longitudeFromDefaults = self.common.defaultLongitude()
		let latitudeFromDefaults = self.common.defaultLatitude()
		let coordinatesFromDefaults = self.common.defaultCoordinatesArray()
		var mapOverlayCoordinates = [CLLocationCoordinate2D]()
		
		if longitudeFromDefaults != 0 && latitudeFromDefaults != 0 {
			
			// Loop through default coordinates array
			if coordinatesFromDefaults.count > 0 {
				for(_, coordinate) in coordinatesFromDefaults.enumerated() {
					for item in coordinate {
						
						// Add coordinates to array for map
						var coordinate = CLLocationCoordinate2D()
						coordinate.longitude = item[0] as? Double ?? 0
						coordinate.latitude = item[1] as? Double ?? 0
						mapOverlayCoordinates.append(coordinate)
					}
				}
			}
			
			// Create polygons from coordinates
			let polygons = MKPolygon(coordinates: mapOverlayCoordinates, count: mapOverlayCoordinates.count)
			
			// Create location from default lat and long
			let location: CLLocation = CLLocation(latitude: latitudeFromDefaults, longitude: longitudeFromDefaults)
			
			// Create annotation from location coordinate
			let annotation = CustomAnnotation()
			annotation.customImageName = "pin-address"
			annotation.coordinate = location.coordinate
			annotation.title = addressFromDefaults
			
			// Create span and region
			let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
			let region = MKCoordinateRegion(center: location.coordinate, span: span)
			
			// Add annotation
			selectSectionMap.removeAnnotations(selectSectionMap.annotations)
			selectSectionMap.addAnnotation(annotation)
			
			// Add polygon overlays
			selectSectionMap.addOverlay(polygons)
			
			// Set region
			selectSectionMap.setRegion(region, animated: false)
		}
	}
	
	// Method required to add polygons to section map
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		
		if overlay is MKPolygon {
			
			if let polygon = overlay as? MKPolygon {
				
				let renderer = MKPolygonRenderer(polygon: polygon)
				renderer.fillColor = .red
				renderer.alpha = 0.4
				return renderer
				
			}
		}
		
		return MKOverlayRenderer(overlay: overlay)
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		let reuseIdentifier = "pin"
		
		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
		
		if annotationView == nil {
			
			annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
			annotationView?.canShowCallout = true
			
		}
		else {
			
			annotationView?.annotation = annotation
			
		}
		
		let customPointAnnotation = annotation as! CustomAnnotation
		annotationView?.image = UIImage(named: customPointAnnotation.customImageName)
		annotationView?.centerOffset = CGPoint(x: 0, y: -(annotationView?.image!.size.height)!/2)
		annotationView?.subviews.forEach({ $0.removeFromSuperview() })
		
		let annotationLabel = THLabel(frame: CGRect(x: -40, y: 50, width: 125, height: 30))
		annotationLabel.lineBreakMode = .byWordWrapping
		annotationLabel.textAlignment = .center
		annotationLabel.font = .boldSystemFont(ofSize: 11)
		annotationLabel.text = annotation.title!
		annotationLabel.strokeSize = 1
		annotationLabel.strokeColor = UIColor.white
		annotationView?.addSubview(annotationLabel)
		
		return annotationView
	}
    
    // Section table view methods
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
		// Get cell from table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionTableCell", for: indexPath)
		
		// Set cell background color
		cell.contentView.backgroundColor = UIColor(hexString: self.common.constants.background)
		
		// Get section label from cell
        let sectionLabel = cell.viewWithTag(1) as! UILabel
		
		// Set section label text with ward and section number
        sectionLabel.text = "Ward \(schedule.ward) - Section \(self.sections[indexPath.row])"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
		// Get schedule and go to schedule view when a user selects a section
		
        let row = indexPath.row
        
        self.schedule.section = sections[row]
        
        getSchedule()
        
    }
    
}
