import MapKit
import THLabel
import Alamofire
import IntentsUI

class FavoriteListViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate  {
    
    // MARK: Controls
    @IBOutlet weak var favoriteListMapView: MKMapView!
    @IBOutlet weak var favoriteListMapViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var favoriteListTableView: UITableView!
    @IBOutlet weak var favoriteListViewHeaderLabel: UILabel!
    @IBOutlet weak var siriView: UIView!
    
    // MARK: Classes
    let common = Common()
    let database = Database()
    var addresses = [AddressModel]()
    
    // MARK: Shared
    let generator = UISelectionFeedbackGenerator()
    var favoriteAddresses = [[String]]()
    var mapLocations = [CLLocationCoordinate2D]()
    let spinnerView = SpinnerViewController()
    
    // MARK: Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        self.initializeControlsPerDevice()
        
        // Set required properties for favorite list table view and map
        self.favoriteListTableView.dataSource = self
        self.favoriteListTableView.delegate = self
        self.favoriteListMapView.delegate = self
        
        self.getAddresses()
        
    }
    
    func getAddresses() {
        
        self.addSpinnerView()
        
        // Get addresses from database and use the data in the map and table
        self.database.getAddresses(completion: { addresses in
            
            self.addresses = addresses
            
            DispatchQueue.main.async {
                self.favoriteListTableView.reloadData()
                self.loadFavoriteListMap()
                self.removeSpinnerView()
            }
        })
        
    }
    
    func addSpinnerView() {
        
        // add the spinner view controller
        addChild(self.spinnerView)
        self.spinnerView.view.frame = view.frame
        view.addSubview(spinnerView.view)
        self.spinnerView.didMove(toParent: self)
        
    }
    
    func removeSpinnerView() {
        
        DispatchQueue.main.async() {
            // then remove the spinner view controller
            self.spinnerView.willMove(toParent: nil)
            self.spinnerView.view.removeFromSuperview()
            self.spinnerView.removeFromParent()
        }
        
    }
    
    // Change constraints and sizes per device
    func initializeControlsPerDevice() {
        
        switch UIDevice().type {
        case .iPhoneSE:
            favoriteListMapViewHeightConstraint.constant = 175
            favoriteListViewHeaderLabel.font = UIFont.systemFont(ofSize: 11)
        default:
            break
        }
    }
    
    func addSiriButton(to view: UIView) {
        
        siriView.isHidden = false
        
        let button = INUIAddVoiceShortcutButton(style: .whiteOutline)
        button.shortcut = INShortcut(intent: intent)
        button.delegate = self
        button.translatesAutoresizingMaskIntoConstraints = false
        view.subviews.forEach({ $0.removeFromSuperview() })
        view.addSubview(button)
        view.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
    }

    //
    func loadFavoriteListMap() {
        
        // Remove map annotions and clear map locations array
        self.favoriteListMapView.removeAnnotations(favoriteListMapView.annotations)
        self.mapLocations.removeAll()
        
        if self.addresses.count > 0 {
            
            addSiriButton(to: siriView)
            
            self.tabBarController?.navigationItem.title = "Saved Addresses"
            self.favoriteListViewHeaderLabel.text = "Click on address below to set up notifications.\nClick on magnifying glass in map to view schedule."
            
            let addressWithNextSweepDay = self.addresses.reduce(self.addresses[0], {
                $0.nextSweepDay!.timeIntervalSince1970 < $1.nextSweepDay!.timeIntervalSince1970 && $0.nextSweepDay != nil && $1.nextSweepDay != nil ? $0 : $1
            })

            for (_, address) in self.addresses.enumerated() {
                                          
                // Get coordinates from address
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(address.address) { placemarks, error in
                    
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
                        else {
                            annotation.title = "Next Sweep: No more sweeps at this address in \(self.common.defaults.latestAppVersion())"
                        }
                        
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
                            if address.nextSweepDay == addressWithNextSweepDay.nextSweepDay {
                                self.favoriteListMapView.selectAnnotation(annotation, animated: true)
                            }
                        }
                        // If there is only one address then open the callout by default
                        else if self.addresses.count == 1 {
                            self.favoriteListMapView.selectAnnotation(annotation, animated: true)
                        }
                        
                        // Set the visible area of the map based on where the annotations are located
                        if self.addresses.count > 1 && self.addresses.count == self.favoriteListMapView.annotations.count {
                            let poly:MKPolygon = MKPolygon(coordinates: self.mapLocations, count: self.mapLocations.count)
                            self.favoriteListMapView.setVisibleMapRect(poly.boundingMapRect, edgePadding: UIEdgeInsets(top: 80, left: 80, bottom: 80, right: 80), animated: true)
                        }
                    }
                }
            }
        }
        else {
            
            siriView.isHidden = true
            
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
                completion(schedule)
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
                let wardQuery = wardClient.query(dataset: self.common.defaults.wardDataset())
                    .filter("intersects(\(self.common.defaults.geomTitle()),'POINT(\(schedule.locationCoordinate.longitude) \(schedule.locationCoordinate.latitude))')")
                    .limit(1)
                
                wardQuery.get { res in
                    switch res {
                    case .dataset (let data):
                        
                        if data.count > 0 {
                            
                            // Get values from json query
                            let ward = data[0][self.common.defaults.wardTitle()] as? String ?? ""
                            let section = data[0][self.common.defaults.sectionTitle()] as? String ?? ""
                            let the_geom = data[0][self.common.defaults.geomTitle()] as? [String: Any] ?? [:]
                            let coordinatesWrapper = the_geom[self.common.defaults.coordinatesTitle()] as? NSMutableArray
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
                            let scheduleQuery = wardClient.query(dataset: self.common.defaults.scheduleDataset())
                                .filter("\(self.common.defaults.wardTitle()) = '\(ward)' \(section != "" ? "AND \(self.common.defaults.sectionTitle()) = '\(section)'" : "") ")
                                .orderAscending(self.common.defaults.monthNumberTitle())
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        // Loop through months
                                        for (_, item) in data.enumerated() {
                                            
                                            // Get values from json data
                                            let monthName = item[self.common.defaults.monthNameTitle()] as? String ?? ""
                                            let monthNumber = item[self.common.defaults.monthNumberTitle()] as? String ?? ""
                                            let dates = item[self.common.defaults.dates()] as? String ?? ""
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
                                        
                                        // Segue to favorite page
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
                                    completion(schedule)
                                }
                            }
                        }
                    case .error (let err):
                        print("searchForSchedule Unable to get ward data from the City of Chicago: \(err.localizedDescription)")
                        completion(schedule)
                    }
                }
            }
            else {
                completion(schedule)
            }
        }
    }
    
    //MARK: Map view methods
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let annotation = view.annotation as? CustomAnnotation {
            
            // Segue to schedule view
            if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
                
                self.populateSchedule(address: annotation.subtitle!, goToFavoritePage: false, completion: { schedule in
                    destinationViewController.schedule = schedule
                    self.navigationController?.pushViewController(destinationViewController, animated: true)
                })
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
    
    //MARK: Table view methods
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
                    
            let address = self.addresses[indexPath.row].address
            
            // Create remove favorite alert
            let removeFavoriteAlert = UIAlertController(title: "Are You Sure?", message: "You will no longer receive notifications for this address", preferredStyle: .alert)
            
            // Create yes option for remove favorite alert
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler:{ action in
                
                self.database.deleteAddressFromDatabase(address: address, deleteAddressResult: { message in
                    
                    DispatchQueue.main.async {
                        self.favoriteListTableView.beginUpdates()
                        self.addresses.remove(at: indexPath.row)
                        self.favoriteListTableView.deleteRows(at: [indexPath], with: .automatic)
                        self.favoriteListTableView.endUpdates()
                        self.loadFavoriteListMap()
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
        
        // Get address label and set label text
        let addressLabel = cell.viewWithTag(1) as! UILabel
        let address = addressLabel.text!.trimmingCharacters(in: .whitespaces)
        
        // Populate schedule and go to favorite page
        self.populateSchedule(address: address, goToFavoritePage: true, completion: { completion in })
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get cell from table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteListTableCell", for: indexPath)
        
        // Get views from cell
        let addressLabel = cell.viewWithTag(1) as! UILabel
        let image = cell.viewWithTag(2) as! UIImageView
        
        // Show or hide notifications image if notifications are enabled or not
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

extension FavoriteListViewController {
    public var intent: GetNextSweepDayIntent {
        let nextSweepDayIntent = GetNextSweepDayIntent()
        nextSweepDayIntent.suggestedInvocationPhrase = "Get Next Sweeping"
        return nextSweepDayIntent
    }
}

extension FavoriteListViewController: INUIAddVoiceShortcutButtonDelegate {
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        addVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(addVoiceShortcutViewController, animated: true, completion: nil)
    }
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        editVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }
}

extension FavoriteListViewController: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension FavoriteListViewController: INUIEditVoiceShortcutViewControllerDelegate {
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}


