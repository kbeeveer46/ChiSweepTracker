import UIKit
import CoreLocation
import MapKit
import CoreData

class ScheduleViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var scheduleMapView: MKMapView!
    @IBOutlet weak var scheduleTableView: UITableView!
    
    //@IBOutlet weak var addFavoriteButton: UIBarButtonItem!
    let constants = Constants()
    //var schedule = ScheduleModel(address: "", ward: "", section: "", months: [MonthModel](), locationCoordinate: CLLocationCoordinate2D(), polygonCoordinates: [CLLocationCoordinate2D]())
    var schedule = ScheduleModel()
    let defaults = UserDefaults.standard
    var addFavoriteButton = UIBarButtonItem()
    var removeFavoriteButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaults.set(schedule.address, forKey: "defaultAddress")
        let favoriteAddress = defaults.string(forKey: "favoriteAddress") ?? ""
        
        addFavoriteButton = UIBarButtonItem(image: UIImage(named: "star_border"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(addFavorite))
        
        removeFavoriteButton = UIBarButtonItem(image: UIImage(named: "star"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(removeFavorite))
        
        if favoriteAddress != schedule.address {
            self.navigationItem.rightBarButtonItem = addFavoriteButton
            
        }
        else {
            self.navigationItem.rightBarButtonItem = removeFavoriteButton
        }
        
        loadScheduleMap()
        
        self.scheduleTableView.dataSource = self
        self.scheduleTableView.delegate = self
        self.scheduleTableView.allowsSelection = false
        self.scheduleTableView.reloadData()

    }
    
    @objc func addFavorite() {
        
        defaults.set(schedule.address, forKey: "favoriteAddress")
        defaults.set(schedule.section, forKey: "favoriteSection")
        
        self.navigationItem.rightBarButtonItem = removeFavoriteButton
        
        let alert = UIAlertController(title: "Favorite saved", message: "Go to the favorite tab to set up push notifications", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        //UserDefaults.standard.set(try? PropertyListEncoder().encode(schedule), forKey:"favoriteSchedule")
        //let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: schedule)
        //defaults.set(encodedData, forKey: "favoriteSchedule")
        //defaults.synchronize()
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//
//        //We need to create a context from this container
//        let managedContext = appDelegate.persistentContainer.viewContext
//
//        //Prepare the request of type NSFetchRequest  for the entity
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
//
//        do {
//
//            let result = try managedContext.fetch(fetchRequest)
//
//            if result.count == 0 {
//
//                print("Address added to favorites: \(self.schedule.address)")
//
//                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//                let favorites = Favorites(context: context)
//                favorites.address = self.schedule.address
//
//                // Search for address and only add it if it doesn't exist
//
//                (UIApplication.shared.delegate as! AppDelegate).saveContext()
//            }
//
//        } catch {
//
//            print("Could not retrieve favorites from Core Data")
//        }
        
    }
    
    @objc func removeFavorite() {
        
        let alert = UIAlertController(title: "Delete favorite?", message: "You will no longer receive push notifications", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            self.defaults.set("", forKey: "favoriteAddress")
            self.navigationItem.rightBarButtonItem = self.addFavoriteButton
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
//    @objc func loadNotificationView() {
//
//        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsViewController") as? NotificationsViewController {
//
//            destinationViewController.schedule = self.schedule
//            self.navigationController?.pushViewController(destinationViewController, animated: true)
//
//        }
//
//        //self.performSegue(withIdentifier: "notificationsSegue", sender: self)
//    }
    
//    func addAddressToFavorites() {
//
//        //As we know that container is set up in the AppDelegates so we need to refer that container.
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//
//        //We need to create a context from this container
//        let managedContext = appDelegate.persistentContainer.viewContext
//
//        //Prepare the request of type NSFetchRequest  for the entity
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
//
//        fetchRequest.predicate = NSPredicate(format: "address = %@", schedule.address)
//
//        do {
//
//            let result = try managedContext.fetch(fetchRequest)
//
//            if result.count == 0 {
//
//                print("Address added to favorites: \(self.schedule.address)")
//
//                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//                let favorites = Favorites(context: context)
//                favorites.address = self.schedule.address
//
//                // Search for address and only add it if it doesn't exist
//
//                (UIApplication.shared.delegate as! AppDelegate).saveContext()
//            }
//
//        } catch {
//
//            print("Could not retrieve favorites from Core Data")
//        }
//
//    }
    
//    @IBAction func addFavoriteTapped(_ sender: Any) {
//
//        print("Add favorite tapped")
//
//        let alert = UIAlertController(title: "Add address to favorites?", message: "Address must be in your favorites to receive push notifications", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
//            self.addAddressToFavorites()
//        }))
//        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//
//        self.present(alert, animated: true)
//
//    }
//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule.months.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleTableCell", for: indexPath)

        let monthNameLabel = cell.viewWithTag(1) as! UILabel
        let daysLabel = cell.viewWithTag(2) as! UILabel

        var dates = ""
        for date in schedule.months[indexPath.row].dates  {

            dates = dates + String(date.date).padding(toLength: 5, withPad: " ", startingAt: 0)

        }

        monthNameLabel.text = schedule.months[indexPath.row].name
        daysLabel.text = dates

 //       let currentMonthNumber = Calendar.current.component(.month, from: Foundation.Date())

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
        
        scheduleMapView.setRegion(region, animated: false)
        scheduleMapView.removeOverlays(scheduleMapView.overlays)
        scheduleMapView.addOverlay(polygon)
        scheduleMapView.addAnnotation(annotation)
        
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let identifier = "Address"
//
//        //if annotation is MKAnnotation {
//            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
//                annotationView.annotation = annotation
//                return annotationView
//            } else {
//                let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:identifier)
//                //annotationView.isEnabled = true
//                annotationView.canShowCallout = true
//                annotationView.isSelected = true
//
//                //let label = UILabel()
//                //label.text = annotation.title!
//                //label.font.pointSize = 10
//
//                //let title = annotation.title
//
//                let btn = UIButton(type: .contactAdd)
//                btn.addTarget(self, action: #selector(saveAddressAsDefault), for: .touchUpInside)
//                annotationView.rightCalloutAccessoryView = btn
//                return annotationView
//            }
//        //}
//
//        //return nil
//    }
    
//    @objc func saveAddressAsDefault() {
//    
//        print("Button in pin tapped")
//        
//    }
    
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
