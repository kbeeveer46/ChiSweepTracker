import UIKit
import MapKit
import THLabel

class TowedDetailViewController: UIViewController, MKMapViewDelegate {
	
	// Controls
	@IBOutlet weak var towedDetailMapView: MKMapView!
	@IBOutlet weak var towedDetailMapViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var makeLabel: UILabel!
	@IBOutlet weak var modelLabel: UILabel!
	@IBOutlet weak var colorLabel: UILabel!
	@IBOutlet weak var stateLabel: UILabel!
	@IBOutlet weak var plateLabel: UILabel!
	@IBOutlet weak var towedDateLabel: UILabel!
	@IBOutlet weak var towedToAddressLabel: UILabel!
	@IBOutlet weak var towedToPhoneLabel: UILabel!
	@IBOutlet weak var inventoryNumberLabel: UILabel!
	
	// Shared
	var towedVehicle = TowedVehicleModel()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Set the title
		self.navigationItem.title = "Towed Vehicle Details"
		
		// Load detail map and show towed to location pin
		self.loadDetailSectionMap()
		
		// Populate labels with data from towed vehicle
		self.populateTowedVehicleLabels()
		
		// Initialize controls per device
		self.initializeControlsPerDevice()
		
    }
	
	func populateTowedVehicleLabels() {
		
		makeLabel.text = towedVehicle.make
		modelLabel.text = towedVehicle.model
		colorLabel.text = towedVehicle.color
		stateLabel.text = towedVehicle.state
		plateLabel.text = towedVehicle.plate
		towedDateLabel.text = towedVehicle.towedDate
		towedToAddressLabel.text = towedVehicle.towedToAddress
		towedToPhoneLabel.text = towedVehicle.towedToPhone
		inventoryNumberLabel.text = towedVehicle.inventoryNumber
		
	}
	
	func initializeControlsPerDevice() {
		
		switch UIDevice().type {
		case .iPhoneSE:
			towedDetailMapViewHeightConstraint.constant = 150
		default:
			break
		}
		
	}
	
	// Load map using use default values from search
	func loadDetailSectionMap() {
		
		// Set required properties for map
		towedDetailMapView.delegate = self
		
		// Get coordinates from address
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(towedVehicle.towedToAddress + " Chicago") { placemarks, error in
			
			// No internet connection will cause an error
			if error != nil {
				//self.common.showAlert(self.common.constants.errorTitle, self.common.constants.noInternetConnectionSearchMessage)
				//return
			}
			
			if placemarks != nil {
				
				// Get first placemark in list
				let placemark = placemarks?.first
				
				// Create coorindates from placemark
				let latitude = placemark?.location?.coordinate.latitude ?? 0
				let longitude = placemark?.location?.coordinate.longitude ?? 0
				
				// Create location from lat and long
				let location: CLLocation = CLLocation(latitude: latitude, longitude: longitude)
				
				// Create annotation from location coordinate
				let annotation = CustomPointAnnotation()
				annotation.customImageName = "pin-red"
				annotation.coordinate = location.coordinate
				annotation.title = self.towedVehicle.towedToAddress
				annotation.subtitle = "Phone: \(self.towedVehicle.towedToPhone) - Inventory #: \(self.towedVehicle.inventoryNumber)"
				
				// Create span and region
				let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
				let region = MKCoordinateRegion(center: location.coordinate, span: span)
				
				// Add annotation
				self.towedDetailMapView.removeAnnotations(self.towedDetailMapView.annotations)
				self.towedDetailMapView.addAnnotation(annotation)
				
				// Set region
				self.towedDetailMapView.setRegion(region, animated: true)
			}
		}
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
		
		let customPointAnnotation = annotation as! CustomPointAnnotation
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
