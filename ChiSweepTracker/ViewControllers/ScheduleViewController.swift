import UIKit
import CoreLocation
import MapKit

class ScheduleViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var scheduleMapView: MKMapView!
    @IBOutlet weak var scheduleTableView: UITableView!
    
    let generator = UISelectionFeedbackGenerator()
	let common = Common()
    var schedule = ScheduleModel()
    let defaults = UserDefaults.standard
    var addFavoriteButton = UIBarButtonItem()
    var removeFavoriteButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
		self.title = "Sweep Schedule - \(self.common.constants.appVersion)"
        
        // Set default address to be used when app is re-opened
        defaults.set(schedule.address, forKey: "defaultAddress")
        
        // If user has a favorite address and it matches the address they're viewing then show the remove favorite button, otherwise show add button
        let favoriteAddress = defaults.string(forKey: "favoriteAddress") ?? ""
        addFavoriteButton = UIBarButtonItem(image: UIImage(named: "star_border"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(addFavorite))
        removeFavoriteButton = UIBarButtonItem(image: UIImage(named: "star"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(removeFavorite))
        
        if favoriteAddress != schedule.address {
            self.navigationItem.rightBarButtonItem = addFavoriteButton
        }
        else {
            self.navigationItem.rightBarButtonItem = removeFavoriteButton
        }
        //
        
        // Load map with annotations and overlays
        loadScheduleMap()
        
		// Set required properties for schedule table view
        self.scheduleTableView.dataSource = self
        self.scheduleTableView.delegate = self
        self.scheduleTableView.reloadData()

    }
    
    @objc func addFavorite() {
        
		// Add haptic feedback
        generator.prepare()
        generator.selectionChanged()
        
        // Clear notifications created by previous favorite
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Set user favorites
        // Section is used when creating location notifications that way we know the section in case there are multiple
        defaults.set(schedule.address, forKey: "favoriteAddress")
        defaults.set(schedule.ward, forKey: "favoriteWard")
        defaults.set(schedule.section, forKey: "favoriteSection")
        defaults.set(schedule.locationCoordinate.longitude, forKey: "favoriteLongitude")
        defaults.set(schedule.locationCoordinate.latitude, forKey: "favoriteLatitude")
		// Toggled off notifications when user adds a new favorite
        self.defaults.set(false, forKey: "notificationsToggled")
        
		// defaultCoordinatesArray is set when user searches. Use its value for user's favorite
        let defaultCoordinates = defaults.object(forKey: "defaultCoordinatesArray") as? [[NSArray]] ?? nil
        defaults.set(defaultCoordinates, forKey: "favoriteCoordinatesArray")
        
        // Set right bar button to remove now that a favorite has been set
        self.navigationItem.rightBarButtonItem = removeFavoriteButton
        
        // Alert the user that their favorite has been set and prompt them to enable notifications
        let alert = UIAlertController(title: "Favorite Saved", message: "Do you want to enable push notifications?", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
            self.performSegue(withIdentifier: "viewNotificationsFromScheduleSegue", sender: self)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func removeFavorite() {
        
		// Add haptic feedback
        generator.prepare()
        generator.selectionChanged()
        
        // Prompt the user  if they want to delete their favorite because they will no longer receive notifications
        let alert = UIAlertController(title: "Delete Favorite?", message: "You will no longer receive push notifications", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
            
            // Remove any notifications set from their previous favorite
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            // Clear favorites from defaults
            self.defaults.set("", forKey: "favoriteAddress")
            self.defaults.set("", forKey: "favoriteWard")
            self.defaults.set("", forKey: "favoriteSection")
            self.defaults.set(0.0, forKey: "favoriteLatitude")
            self.defaults.set(0.0, forKey: "favoriteLongitude")
            self.defaults.set(nil, forKey: "favoriteCoordinatesArray")
			self.defaults.set(false, forKey: "notificationsToggled")
            
            // Set right bar button to add now that a favorite has been removed
            self.navigationItem.rightBarButtonItem = self.addFavoriteButton
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        //
        
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
        let cell = tableView.cellForRow(at: indexPath)!
        let daysLabel = cell.viewWithTag(2) as! UILabel
        let days = daysLabel.text!.trimmingCharacters(in: .whitespaces)
        
        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController {
            destinationViewController.selectedMonthNumber = Int(schedule.months[indexPath.row].number) ?? 0
            destinationViewController.selectedMonthName = schedule.months[indexPath.row].name
            destinationViewController.selectedDates = days
            destinationViewController.schedule = self.schedule
            self.navigationController?.pushViewController(destinationViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleTableCell", for: indexPath)
        let monthNameLabel = cell.viewWithTag(1) as! UILabel
        let daysLabel = cell.viewWithTag(2) as! UILabel

        // Put dates in one string and add padding between days
        var dates = ""
        for date in schedule.months[indexPath.row].dates  {
            dates = dates + String(date.date).padding(toLength: 5, withPad: " ", startingAt: 0)
        }

        monthNameLabel.text = schedule.months[indexPath.row].name
        daysLabel.text = dates

        // TODO: Style past months in grey color?
//        let currentMonthNumber = Calendar.current.component(.month, from: Foundation.Date())
//
//        if currentMonthNumber > schedule.months[indexPath.row].number {
//
//            monthNameLabel.textColor = .lightGray
//            daysLabel.textColor = .lightGray
//
//        }

        return cell
        
    }
    
	// Load schedule map with annotation and polygons
    func loadScheduleMap() {
        
        scheduleMapView.delegate = self
        
        let coordinates = self.schedule.polygonCoordinates
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        
        let annotation = MKPointAnnotation()
        annotation.title = "\(self.schedule.address)"
        annotation.subtitle = "Ward \(self.schedule.ward) - Section \(self.schedule.section)"
        annotation.coordinate = self.schedule.locationCoordinate
        
        let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
        let region = MKCoordinateRegion(center: self.schedule.locationCoordinate, span: span)
        
        scheduleMapView.setRegion(region, animated: true)
        scheduleMapView.removeOverlays(scheduleMapView.overlays)
        scheduleMapView.addOverlay(polygon)
        scheduleMapView.addAnnotation(annotation)
        
    }
    
	// Method required to add polygons to schedule map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolygon {
            
            if let pg = overlay as? MKPolygon {
                
                let pr = MKPolygonRenderer(polygon: pg)
                pr.fillColor = .red
                pr.alpha = 0.4
                return pr
            }
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
    
}
