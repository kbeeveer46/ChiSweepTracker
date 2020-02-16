import UIKit
import MapKit
import THLabel

class DivvyDetailViewController: UIViewController, MKMapViewDelegate {

	// Controls
	@IBOutlet weak var stationMapView: MKMapView!
	@IBOutlet weak var stationMapViewHeightConstraint: NSLayoutConstraint!
	
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
		
    }
	
	func initializeControlsPerDevice() {
		
		switch UIDevice().type {
		case .iPhoneSE:
			stationMapViewHeightConstraint.constant = 150
		default:
			break
		}
	}
	
	func loadStationMap() {
		
		// Set properties for map
		self.stationMapView.delegate = self
		
		// Get polygon coordinates from schedule
		let coordinates = CLLocationCoordinate2D(latitude: Double(self.station.latitude)!, longitude: Double(self.station.longitude)!)
		
		// Create map annotation
		let annotation = CustomAnnotation()
		annotation.customImageName = "pin-blue"
		annotation.coordinate = coordinates
		annotation.title = station.name
		//annotation.subtitle = "Ward: \(self.schedule.ward) - Section: \(self.schedule.section)"
		
		// Create map span
		let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
		
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
		
		let annotationLabel = THLabel(frame: CGRect(x: -40, y: 40, width: 125, height: 30))
		annotationLabel.lineBreakMode = .byWordWrapping
		annotationLabel.textAlignment = .center
		annotationLabel.font = .boldSystemFont(ofSize: 11)
		annotationLabel.text = annotation.title!
		annotationLabel.strokeSize = 1
		annotationLabel.strokeColor = UIColor.white
		annotationView?.addSubview(annotationLabel)
		
		return annotationView
	}
    
}
