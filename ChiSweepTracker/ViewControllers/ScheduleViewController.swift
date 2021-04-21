import UIKit
import CoreLocation
import MapKit
import THLabel

class ScheduleViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
	// Controls
    @IBOutlet weak var scheduleMapView: MKMapView!
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var scheduleMapViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var comingSoonStackView: UIStackView!
    @IBOutlet weak var comingSoonYearLabel: UILabel!
    
	// Shared
    let generator = UISelectionFeedbackGenerator()
    let currentYear = Calendar.current.component(.year, from: Date())
    
	// Classes
	let common = Common()
    var schedule = ScheduleModel()
    
	// MARK: Methods
	
    override func viewWillAppear(_ animated: Bool) {
		
		// Set title using latest app version (year)
		self.title = "Sweep Schedule - \(self.common.latestAppVersion())"
		
		// Show settings button in the top right
		if (
				schedule.address.trimmingCharacters(in: .whitespaces) != self.common.favoriteAddress().trimmingCharacters(in: .whitespaces) ||
				schedule.address.trimmingCharacters(in: .whitespaces) == self.common.favoriteAddress().trimmingCharacters(in: .whitespaces) && self.common.favoriteSection() != self.schedule.section
		   ) {
			self.navigationItem.rightBarButtonItem  = UIBarButtonItem(image: UIImage(named: "settings"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(openOptionsMenu))
		}
        else {
            self.navigationItem.rightBarButtonItem = nil
        }
		
		// Load map with annotations and overlays
		self.loadScheduleMap()
		
		// Initialize controls per device
		self.initializeControlsPerDevice()
		
		// Set required properties for schedule table view
		self.scheduleTableView.dataSource = self
		self.scheduleTableView.delegate = self
		self.scheduleTableView.reloadData()
        
	}
	
	func initializeControlsPerDevice() {
		
		switch UIDevice().type {
		case .iPhoneSE:
			scheduleMapViewHeightConstraint.constant = 175
			scheduleTableView.rowHeight = 37
		default:
			break
		}
		
	}
    
	// Method is called when user chooses yes to add a favorite
    @objc func addFavorite() {
        
		// Add haptic feedback
        generator.prepare()
        generator.selectionChanged()
        
        // Clear notifications created by previous favorite
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		
		// Unregister from Firebase Cloud Messaging notifications
		//UIApplication.shared.unregisterForRemoteNotifications()
		
		//print("Deleted user's local notifications")
        
        var favoriteAddresses = self.common.favoriteAddresses()
        
        for (index, element) in favoriteAddresses.enumerated() {
            if element[0] == "" {
                favoriteAddresses[index][0] = schedule.address
                favoriteAddresses[index][1] = "false"
                break
            }
        }
        
        defaults.set(favoriteAddresses, forKey: "favoriteAddresses")
                    
		
        // Set user favorites
        defaults.set(schedule.address, forKey: "favoriteAddress")
        defaults.set(schedule.ward, forKey: "favoriteWard")
        defaults.set(schedule.section, forKey: "favoriteSection") // Used when creating location notifications so we know the section in case there are multiple
        defaults.set(schedule.locationCoordinate.longitude, forKey: "favoriteLongitude")
        defaults.set(schedule.locationCoordinate.latitude, forKey: "favoriteLatitude")
		
		// defaultCoordinatesArray is set when user searches. Use its value for user's favorite
		let defaultCoordinates = defaults.object(forKey: "defaultCoordinatesArray") as? [[NSArray]] ?? nil
		defaults.set(defaultCoordinates, forKey: "favoriteCoordinatesArray")
		
		// Toggled off notifications when user adds a new favorite
        defaults.set(false, forKey: "notificationsToggled")
		
		//print("Added favorite address: \(self.common.favoriteAddress())")
        
        // Set right bar button to remove now that a favorite has been set
        //self.navigationItem.rightBarButtonItem = removeFavoriteButton
        
        // Create alert
        let alert = UIAlertController(title: "Favorite Saved", message: "Would you like to enable notifications?", preferredStyle: .alert)
		
		// Yes option
		alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
			// Segue to notifications view if they select yes
			self.performSegue(withIdentifier: "viewNotificationsFromScheduleSegue", sender: self)
		}))
		
		// No option
		alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
		// Present alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
	// Method is called when user chooses yes to remove a favorite
//    @objc func removeFavorite() {
//
//		// Add haptic feedback
//        generator.prepare()
//        generator.selectionChanged()
//
//        // Create alert
//        let alert = UIAlertController(title: "Remove Favorite Address?", message: "You will no longer receive notifications for this address", preferredStyle: .alert)
//
//		// Yes option
//		let yesAction = UIAlertAction(title: "Yes", style: .default, handler:{ action in
//
//			print("Deleted favorite address: \(self.common.favoriteAddress())")
//
//			// Clear favorites from defaults
//			defaults.set("", forKey: "favoriteAddress")
//			defaults.set("", forKey: "favoriteWard")
//			defaults.set("", forKey: "favoriteSection")
//			defaults.set(0.0, forKey: "favoriteLatitude")
//			defaults.set(0.0, forKey: "favoriteLongitude")
//			defaults.set(nil, forKey: "favoriteCoordinatesArray")
//			defaults.set(false, forKey: "notificationsToggled")
//
//			// Remove any notifications set from their previous favorite
//			UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//
//			// Unregister from Firebase Cloud Messaging notifications
//			UIApplication.shared.unregisterForRemoteNotifications()
//
//			//print("Deleted user's local notifications")
//
//			// Set right bar button to add now that a favorite has been removed
//			//self.navigationItem.rightBarButtonItem = self.addFavoriteButton
//
//		})
//		yesAction.setValue(UIColor.red, forKey: "titleTextColor")
//		alert.addAction(yesAction)
//
//		// No option
//        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//
//		// Present alert
//        self.present(alert, animated: true, completion: nil)
//
//    }
	
	@objc func openOptionsMenu() {
		
		// Add haptic feedback
		let generator = UISelectionFeedbackGenerator()
		generator.prepare()
		generator.selectionChanged()
		
		// Get favorite address
		let favoriteAddress = self.common.favoriteAddress()
		
		// Create options alert
		let optionsAlert = UIAlertController(title: nil, message: "Options", preferredStyle: .actionSheet)
		
		// Create remove favorite option for options alert
		//let removeFavoriteAction = UIAlertAction(title: "Remove Favorite Address", style: .default, handler:{ action in
		//	self.removeFavorite()
		//})
		//removeFavoriteAction.setValue(UIColor.red, forKey: "titleTextColor")
		
		// Create add favorite option for options alert
		let saveFavoriteAction = UIAlertAction(title: "Save As Favorite Address", style: .default, handler:{ action in
			self.addFavorite()
		})
		
		if favoriteAddress != schedule.address ||
		   (favoriteAddress == schedule.address && self.common.favoriteSection() != self.schedule.section) {
			
			optionsAlert.addAction(saveFavoriteAction)
		}
		//else {
		//	optionsAlert.addAction(removeFavoriteAction)
		//}
		
		let favoriteImage = UIImage(named: "star")
		if let icon = favoriteImage?.imageWithSize(scaledToSize: CGSize(width: 32, height: 32)) {
			saveFavoriteAction.setValue(icon, forKey: "image")
			//removeFavoriteAction.setValue(icon, forKey: "image")
		}
		
		// Create cancel option for options alert
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		
		// Add options to options alert
		optionsAlert.addAction(cancelAction)
		
		// Present options alert
		self.present(optionsAlert, animated: true, completion: nil)
		
	}
	
	// Load schedule map with annotation and polygons
	func loadScheduleMap() {
		
		// Set required map properties
		scheduleMapView.delegate = self
		
		// Create polygons
		let coordinates = self.schedule.polygonCoordinates
		let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
		
		// Create annotation
		let annotation = CustomAnnotation()
		annotation.customImageName = "pin-address"
		annotation.coordinate = self.schedule.locationCoordinate
		annotation.title = "\(self.schedule.address)"
		annotation.subtitle = "Ward: \(self.schedule.ward) - Section: \(self.schedule.section)"
		
		// Create span and region
		let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
		let region = MKCoordinateRegion(center: self.schedule.locationCoordinate, span: span)
		
		// Set region
		scheduleMapView.setRegion(region, animated: false)
		
		// Add polygons to map
		scheduleMapView.removeOverlays(scheduleMapView.overlays)
		scheduleMapView.addOverlay(polygon)
		
		// Add annotation to map
		scheduleMapView.addAnnotation(annotation)
        
        if (self.currentYear > self.common.latestAppVersion()) {
            self.comingSoonStackView.isHidden = false
            self.comingSoonYearLabel.text = "The \(self.currentYear) sweeping schedule is coming soon."
        }
        else {
            self.comingSoonStackView.isHidden = true
        }
		
	}

    // Months/Days table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule.months.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
        
        // Add haptic feedback
        generator.prepare()
        generator.selectionChanged()
        
		// Get selected month and send user to calendar view
		
		// Get cell from table view
        let cell = tableView.cellForRow(at: indexPath)!
		
		// Get days label from cell
        let daysLabel = cell.viewWithTag(2) as! UILabel
		
		// Get list of days from days label
        let days = daysLabel.text!.trimmingCharacters(in: .whitespaces)
        
        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController {
            
			// Pass month name, number, days, and schededule to calendar view
			destinationViewController.selectedMonthNumber = Int(schedule.months[indexPath.row].number) ?? 0
            destinationViewController.selectedMonthName = schedule.months[indexPath.row].name
            destinationViewController.selectedDates = days
            destinationViewController.schedule = self.schedule
            self.navigationController?.pushViewController(destinationViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
		// Get cell from table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleTableCell", for: indexPath)
        
		// Get labels from cell
		let monthNameLabel = cell.viewWithTag(1) as! UILabel
        let daysLabel = cell.viewWithTag(2) as! UILabel

        // Concatenate dates in one string and add padding between days
        var dates = ""
        for date in schedule.months[indexPath.row].dates  {
            dates = dates + String(date.date).padding(toLength: 5, withPad: " ", startingAt: 0)
        }

		// Set label text
        monthNameLabel.text = schedule.months[indexPath.row].name
		daysLabel.text = dates
		
		// If month equals the current month then change the labels to blue
		let date = Date()
		if (date.month.uppercased() == schedule.months[indexPath.row].name.uppercased()) &&
           (self.currentYear == self.common.latestAppVersion()) {
			daysLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
			daysLabel.textColor = UIColor(hexString: self.common.constants.systemBlue)
			monthNameLabel.textColor = UIColor(hexString: self.common.constants.systemBlue)
		}

        return cell
        
    }
    
	// Method required to add polygons to schedule map
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
		annotationLabel.strokeSize = 1 //self.common.selectedAnnotationStrokeSize()
		annotationLabel.strokeColor = UIColor.white
		annotationView?.addSubview(annotationLabel)
		
		return annotationView
	}
}
