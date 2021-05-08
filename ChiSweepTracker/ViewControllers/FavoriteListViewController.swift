import UIKit
import MapKit
import THLabel
import Alamofire

class FavoriteListViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate  {

    // Controls
    @IBOutlet weak var favoriteListMapView: MKMapView!
    @IBOutlet weak var favoriteListTableView: UITableView!
    @IBOutlet weak var favoriteListViewHeaderLabel: UILabel!
    
    // Classes
    let common = Common()
    var addresses = [AddressModel]()
    
    // Shared
    let generator = UISelectionFeedbackGenerator()
    var favoriteAddresses = [[String]]()
    var mapLocations = [CLLocationCoordinate2D]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set required properties for favorite list table view
        self.favoriteListTableView.dataSource = self
        self.favoriteListTableView.delegate = self
        
        // Get addresses from database and use the data in the map and table
        self.getAddresses(completion: { message in
            
            DispatchQueue.main.async {
                
                self.favoriteListTableView.reloadData()
                self.loadFavoriteMap()
                
            }
        })
    }
    
    func getAddresses(completion: @escaping (_ message: Bool) -> Void) {
        
        self.common.getAddresses(completion: { addresses in
            
            self.addresses = addresses
            let group = DispatchGroup()
            
            for address in self.addresses {
            
                group.enter()
                
                self.common.getNextSweepDay(address: address.address, completion: { date in
                    address.nextSweepDay = date
                    group.leave()
                })
            }
            
            group.notify(queue: .main) {
                completion(true)
            }
        })
    }
    
    // Load map with default lat, long, and polygon coordinates or load Chicago map
    func loadFavoriteMap() {
        
        // Set required properties for map
        self.favoriteListMapView.delegate = self
        self.favoriteListMapView.removeAnnotations(favoriteListMapView.annotations)
        
        if self.addresses.count > 0 {
            
            self.tabBarController?.navigationItem.title = "Saved Addresses"
            self.favoriteListViewHeaderLabel.text = "Click on address below to set up notifications.\nClick on magnifying glass to view schedule."
            
            let nextSweepDay = self.addresses.reduce(self.addresses[0], {
                $0.nextSweepDay!.timeIntervalSince1970 < $1.nextSweepDay!.timeIntervalSince1970 && $0.nextSweepDay != nil && $1.nextSweepDay != nil ? $0 : $1
            })

            self.mapLocations.removeAll()
        
            for (_, address) in self.addresses.enumerated() {
                                          
                // Get coordinates from address
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(address.address) { placemarks, error in
                    
                    // No internet connection will cause an error
                    if error != nil {
                        return
                    }
                    
                    if placemarks != nil {
                    
                        // Get first placemark in list
                        let placemark = placemarks?.first
                        
                        // Create coorindates from placemark
                        var coordinates = CLLocationCoordinate2D()
                        coordinates.latitude = placemark?.location?.coordinate.latitude ?? 0
                        coordinates.longitude = placemark?.location?.coordinate.longitude ?? 0
                        self.mapLocations.append(coordinates)
                        
                        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    
                        // Create annotation using location coordinate
                        let annotation = CustomAnnotation()
                        annotation.customImageName = "pin-address"
                        annotation.coordinate = location.coordinate
                        annotation.subtitle = address.address
                        
                        if address.nextSweepDay != nil {
                            let calenderDate = Calendar.current.dateComponents([.day, .year, .month], from: address.nextSweepDay!)
                            annotation.title = "Next Sweep: \(calenderDate.month!)/\(calenderDate.day!)/\(calenderDate.year!)"
                        }
                        
                        // Populate schedule based on address. This is so the user can click on the callout and go to schedule page
                        self.populateSchedule(address: address.address, goToFavoritePage: false, completion: { schedule in
                            annotation.schedule = schedule
                        })
                        
                        // Add annoation to map
                        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "address")
                        self.favoriteListMapView.addAnnotation(annotationView.annotation!)
                        
                        if self.addresses.count == 1 {

                            // Create map span
                            let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)

                            // Create map region
                            let region = MKCoordinateRegion(center: location.coordinate, span: span)

                            // Set map region
                            self.favoriteListMapView.setRegion(region, animated: false)

                        }
                        
                        // If the current address in the loop has a sweep day that matches the next sweep day then open the callout by default
                        if self.addresses.count > 1 {
                            if address.nextSweepDay == nextSweepDay.nextSweepDay {
                                self.favoriteListMapView.selectAnnotation(annotation, animated: true)
                            }
                        }
                        
                        // Set the visible area of the map based on where the annotations are located
                        if self.addresses.count != 1 && self.addresses.count == self.favoriteListMapView.annotations.count {
                            
                            
//                            var zoomRect            = MKMapRect.null
//                            for annotation in self.favoriteListMapView.annotations {
//                                let annotationPoint = MKMapPoint(annotation.coordinate)
//                                let pointRect       = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01);
//                                zoomRect            = zoomRect.union(pointRect);
//                            }
//                            self.favoriteListMapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
                            
                            let poly:MKPolygon = MKPolygon(coordinates: self.mapLocations, count: self.mapLocations.count)
                            self.favoriteListMapView.setVisibleMapRect(poly.boundingMapRect, edgePadding: UIEdgeInsets(top: 80, left: 80, bottom: 80, right: 80), animated: true)
                        }
                        // If there is only one address then open the callout by default
                        else if self.addresses.count == 1 {
                            self.favoriteListMapView.selectAnnotation(annotation, animated: true)
                        }
                    }
                }
            }
        }
        else {
            
            self.tabBarController?.navigationItem.title = "No Saved Addresses"
            self.favoriteListViewHeaderLabel.text = "Use search tab to find and save addresses"
            
            // Create map span using Chicago
            let span = MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45)
            
            // Create coordinates using Chicago
            let chicagoCoordinate = CLLocationCoordinate2D(latitude: 41.846647, longitude: -87.629576)
            
            // Create map region from span and coordinates
            let region = MKCoordinateRegion(center: chicagoCoordinate, span: span)
            
            // Set map region
            self.favoriteListMapView.setRegion(region, animated: false)
            
        }
    }
    
    func populateSchedule(address: String, goToFavoritePage: Bool, completion: @escaping (ScheduleModel) -> ()) {
        
        let schedule = ScheduleModel()

        schedule.address = address
        
        // Get coordinates from address
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            
            // No internet connection will cause an error
            if error != nil {
                return
            }
            
            if placemarks != nil {
            
                // Get first placemark in list
                let placemark = placemarks?.first
                
                // Create coorindates from placemark
                var coordinates = CLLocationCoordinate2D()
                coordinates.latitude = placemark?.location?.coordinate.latitude ?? 0
                coordinates.longitude = placemark?.location?.coordinate.longitude ?? 0
                
                // Set schedule location coordinates
                schedule.locationCoordinate = coordinates
                                
                // Create SODA client using domain and token
                let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
                
                // Query SODA API to get ward and section
                let wardQuery = wardClient.query(dataset: self.common.wardDataset())
                    .filter("intersects(\(self.common.geomTitle()),'POINT(\(schedule.locationCoordinate.longitude) \(schedule.locationCoordinate.latitude))')")
                    .limit(1)
                
                wardQuery.get { res in
                    switch res {
                    case .dataset (let data):
                        
                        if data.count > 0 {
                            
                            // Get values from json query
                            let ward = data[0][self.common.wardTitle()] as? String ?? ""
                            let section = data[0][self.common.sectionTitle()] as? String ?? ""
                            let the_geom = data[0][self.common.geomTitle()] as? [String: Any] ?? [:]
                            let coordinatesWrapper = the_geom[self.common.coordinatesTitle()] as? NSMutableArray
                            let coordinatesArray = coordinatesWrapper?[0] as? [[NSMutableArray]]
                            
                            // Loop through coordinates array
                            for(_, coordinate) in coordinatesArray!.enumerated() {
                                
                                // Loop through each pair of coordinates
                                for item in coordinate {
                                    
                                    // Create coorindate from lat and long in array
                                    var coordinate = CLLocationCoordinate2D()
                                    coordinate.longitude = item[0] as? Double ?? 0
                                    coordinate.latitude = item[1] as? Double ?? 0
                                    
                                    // Add coordinates to schedule polygon coordinates
                                    schedule.polygonCoordinates.append(coordinate)
                                 
                                }
                            }
                            
                            // Set schedule ward and section
                            schedule.ward = ward
                            schedule.section = String(section).trimmingCharacters(in: .whitespaces)
                            
                            // Query SODA API to get months and days
                            let scheduleQuery = wardClient.query(dataset: self.common.scheduleDataset())
                                .filter("\(self.common.wardTitle()) = '\(ward)' \(section != "" ? "AND \(self.common.sectionTitle()) = '\(section)'" : "") ")
                                .orderAscending(self.common.monthNumberTitle())
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        // Loop through months
                                        for (_, item) in data.enumerated() {
                                            
                                            // Get values from json data
                                            let monthName = item[self.common.monthNameTitle()] as? String ?? ""
                                            let monthNumber = item[self.common.monthNumberTitle()] as? String ?? ""
                                            let dates = item[self.common.dates()] as? String ?? ""
                                            let datesArray = dates.components(separatedBy: ",").sorted {$0.localizedStandardCompare($1) == .orderedAscending}
                                            
                                            // Create month object
                                            let month = MonthModel()
                                            month.name = monthName
                                            month.number = monthNumber
                                            
                                            // Loop through dates
                                            for day in datesArray {
                                                
                                                // Add date to month
                                                if !day.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                    
                                                    let date = DateModel()
                                                    date.date = Int(day) ?? 0
                                                    
                                                    if !month.dates.contains(where: { $0.date == Int(day) ?? 0}) {
                                                        month.dates.append(date)
                                                    }
                                                }
                                            }
                                            
                                            // Add month to schedule
                                            schedule.months.append(month)
                                            
                                        }
                                        
                                        // Segue to schedule view
                                        if goToFavoritePage {
                                            if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "FavoriteViewController") as? FavoriteViewController {
                                                destinationViewController.schedule = schedule
                                                self.navigationController?.pushViewController(destinationViewController, animated: true)
                                            }
                                        }
                                        else {
                                            completion(schedule)
                                        }
                                                            
                                    }
                                case .error (let err):
                                    print("searchForSchedule Unable to get schedule data from the City of Chicago: \(err.localizedDescription)")
                                }
                            }
                        }
                    case .error (let err):
                        print("searchForSchedule Unable to get ward data from the City of Chicago: \(err.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let annotation = view.annotation as? CustomAnnotation {
            
             // Segue to schedule view
            if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
                destinationViewController.schedule = annotation.schedule
                self.navigationController?.pushViewController(destinationViewController, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotationView.canShowCallout = true
        annotationView.annotation = annotation
        
        let customPointAnnotation = annotation as! CustomAnnotation
        annotationView.image = UIImage(named: customPointAnnotation.customImageName)
        annotationView.centerOffset = CGPoint(x: 0, y: -(annotationView.image!.size.height)/2)
        annotationView.subviews.forEach({ $0.removeFromSuperview() })
        
        let detailsButton = UIButton()
        detailsButton.frame.size.width = 35
        detailsButton.frame.size.height = 35
        detailsButton.setImage(UIImage(named: "search-red"), for: .normal)
        
        annotationView.leftCalloutAccessoryView = detailsButton
        
        return annotationView
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
                    
            let address = self.addresses[indexPath.row].address
            
            // Create remove favorite alert
            let removeFavoriteAlert = UIAlertController(title: "Are you sure?", message: "You will no longer receive notifications for this address", preferredStyle: .alert)
            
            // Create yes option for remove favorite alert
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler:{ action in
                
                self.common.deleteAddressFromDatabase(address: address, deleteAddressResult: { message in
                    
                    DispatchQueue.main.async {
                        self.favoriteListTableView.beginUpdates()
                        self.addresses.remove(at: indexPath.row)
                        self.favoriteListTableView.deleteRows(at: [indexPath], with: .automatic)
                        self.favoriteListTableView.endUpdates()
                        self.loadFavoriteMap()
                    }
                })
            })
            yesAction.setValue(UIColor.red, forKey: "titleTextColor")
            
            // Create and add no option for remove favorite alert
            removeFavoriteAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            // Add yes option to remove favorite alert
            removeFavoriteAlert.addAction(yesAction)
            
            // Present remove favorite alert
            self.present(removeFavoriteAlert, animated: true, completion: nil)
            
        }
    }
        
    // Table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.addresses.count
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Add haptic feedback
        generator.prepare()
        generator.selectionChanged()
                
        // Get cell from table view
        let cell = tableView.cellForRow(at: indexPath)!
        
        let addressLabel = cell.viewWithTag(1) as! UILabel
        let address = addressLabel.text!.trimmingCharacters(in: .whitespaces)
        
        self.populateSchedule(address: address, goToFavoritePage: true, completion: { completion in })
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get cell from table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteListTableCell", for: indexPath)
        
        // Get views from cell
        let addressLabel = cell.viewWithTag(1) as! UILabel
        let image = cell.viewWithTag(2) as! UIImageView
        
        let notificationsEnabled = addresses[indexPath.row].notificationsEnabled == "1" ? true : false
        if notificationsEnabled == false {
            image.isHidden = true
        }
        else {
            image.isHidden = false
        }

        // Set label text
        addressLabel.text = self.addresses[indexPath.row].address

        return cell
        
    }
}
