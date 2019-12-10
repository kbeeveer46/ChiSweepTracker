import UIKit
import CoreData
import CoreLocation

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var favoritesTableView: UITableView!
    
    //var schedule = ScheduleModel(address: "", ward: "", section: "", months: [MonthModel](), locationCoordinate: CLLocationCoordinate2D(), polygonCoordinates: [CLLocationCoordinate2D]())
    var schedule = ScheduleModel()
    var schedules = [ScheduleModel]()
    let common = Common()
    //let constants = Constants()
    let defaults = UserDefaults.standard
    var favorites = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.favoritesTableView.delegate = self
        self.favoritesTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let notificationButton = UIBarButtonItem(image: UIImage(named: "bell_circle"),
                                                 landscapeImagePhone: nil, style: .plain,
                                                 target: self, action: #selector(loadNotificationView))
        
        self.tabBarController?.navigationItem.rightBarButtonItem = notificationButton
        self.tabBarController?.navigationItem.title = "Favorites"
        
       // getFavorites()
        
        self.favoritesTableView.delegate = self
        self.favoritesTableView.dataSource = self
        
        self.favoritesTableView.reloadData()
    }
    
//    func getFavorites() {
//
//        favorites.removeAll()
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
//        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "address", ascending: true)]
//        //fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur")
//
//        do {
//
//            let result = try managedContext.fetch(fetchRequest)
//
//            for data in result as! [NSManagedObject] {
//
//                print("Favorite: \(data.value(forKey: "address") as! String)")
//                favorites.append(data.value(forKey: "address") as! String)
//
//            }
//
//        } catch {
//
//            print("Could not retrieve favorites from Core Data")
//        }
//    }
    
    @objc func loadNotificationView() {
        
        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsViewController") as? NotificationsViewController {
            
            getSchedules(favorites)
            
            destinationViewController.schedule = self.schedule
            self.navigationController?.pushViewController(destinationViewController, animated: true)
            
        }
        
        //self.performSegue(withIdentifier: "notificationsSegue", sender: self)
    }
    
//    @objc func removeFavorite(sender: UIButton) {
//        
//        let buttonTag = sender.tag
//        let address = favorites[buttonTag]
//        
//        let alert = UIAlertController(title: "Delete favorite?", message: "", preferredStyle: .alert)
//        
//        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
//            
//            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//            
//            //We need to create a context from this container
//            let managedContext = appDelegate.persistentContainer.viewContext
//            
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
//            fetchRequest.predicate = NSPredicate(format: "address = %@", address)
//            
//            do
//            {
//                let test = try managedContext.fetch(fetchRequest)
//                
//                let objectToDelete = test[0] as! NSManagedObject
//                managedContext.delete(objectToDelete)
//                
//                do{
//                    try managedContext.save()
//                    
//                    self.favorites.remove(at: buttonTag)
//                    
//                    print("Favorite removed: \(address)")
//                    
//                    self.favoritesTableView.reloadData()
//                }
//                catch
//                {
//                    print(error)
//                }
//                
//            }
//            catch
//            {
//                print(error)
//            }
//            
//        }))
//        
//        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//        
//        self.present(alert, animated: true, completion: nil)
//        
//    }
    
    func getSchedules(_ addresses: [String]) {
        
        addresses.forEach { address in
            
            //let scheduleForNotifications = ScheduleModel(address: "", ward: "", section: "", months: [MonthModel](), locationCoordinate: CLLocationCoordinate2D(), polygonCoordinates: [CLLocationCoordinate2D]())
            let scheduleForNotifications = ScheduleModel()
            
            scheduleForNotifications.address = address
            
            // Get coordinates
            
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(address) { placemarks, error in
                
                if error != nil {
                    
                    self.common.showAlert(self.common.constants.errorTitle, (error! as NSError).userInfo.debugDescription)
                }
                
                if placemarks != nil {
                    
                    let placemark = placemarks?.first
                    
                    var coordinates = CLLocationCoordinate2D()
                    coordinates.latitude = placemark?.location?.coordinate.latitude ?? 0
                    coordinates.longitude = placemark?.location?.coordinate.longitude ?? 0
                    scheduleForNotifications.locationCoordinate = coordinates
                    
                    let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
                    
                    // Get ward and section JSON from City of Chicago
                    
                    let wardQuery = wardClient.query(dataset: self.common.constants.wardDataset)
                        .filter("intersects(\(self.common.constants.the_geom),'POINT(\(scheduleForNotifications.locationCoordinate.longitude) \(scheduleForNotifications.locationCoordinate.latitude))')")
                    
                    wardQuery.get { res in
                        switch res {
                        case .dataset (let data):
                            
                            if data.count > 0 {
                                
                                let ward = data[0][self.common.constants.ward] as? String ?? ""
                                let section = data[0][self.common.constants.section] as? String ?? ""
                                let the_geom = data[0][self.common.constants.the_geom] as? [String: Any] ?? [:]
                                let coordinatesWrapper = the_geom[self.common.constants.coordinates] as? NSMutableArray
                                let coordinatesArray = coordinatesWrapper?[0] as? [[NSMutableArray]]
                                
                                for(_, coordinate) in coordinatesArray!.enumerated() {
                                    
                                    for item in coordinate {
                                        
                                        var coordinate = CLLocationCoordinate2D()
                                        coordinate.longitude = item[0] as? Double ?? 0
                                        coordinate.latitude = item[1] as? Double ?? 0
                                        
                                        scheduleForNotifications.polygonCoordinates.append(coordinate)
                                        
                                    }
                                }
                                
                                scheduleForNotifications.ward = ward
                                scheduleForNotifications.section = String(section).trimmingCharacters(in: .whitespaces)
                                
                                if self.schedule.section.isEmpty {
                                    
                                    //self.performSegue(withIdentifier: "selectSectionSegue", sender: self)
                                    break
                                    
                                    // TODO!! How to handle missing section
                                }
                                
                                // Get schedule JSON from City of Chicago
                                
                                let scheduleQuery = wardClient.query(dataset: self.common.constants.scheduleDataset)
                                    .filter("ward = '\(ward)' \(section != "" ? "AND section = '\(section)'" : "") ")
                                
                                scheduleQuery.get { res in
                                    switch res {
                                    case .dataset (let data):
                                        
                                        if data.count > 0 {
                                            
                                            // Populate schedule model to be used on schedule view
                                            
                                            for (_, item) in data.enumerated() {
                                                
                                                let monthName = item[self.common.constants.month_name] as? String ?? ""
                                                let monthNumber = item[self.common.constants.month_number] as? String ?? ""
                                                let dates = item[self.common.constants.dates] as? String ?? ""
                                                let datesArray = dates.components(separatedBy: ",")
                                                
                                                //let month = MonthModel(name: "", number: "", dates: [DateModel]())
                                                let month = MonthModel()
                                                month.name = monthName
                                                month.number = monthNumber
                                                
                                                for day in datesArray {
                                                    
                                                    print("Date: \(day)")
                                                    
                                                    if !day.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                        
                                                        //let date = DateModel(date: 0)
                                                        let date = DateModel()
                                                        date.date = Int(day) ?? 0
                                                        
                                                        if !month.dates.contains(where: { $0.date == Int(day) ?? 0}) {
                                                            month.dates.append(date)
                                                        }
                                                    }
                                                }
                                                
                                                scheduleForNotifications.months.append(month)
                                                
                                            }
                                            
                                            self.schedules.append(scheduleForNotifications)
                                            
                                        }
                                    case .error (let err):
                                        
                                        self.common.showAlert(self.common.constants.errorTitle, (err as NSError).userInfo.debugDescription)
                                        
                                    }
                                }
                            }
                            else {
                                
                                self.common.showAlert(self.common.constants.errorTitle, self.common.constants.notFound)
                                
                            }
                        case .error (let err):
                            
                            self.common.showAlert(self.common.constants.errorTitle, (err as NSError).userInfo.debugDescription)
                            
                        }
                    }
                }
                else {
                    
                    self.common.showAlert(self.common.constants.errorTitle, self.common.constants.notFound)
                }
            }
            
        }
        
    }
    
    func showSchedule(_ address: String) {
        
        self.schedule.months.removeAll()
        self.schedule.polygonCoordinates.removeAll()
        
        print("Address: \(address)")
        
        self.schedule.address = address
        
        // Get coordinates
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            
            if error != nil {
                
                self.common.showAlert(self.common.constants.errorTitle, (error! as NSError).userInfo.debugDescription)
            }
            
            if placemarks != nil {
                
                let placemark = placemarks?.first
                
                var coordinates = CLLocationCoordinate2D()
                coordinates.latitude = placemark?.location?.coordinate.latitude ?? 0
                coordinates.longitude = placemark?.location?.coordinate.longitude ?? 0
                self.schedule.locationCoordinate = coordinates
                
                self.defaults.set(placemark?.location?.coordinate.latitude, forKey: "defaultLatitude")
                self.defaults.set(placemark?.location?.coordinate.longitude, forKey: "defaultLongitude")
                
                print("Latitude: \(self.schedule.locationCoordinate.latitude)")
                print("Longitude: \(self.schedule.locationCoordinate.longitude)")
                
                let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
                
                // Get ward and section JSON from City of Chicago
                
                let wardQuery = wardClient.query(dataset: self.common.constants.wardDataset)
                    .filter("intersects(\(self.common.constants.the_geom),'POINT(\(self.schedule.locationCoordinate.longitude) \(self.schedule.locationCoordinate.latitude))')")
                
                wardQuery.get { res in
                    switch res {
                    case .dataset (let data):
                        
                        if data.count > 0 {
                            
                            let ward = data[0][self.common.constants.ward] as? String ?? ""
                            let section = data[0][self.common.constants.section] as? String ?? ""
                            let the_geom = data[0][self.common.constants.the_geom] as? [String: Any] ?? [:]
                            let coordinatesWrapper = the_geom[self.common.constants.coordinates] as? NSMutableArray
                            let coordinatesArray = coordinatesWrapper?[0] as? [[NSMutableArray]]
                            
                            for(_, coordinate) in coordinatesArray!.enumerated() {
                                
                                for item in coordinate {
                                    
                                    var coordinate = CLLocationCoordinate2D()
                                    coordinate.longitude = item[0] as? Double ?? 0
                                    coordinate.latitude = item[1] as? Double ?? 0
                                    
                                    self.schedule.polygonCoordinates.append(coordinate)
                                    
                                }
                            }
                            
                            print("Ward: \(ward)")
                            print("Section: \(section)")
                            
                            self.schedule.ward = ward
                            self.schedule.section = String(section).trimmingCharacters(in: .whitespaces)
                            
                            if self.schedule.section.isEmpty {
                                
                                self.performSegue(withIdentifier: "selectSectionSegue", sender: self)
                                return
                            }
                            
                            // Get schedule JSON from City of Chicago
                            
                            let scheduleQuery = wardClient.query(dataset: self.common.constants.scheduleDataset)
                                .filter("ward = '\(ward)' \(section != "" ? "AND section = '\(section)'" : "") ")
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        // Populate schedule model to be used on schedule view
                                        
                                        for (_, item) in data.enumerated() {
                                            
                                            let monthName = item[self.common.constants.month_name] as? String ?? ""
                                            let monthNumber = item[self.common.constants.month_number] as? String ?? ""
                                            let dates = item[self.common.constants.dates] as? String ?? ""
                                            let datesArray = dates.components(separatedBy: ",")
                                            
                                            print("Month name: \(monthName)")
                                            print("Dates: \(datesArray)")
                                            
                                            //let month = MonthModel(name: "", number: "", dates: [DateModel]())
                                            let month = MonthModel()
                                            month.name = monthName
                                            month.number = monthNumber
                                            
                                            for day in datesArray {
                                                
                                                print("Date: \(day)")
                                                
                                                if !day.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                    
                                                    //let date = DateModel(date: 0)
                                                    let date = DateModel()
                                                    date.date = Int(day) ?? 0
                                                    
                                                    if !month.dates.contains(where: { $0.date == Int(day) ?? 0}) {
                                                        month.dates.append(date)
                                                    }
                                                }
                                            }
                                            
                                            self.schedule.months.append(month)
                                            
                                        }
                                        
                                        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
                                            destinationViewController.schedule = self.schedule
                                            self.navigationController?.pushViewController(destinationViewController, animated: true)
                                        }
                                        
                                    }
                                case .error (let err):
                                    
                                    self.common.showAlert(self.common.constants.errorTitle, (err as NSError).userInfo.debugDescription)
                                    
                                }
                            }
                        }
                        else {
                            
                            self.common.showAlert(self.common.constants.errorTitle, self.common.constants.notFound)
                            
                        }
                    case .error (let err):
                        
                        self.common.showAlert(self.common.constants.errorTitle, (err as NSError).userInfo.debugDescription)
                        
                    }
                }
            }
            else {
                
                self.common.showAlert(self.common.constants.errorTitle, self.common.constants.notFound)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritesTableViewCell", for: indexPath)
        
        let label = cell.viewWithTag(1) as! UILabel
        
        //let star = cell.viewWithTag(2) as! UIButton
        
        if let star = cell.contentView.viewWithTag(2) as? UIButton {
            //star.addTarget(self, action: #selector(removeFavorite(sender:)), for: .touchUpInside)
            star.tag = indexPath.row
        }
        
        label.text = favorites[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let address = favorites[indexPath.row]
        
        print("Selected favorite: \(address)")
        
        showSchedule(address)
        
    }
    
    // Prepare segue and pass data to view controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let scheduleViewController = segue.destination as? ScheduleViewController {
            scheduleViewController.schedule = schedule
        }
    }
}
