import UIKit
import CoreLocation
import MapKit

class ScheduleViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
	// Controls
    @IBOutlet weak var scheduleMapView: MKMapView!
	@IBOutlet weak var scheduleMapViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scheduleTableView: UITableView!
	
	// Shared
    let generator = UISelectionFeedbackGenerator()
	var addFavoriteButton = UIBarButtonItem()
	var removeFavoriteButton = UIBarButtonItem()
	
	// Classes
	let common = Common()
    var schedule = ScheduleModel()
    
	// MARK: Methods
	
    override func viewWillAppear(_ animated: Bool) {
		
		// Set title using latest app version (year)
		self.title = "Sweep Schedule - \(self.common.latestAppVersion())"
		
		// Show add or remove favorite button
		self.setAddRemoveFavoriteButton()
		
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
			scheduleMapViewHeightConstraint.constant = 150
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
		
		print("Deleted user's local notifications")
		
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
		
		print("Added favorite address: \(self.common.favoriteAddress())")
        
        // Set right bar button to remove now that a favorite has been set
        self.navigationItem.rightBarButtonItem = removeFavoriteButton
        
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
    @objc func removeFavorite() {
        
		// Add haptic feedback
        generator.prepare()
        generator.selectionChanged()
        
        // Create alert
        let alert = UIAlertController(title: "Delete Favorite?", message: "You will no longer receive notifications", preferredStyle: .alert)
        
		// Yes option
		alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
			
			print("Deleted favorite address: \(self.common.favoriteAddress())")
			
			// Clear favorites from defaults
			defaults.set("", forKey: "favoriteAddress")
			defaults.set("", forKey: "favoriteWard")
			defaults.set("", forKey: "favoriteSection")
			defaults.set(0.0, forKey: "favoriteLatitude")
			defaults.set(0.0, forKey: "favoriteLongitude")
			defaults.set(nil, forKey: "favoriteCoordinatesArray")
			defaults.set(false, forKey: "notificationsToggled")
			
            // Remove any notifications set from their previous favorite
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
			
			// Unregister from Firebase Cloud Messaging notifications
			UIApplication.shared.unregisterForRemoteNotifications()
			
			print("Deleted user's local notifications")
            
            // Set right bar button to add now that a favorite has been removed
            self.navigationItem.rightBarButtonItem = self.addFavoriteButton
            
        }))
		
		// No option
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
		
		// Present alert
        self.present(alert, animated: true, completion: nil)
        
    }
	
	func setAddRemoveFavoriteButton() {
		
		// If user has a favorite address and it matches the address they're viewing then show the remove favorite button, otherwise show add button
		
		// Get favorite address
		let favoriteAddress = self.common.favoriteAddress()
		
		// Initialize add button
		addFavoriteButton = UIBarButtonItem(image: UIImage(named: "star_border"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(addFavorite))
		
		// Initialize remove button
		removeFavoriteButton = UIBarButtonItem(image: UIImage(named: "star"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(removeFavorite))
		
		// Set top right navigation button to either add or remove
		if favoriteAddress != schedule.address {
			self.navigationItem.rightBarButtonItem = addFavoriteButton
		}
		else {
			self.navigationItem.rightBarButtonItem = removeFavoriteButton
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
        
		// Get month name from cell
		let monthNameLabel = cell.viewWithTag(1) as! UILabel
		
		// Get days label from cell
        let daysLabel = cell.viewWithTag(2) as! UILabel

        // Concatenate dates in one string and add padding between days
        var dates = ""
        for date in schedule.months[indexPath.row].dates  {
            dates = dates + String(date.date).padding(toLength: 5, withPad: " ", startingAt: 0)
        }

		// Set month label text
        monthNameLabel.text = schedule.months[indexPath.row].name
		
		// Set days label text
        daysLabel.text = dates

        return cell
        
    }
    
	// Load schedule map with annotation and polygons
    func loadScheduleMap() {
        
		// Set required map properties
        scheduleMapView.delegate = self
        
		// Create polygons
        let coordinates = self.schedule.polygonCoordinates
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        
		// Create annotation
        let annotation = MKPointAnnotation()
        annotation.title = "\(self.schedule.address)"
        annotation.subtitle = "Ward \(self.schedule.ward) - Section \(self.schedule.section)"
        annotation.coordinate = self.schedule.locationCoordinate
        
		// Create span and region
        let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
        let region = MKCoordinateRegion(center: self.schedule.locationCoordinate, span: span)
        
		// Set region
        scheduleMapView.setRegion(region, animated: true)
        
		// Add polygons to map
		scheduleMapView.removeOverlays(scheduleMapView.overlays)
        scheduleMapView.addOverlay(polygon)
		
		// Add annotation to map
        scheduleMapView.addAnnotation(annotation)
        
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
}
