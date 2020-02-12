import UIKit
import MapKit
import THLabel

class RelocatedDetailViewController: UIViewController, MKMapViewDelegate {

	// Controls
	@IBOutlet weak var relocatedDetailMap: MKMapView!
	@IBOutlet weak var relocatedDetailMapHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var makeLabel: UILabel!
	@IBOutlet weak var colorLabel: UILabel!
	@IBOutlet weak var stateLabel: UILabel!
	@IBOutlet weak var plateLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var addressButton: UIButton!
	@IBOutlet weak var reasonLabel: UILabel!
	
	// Shared
	var relocatedVehicle = VehicleModel()
	var latitude = 0.0
	var longitude = 0.0
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Set the title
		self.navigationItem.title = "Relocated Vehicle Details"
		
		// Load detail map and show relocated to location pin
		self.loadRelocatedDetailMap()
		
		// Populate labels with data from relocated vehicle
		self.populateTowedVehicleLabels()
		
		// Initialize controls per device
		self.initializeControlsPerDevice()
		
    }
	
	func initializeControlsPerDevice() {
		
		switch UIDevice().type {
		case .iPhoneSE:
			relocatedDetailMapHeightConstraint.constant = 150
		default:
			break
		}
	}
	
	func populateTowedVehicleLabels() {
		
		makeLabel.text = relocatedVehicle.make
		colorLabel.text = relocatedVehicle.color
		stateLabel.text = relocatedVehicle.state
		plateLabel.text = relocatedVehicle.plate
		dateLabel.text = relocatedVehicle.relocatedDate
		addressButton.setTitle(relocatedVehicle.relocatedToAddress, for: .normal)
		reasonLabel.text = relocatedVehicle.relocatedReason
		
	}
    
	// Load map using use default values from search
	func loadRelocatedDetailMap() {
		
		// Set required properties for map
		self.relocatedDetailMap.delegate = self
		
		if (!relocatedVehicle.relocatedToAddress.contains("Chicago")) {
			relocatedVehicle.relocatedToAddress += " Chicago, IL"
		}
		
		// Get coordinates from address
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(relocatedVehicle.relocatedToAddress) { placemarks, error in
			
			// No internet connection will cause an error
			if error != nil {
				//self.common.showAlert(self.common.constants.errorTitle, self.common.constants.noInternetConnectionSearchMessage)
				//return
			}
			
			if placemarks != nil {
				
				// Relocated to pin
				
				// Get first placemark in list
				let placemark = placemarks?.first
				
				// Create coorindates from placemark
				self.latitude = placemark?.location?.coordinate.latitude ?? 0
				self.longitude = placemark?.location?.coordinate.longitude ?? 0
				
				// Create location from lat and long
				let location: CLLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
				
				// Create annotation from location coordinate
				let annotation = CustomPointAnnotation()
				annotation.customImageName = "pin-orange"
				annotation.coordinate = location.coordinate
				annotation.title = self.relocatedVehicle.relocatedToAddress
				annotation.subtitle = "" //"Phone: \(self.towedVehicle.towedToPhone) - Inventory #: \(self.towedVehicle.inventoryNumber)"
				
				// Create span and region
				//let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
				//let region = MKCoordinateRegion(center: location.coordinate, span: span)
				
				// Set region
				//self.relocatedDetailMap.setRegion(region, animated: true)
				
				// Add annotation
				self.relocatedDetailMap.removeAnnotations(self.relocatedDetailMap.annotations)
				self.relocatedDetailMap.addAnnotation(annotation)
				
				// Relocated from pin
				
				// Create location from lat and long
				let location2: CLLocation = CLLocation(latitude: Double(self.relocatedVehicle.relocatedFromLatitude)!, longitude: Double(self.relocatedVehicle.relocatedFromLongitude)!)
				
				// Create annotation from location coordinate
				let annotation2 = CustomPointAnnotation()
				annotation2.customImageName = "pin-orange"
				annotation2.coordinate = location2.coordinate
				annotation2.title = "Relocated From" //self.relocatedVehicle.relocatedToAddress
				annotation2.subtitle = "" //"Phone: \(self.towedVehicle.towedToPhone) - Inventory #: \(self.towedVehicle.inventoryNumber)"
				self.relocatedDetailMap.addAnnotation(annotation2)
				
				
				let request = MKDirections.Request()
				request.source = MKMapItem(placemark: MKPlacemark(coordinate: annotation.coordinate, addressDictionary: nil))
				request.destination = MKMapItem(placemark: MKPlacemark(coordinate: annotation2.coordinate, addressDictionary: nil))
				request.requestsAlternateRoutes = true
				request.transportType = .walking
				
				let directions = MKDirections(request: request)
				
				directions.calculate { [unowned self] response, error in
					guard let unwrappedResponse = response else { return }
					
					if (unwrappedResponse.routes.count > 0) {
						self.relocatedDetailMap.addOverlay(unwrappedResponse.routes[0].polyline)
						self.relocatedDetailMap.setVisibleMapRect(unwrappedResponse.routes[0].polyline.boundingMapRect, animated: true)
					}
				}
				
			}
		}
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
					
		assert(overlay is MKPolyline, "overlay must be polyline")
		
		let polylineRenderer = MKPolylineRenderer(overlay: overlay)
		polylineRenderer.strokeColor = UIColor(hexString: "#FF7832")
		polylineRenderer.lineWidth = 5
		return polylineRenderer
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

	@IBAction func addressButtonTapped(_ sender: Any) {
		
		print("tapped")
		
	}
	
}
