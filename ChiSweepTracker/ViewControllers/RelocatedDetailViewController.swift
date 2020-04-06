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
	@IBOutlet weak var relocatedFromAddressButton: UIButton!
	@IBOutlet weak var reasonLabel: UILabel!
	@IBOutlet weak var relocatedDetailStackView: UIStackView!
	
	// Shared
	var relocatedVehicle = VehicleModel()
	var toLatitude = 0.0
	var toLongitude = 0.0
	
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
			relocatedDetailMapHeightConstraint.constant = 175
			relocatedDetailStackView.spacing = 15
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
		relocatedFromAddressButton.setTitle(relocatedVehicle.relocatedFromAddress, for: .normal)
		addressButton.setTitle(relocatedVehicle.relocatedToAddress, for: .normal)
		reasonLabel.text = relocatedVehicle.relocatedReason
		
	}
    
	// Load map using use default values from search
	func loadRelocatedDetailMap() {
		
		// Set properties for map
		self.relocatedDetailMap.delegate = self
		self.relocatedDetailMap.layoutMargins = UIEdgeInsets(top: 60, left: 60, bottom: 60, right: 60)
		self.relocatedDetailMap.removeAnnotations(self.relocatedDetailMap.annotations)
		self.relocatedDetailMap.removeOverlays(self.relocatedDetailMap.overlays)
		
		// Do not remove this. Used to zoom in on map before view loads.
		
		// Create location from from lat and long
		let centerLocation = CLLocationCoordinate2D(latitude: Double(self.relocatedVehicle.relocatedFromLatitude)!, longitude: Double(self.relocatedVehicle.relocatedFromLongitude)!)
		
		// Create map span
		let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
		
		// Create map region from span
		let region = MKCoordinateRegion(center: centerLocation, span: span)
		
		// Set map region
		relocatedDetailMap.setRegion(region, animated: false)
		
		//
		
		// Add "Chicago, IL" to end of address if it doesn't exist to help find the address when it's clicked
		var relocatedToAddress = relocatedVehicle.relocatedToAddress
		if (!relocatedToAddress.contains("Chicago")) {
			relocatedToAddress += " Chicago, IL"
		}
		
		// Get coordinates from relocated to address
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(relocatedToAddress) { placemarks, error in
			
			// No internet connection will cause an error
			if error != nil {
				print("Error getting relocated to address lat and long: \(error!)")
				return
			}
			
			if placemarks != nil {
								
				// Get first placemark in list
				let placemark = placemarks?.first
				
				// Create coorindates from placemark
				self.toLatitude = placemark?.location?.coordinate.latitude ?? 0
				self.toLongitude = placemark?.location?.coordinate.longitude ?? 0
				
				// Create from and to location using lat and long
				let fromLocation = CLLocation(latitude: Double(self.relocatedVehicle.relocatedFromLatitude)!, longitude: Double(self.relocatedVehicle.relocatedFromLongitude)!)
				let toLocation = CLLocation(latitude: self.toLatitude, longitude: self.toLongitude)
				
				// Create from and to annotation from location coordinate
				let fromAnnotation = CustomAnnotation()
				fromAnnotation.customImageName = "pin-relocated"
				fromAnnotation.coordinate = fromLocation.coordinate
				fromAnnotation.title = "Relocated From: \(self.relocatedVehicle.relocatedFromAddress)"
			
				let toAnnotation = CustomAnnotation()
				toAnnotation.customImageName = "pin-relocated"
				toAnnotation.coordinate = toLocation.coordinate
				toAnnotation.title = "Relocated To: \(self.relocatedVehicle.relocatedToAddress)"
				
				// Add from and to annotations
				self.relocatedDetailMap.addAnnotation(fromAnnotation)
				self.relocatedDetailMap.addAnnotation(toAnnotation)
				
				// Initialize directions request with from and to annotations
				let request = MKDirections.Request()
				request.destination = MKMapItem(placemark: MKPlacemark(coordinate: toAnnotation.coordinate, addressDictionary: nil))
				request.source = MKMapItem(placemark: MKPlacemark(coordinate: fromAnnotation.coordinate, addressDictionary: nil))
				
				// Create directions object from request
				let directions = MKDirections(request: request)
				
				// Calculate directions based on destination and source
				directions.calculate { [unowned self] response, error in
					guard let unwrappedResponse = response else { return }

					if (unwrappedResponse.routes.count > 0) {
						//self.relocatedDetailMap.addOverlay(unwrappedResponse.routes[0].polyline)
						self.relocatedDetailMap.setVisibleMapRect(unwrappedResponse.routes[0].polyline.boundingMapRect, animated: true)
					}
				}
			}
		}
	}
	
//	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//
//		assert(overlay is MKPolyline, "overlay must be polyline")
//
//		let polylineRenderer = MKPolylineRenderer(overlay: overlay)
//		polylineRenderer.strokeColor = UIColor(hexString: "#FF7832")
//		polylineRenderer.lineWidth = 3
//		return polylineRenderer
//	}
	
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
	
	@IBAction func relocatedFromAddressTapped(_ sender: Any) {
		
		let coordinates = CLLocationCoordinate2DMake(Double(self.relocatedVehicle.relocatedFromLatitude)!, Double(self.relocatedVehicle.relocatedFromLongitude)!)
		
		let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
		
		let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
		
		let mapItem = MKMapItem(placemark: placemark)
		
		mapItem.name = relocatedVehicle.relocatedFromAddress
		
		mapItem.openInMaps(launchOptions:[MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center)] as [String : Any])
		
	}
	
	@IBAction func addressButtonTapped(_ sender: Any) {
		
		let coordinates = CLLocationCoordinate2DMake(self.toLatitude, self.toLongitude)
		
		let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
		
		let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
		
		let mapItem = MKMapItem(placemark: placemark)
		
		mapItem.name = relocatedVehicle.relocatedToAddress
		
		mapItem.openInMaps(launchOptions:[MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center)] as [String : Any])
	}
	
}
