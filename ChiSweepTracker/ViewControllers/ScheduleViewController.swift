import UIKit
import CoreLocation
import MapKit
import CoreData

class ScheduleViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var scheduleMapView: MKMapView!
    @IBOutlet weak var scheduleTableView: UITableView!
    
    let generator = UISelectionFeedbackGenerator()
    
    var schedule = ScheduleModel()
    let defaults = UserDefaults.standard
    var addFavoriteButton = UIBarButtonItem()
    var removeFavoriteButton = UIBarButtonItem()
    var sentFromNotification = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set default address to be used when app is opened
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
        
        self.scheduleTableView.dataSource = self
        self.scheduleTableView.delegate = self
        self.scheduleTableView.allowsSelection = false
        self.scheduleTableView.reloadData()

    }
    
    // TODO: Use this to send user to schedule page when notification is opened
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }
    
//    @objc func catchIt() {
//
//        NotificationCenter.default.addObserver(self, selector: #selector(self.catchIt), name: NSNotification.Name(rawValue: "sentFromNotification"), object: nil)
//
//    }
    
    @objc func addFavorite() {
        
        generator.prepare()
        generator.selectionChanged()
        
        // Clear notifications created by previous favorite
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Set favorite address and section.
        // Section is used when creating location notifications that way we know the section in case there are multiple
        defaults.set(schedule.address, forKey: "favoriteAddress")
        defaults.set(schedule.ward, forKey: "favoriteWard")
        defaults.set(schedule.section, forKey: "favoriteSection")
        defaults.set(schedule.locationCoordinate.longitude, forKey: "favoriteLongitude")
        defaults.set(schedule.locationCoordinate.latitude, forKey: "favoriteLatitude")
        self.defaults.set(false, forKey: "notificationsToggled")
        
        let defaultCoordinates = defaults.object(forKey: "defaultCoordinatesArray") as? [[NSArray]] ?? nil
        defaults.set(defaultCoordinates, forKey: "favoriteCoordinatesArray")
        
        // Set right bar button to remove now that a favorite has been set
        self.navigationItem.rightBarButtonItem = removeFavoriteButton
        
        // Alert the user that their favorite has been set
        let alert = UIAlertController(title: "Favorite Saved", message: "Do you want to enable push notifications?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler:{ action in
    
            
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
            self.performSegue(withIdentifier: "viewNotificationsFromScheduleSegue", sender: self)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func removeFavorite() {
        
        generator.prepare()
        generator.selectionChanged()
        
        // Prompt the user  if they want to delete their favorite.
        let alert = UIAlertController(title: "Delete Favorite?", message: "You will no longer receive push notifications", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
            
            // Remove any notifications set for their previous favorite
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            // Clear favorite from defaults
            self.defaults.set("", forKey: "favoriteAddress")
            self.defaults.set("", forKey: "favoriteWard")
            self.defaults.set("", forKey: "favoriteSection")
            self.defaults.set(0.0, forKey: "favoriteLatitude")
            self.defaults.set(0.0, forKey: "favoriteLongitude")
            self.defaults.set(nil, forKey: "favoriteCoordinatesArray")
            
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
