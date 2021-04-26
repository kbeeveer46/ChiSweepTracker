import UIKit
import MapKit
import THLabel

class FavoriteListViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var favoriteListMapView: MKMapView!
    @IBOutlet weak var favoriteListTableView: UITableView!
    @IBOutlet weak var favoriteListViewHeaderLabel: UILabel!
    
    let generator = UISelectionFeedbackGenerator()
    let common = Common()
    var addresses = [String]()
    var favoriteAddresses = [[String]]()
    var mapLocations = [CLLocationCoordinate2D]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set required properties for favorite list table view
        self.favoriteListTableView.dataSource = self
        self.favoriteListTableView.delegate = self
        
        getAddresses(completion: { message in
            
            DispatchQueue.main.async {
            
                if self.addresses.count == 0 {
                    self.tabBarController?.navigationItem.title = "No Saved Addresses"
                    self.favoriteListViewHeaderLabel.text = "Use search tab to find and save addresses"
                }
                else {
                    self.tabBarController?.navigationItem.title = "Saved Addresses"
                    self.favoriteListViewHeaderLabel.text = "Click on address to set up notifications"
                }
                
                self.favoriteListTableView.reloadData()
                self.loadFavoriteMap()
                
            }
        })
        
//        self.favoriteAddresses = self.common.favoriteAddresses().filter { $0[0] != "" }
//
//        if self.favoriteAddresses.filter({ $0[0] != "" }).count == 0 {
//            favoriteListViewHeaderLabel.text = "Use search tab to find and save addresses"
//        }
//        else {
//            favoriteListViewHeaderLabel.text = "Click on address to set up notifications"
//        }
    }
    
    func getAddresses(completion: @escaping (_ message: Bool) -> Void) {
        
        self.common.getRequest(self.common.constants.websiteURL + "/get-address-data.php", parameters: ["tableName": self.common.constants.addressesDatabaseName, "uuid": self.common.deviceUUID()]) { responseObject, error in
            guard let response = responseObject, error == nil else {
                print(error ?? "Unknown error")
                return
            }

            self.addresses.removeAll()
            
            if response.count > 0 {
                for item in response.enumerated() {
                    self.addresses.append(item.element["address"] as! String)
                }
            }
            completion(true)
        }
    }
    
    // Load map with default lat, long, and polygon coordinates or load Chicago map
    func loadFavoriteMap() {
        
        // Set required properties for map
        self.favoriteListMapView.delegate = self
        self.favoriteListMapView.removeAnnotations(favoriteListMapView.annotations)
        
        //let addresses = favoriteAddresses.filter { $0[0] != "" }
        
        if self.addresses.count > 0 {

            
            self.mapLocations.removeAll()
        
            for (_, address) in self.addresses.enumerated() {
                                          
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
                        self.mapLocations.append(coordinates)
                        
                        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    
                        // Create annotation using location coordinate
                        let annotation = CustomAnnotation()
                        annotation.customImageName = "pin-address"
                        annotation.coordinate = location.coordinate
                        annotation.title = address
                        
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
                        
                        if self.addresses.count != 1 && self.addresses.count == self.favoriteListMapView.annotations.count {
                            
                            let poly:MKPolygon = MKPolygon(coordinates: self.mapLocations, count: self.mapLocations.count)
                            self.favoriteListMapView.setVisibleMapRect(poly.boundingMapRect, edgePadding: UIEdgeInsets(top: 60.0, left: 60.0, bottom: 60.0, right: 60.0), animated: false)
                            
                        }
                    }
                }
            }
        }
        else {
            
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
    
    func searchForSchedule(_ address: String) {
        
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
                                        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "FavoriteViewController") as? FavoriteViewController {
                                            destinationViewController.schedule = schedule
                                            self.navigationController?.pushViewController(destinationViewController, animated: true)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotationView.canShowCallout = true
        annotationView.annotation = annotation
        
        let customPointAnnotation = annotation as! CustomAnnotation
        annotationView.image = UIImage(named: customPointAnnotation.customImageName)
        annotationView.centerOffset = CGPoint(x: 0, y: -(annotationView.image!.size.height)/2)
        annotationView.subviews.forEach({ $0.removeFromSuperview() })
        annotationView.leftCalloutAccessoryView = nil
        
        return annotationView
    }
        
    // Months/Days table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return favoriteAddresses.filter { $0[0] != "" }.count
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
        
        self.searchForSchedule(address)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get cell from table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteListTableCell", for: indexPath)
        
        // Get labels from cell
        let addressLabel = cell.viewWithTag(1) as! UILabel

        // Set label text
        addressLabel.text = self.addresses[indexPath.row]
        //addressLabel.text = self.favoriteAddresses[indexPath.row][0]

        return cell
        
    }

}
