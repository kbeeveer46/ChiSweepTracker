import UIKit
import MapKit
import THLabel

class DivvyDetailViewController: UIViewController, MKMapViewDelegate {

	// Controls
	@IBOutlet weak var stationMapView: MKMapView!
	@IBOutlet weak var stationMapViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var bikesAvailableLabel: UILabel!
	@IBOutlet weak var eBikesAvailableLabel: UILabel!
	@IBOutlet weak var docksAvailableLabel: UILabel!
	@IBOutlet weak var lastUpdatedLabel: UILabel!
	
	// Classes
	let common = Common()
    let defaults = Defaults()
	
	// Shared
	var station = DivvyStationModel()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Set the title
		self.navigationItem.title = "Divvy Station Details"
		
		// Load station map 
		self.loadStationMap()
		
		// Initialize controls per device
		self.initializeControlsPerDevice()
		
		// Populate divvy station label values
		self.populateStationLabels()
		
    }
	
	func initializeControlsPerDevice() {
		
		switch UIDevice().type {
		case .iPhoneSE:
			stationMapViewHeightConstraint.constant = 175
		default:
			break
		}
	}
	
	func populateStationLabels() {
		
		// Get JSON URL
        let url = URL(string: self.defaults.divvyJSONUrl())
		
		URLSession.shared.dataTask(with:url!, completionHandler: {(results, response, error) in
			guard let results = results, error == nil else { return }
			
			do {
				// Get entire JSON response
				let json = try JSONSerialization.jsonObject(with: results, options: .allowFragments) as? [String:Any]
				
				// Get last updated unix timestamp and convert it to local time
                let lastUpdated = json?[self.defaults.divvyJSONLastUpdatedTitle()] as? Double ?? 0.0
				let lastUpdatedUTCDate = NSDate(timeIntervalSince1970: lastUpdated)
				let lastUpdatedUTCDateFormatted = Date.getFormattedDate("\(lastUpdatedUTCDate)", "yyyy-MM-dd HH:mm:ss ZZZ", "MM/dd hh:mm a")
				
				// Get data element from JSON
				let data = json?["\(self.defaults.divvyJSONDataTitle())"] as? [String: Any] ?? [:]
				
				// Get station element from data
				let stations = data["\(self.defaults.divvyJSONStationsTitle())"] as? [[String: Any]] ?? []
				
				var bikesAvailable = 0
				var eBikesAvailable = 0
				var docksAvailable = 0
				
				// Loop through stations data to find matching station id and retrieve data
				for item in stations {
					
					let id = item["\(self.defaults.divvyJSONIdTitle())"] as? String ?? ""
					
					if (id.trimmingCharacters(in: .whitespaces) == self.station.id.trimmingCharacters(in: .whitespaces)) {
						
						bikesAvailable = item[self.defaults.divvyJSONBikesAvailableTitle()] as? Int ?? 0
						eBikesAvailable = item[self.defaults.divvyJSONEBikesAvailableTitle()] as? Int ?? 0
						docksAvailable = item[self.defaults.divvyJSONDocksAvailableTitle()] as? Int ?? 0
						
						break
					}
				}
				
				// Populate labels
				DispatchQueue.main.async {
					self.nameLabel.text = self.station.name
					self.statusLabel.text = self.station.status
					self.bikesAvailableLabel.text = "\(bikesAvailable)"
					self.eBikesAvailableLabel.text = "\(eBikesAvailable)"
					self.docksAvailableLabel.text = "\(docksAvailable)"
					self.lastUpdatedLabel.text = "\(lastUpdatedUTCDateFormatted)"
				}
				
			} catch {
				print("Divvy JSON error: \(error)")
			}
		}).resume()
	}
	
	func loadStationMap() {
		
		// Set properties for map
		self.stationMapView.delegate = self
		
		// Get polygon coordinates from schedule
		let coordinates = CLLocationCoordinate2D(latitude: Double(self.station.latitude)!, longitude: Double(self.station.longitude)!)
		
		// Create map annotation
		let annotation = CustomAnnotation()
		annotation.customImageName = "pin-divvy"
		annotation.coordinate = coordinates
		annotation.title = station.name
		
		// Create map span
		let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
		
		// Create map region from span
		let region = MKCoordinateRegion(center: coordinates, span: span)
		
		// Set map region
		stationMapView.setRegion(region, animated: false)
		
		// Add annotation to map
		stationMapView.removeAnnotations(stationMapView.annotations)
		stationMapView.addAnnotation(annotation)
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
		annotationLabel.strokeSize = 1 //self.common.selectedAnnotationStrokeSize()
		annotationLabel.strokeColor = UIColor.white
		annotationView?.addSubview(annotationLabel)
		
		return annotationView
	}
}
