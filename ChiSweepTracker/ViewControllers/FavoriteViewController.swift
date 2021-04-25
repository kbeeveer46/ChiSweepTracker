import UIKit
import UserNotifications
import CoreLocation
import MapKit
import THLabel
import OneSignal

class FavoriteViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, MKMapViewDelegate {
    
    // Controls
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    @IBOutlet weak var onPicker: UIPickerView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var favoriteMapView: MKMapView!
    @IBOutlet weak var favoriteMapHeighConstraint: NSLayoutConstraint!
    @IBOutlet weak var favoriteStackView: UIStackView!
    @IBOutlet weak var whenPickerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var whenPickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timePickerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var timePickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
    
    // Classes
    let common = Common()
    var schedule = ScheduleModel()
    
    // Shared
    let whenData = ["Day Of Sweep", "1 Day Prior", "2 Days Prior", "3 Days Prior", "4 Days Prior", "5 Days Prior", "6 Days Prior", "7 Days Prior"]
    var relocatedVehicleCount = 0
    var divvyStationCount = 0
    
    // MARK: Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fill in notification form values with user defaults
        self.loadNotificationControlValues()
        
        // Load map using user favorite lat, long, and polygon coordinates
        self.loadFavoriteMap()
        
        // Initialize controls per device
        self.initializeControlsPerDevice()
        
    }
    
    // Change constraints and sizes per device
    func initializeControlsPerDevice() {
        
        switch UIDevice().type {
        case .iPhoneSE:
            favoriteMapHeighConstraint.constant = 175
            cardViewRightConstraint.constant = 0
            cardViewLeftConstraint.constant = 0
            cardViewTopConstraint.constant = 0
            cardViewBottomConstraint.constant = 0
            whenPickerWidthConstraint.constant = 165
            timePickerWidthConstraint.constant = 165
            timePickerHeightConstraint.constant = 60
            whenPickerHeightConstraint.constant = 60
            favoriteStackView.spacing = 0
//        case .iPhoneSE2:
//            favoriteMapHeighConstraint.constant = 175
//        case .iPhone5,
//             .iPhone5S,
//             .iPhone5C,
//             .iPhone6,
//             .iPhone6S,
//             .iPhone7,
//             .iPhone8:
//            favoriteStackView.spacing = 7
//            favoriteMapHeighConstraint.constant = 175
        default:
            break
        }
    }
    
    // Go to schedule page when top left schedule button is clicked
    @objc func viewSchedule() {
        
        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
            destinationViewController.schedule = self.schedule
            self.navigationController?.pushViewController(destinationViewController, animated: true)
        }
    }
    
    func loadFavoriteMap() {
        
        // Set required properties for map
        self.favoriteMapView.delegate = self
        self.favoriteMapView.removeOverlays(favoriteMapView.overlays)
        self.favoriteMapView.removeAnnotations(favoriteMapView.annotations)
        
        let selectedAnnotationLongitude = self.common.selectedAnnotationLongitude()
        let selectedAnnotationLatitude = self.common.selectedAnnotationLatitude()
        var mapOverlayCoordinates = [CLLocationCoordinate2D]()
        
        for coordinate in self.schedule.polygonCoordinates {
            mapOverlayCoordinates.append(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
        
        // Create polygons
        let polygons = MKPolygon(coordinates: mapOverlayCoordinates, count: mapOverlayCoordinates.count)
        
        // Add polygons to map
        favoriteMapView.addOverlay(polygons)
        
        // Create location using lat and long
        let location =  CLLocation(latitude: self.schedule.locationCoordinate.latitude, longitude: self.schedule.locationCoordinate.longitude)
        let selectedAnnotationLocation = CLLocation(latitude: selectedAnnotationLatitude, longitude: selectedAnnotationLongitude)
        
        defaults.set(0, forKey: "selectedAnnotationLongitude")
        defaults.set(0, forKey: "selectedAnnotationLatitude")
        
        // Add Divvy stations to map
        addDivvyStationsToMap(location)
        
        // Add relocated vehicles to map
        addRelocationVehiclesToMap(location)
        
        // Create annotation using location coordinate
        let annotation = CustomAnnotation()
        annotation.customImageName = "pin-address"
        annotation.coordinate = location.coordinate
        annotation.title = self.schedule.address
        annotation.subtitle = "Ward: \(self.schedule.ward) - Section: \(self.schedule.section)"
        
        // Create map span
        let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
        
        // Create map region
        let region = MKCoordinateRegion(center: selectedAnnotationLocation.coordinate.latitude != 0 && selectedAnnotationLocation.coordinate.longitude != 0 ? selectedAnnotationLocation.coordinate : location.coordinate, span: span)
        
        // Set map region
        favoriteMapView.setRegion(region, animated: false)
        
        // Add annoation to map
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "address")
        self.favoriteMapView.addAnnotation(annotationView.annotation!)
        
    }
    
    func addRelocationVehiclesToMap(_ favoriteLocation: CLLocation) {
        
        // Get show relocated vehicle setting from defaults
        let showTowedVehicles = self.common.showTowedVehicles()
        
        self.relocatedVehicleCount = 0
        
        // Show relocated vehicles if user has that option turned on
        if (showTowedVehicles) {
            
            // Create SODA client
            let relocatedClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
            
            // Create SODA query
            let relocatedQuery = relocatedClient.query(dataset: self.common.relocatedDataset())
                .filter("\(self.common.relocatedFromLatitudeTitle()) IS NOT NULL AND \(self.common.relocatedFromLongitudeTitle()) IS NOT NULL")
                .limit(5000)
            
            relocatedQuery.get { res in
                switch res {
                case .dataset (let data):
                    
                    if data.count > 0 {
                        
                        // Loop through relocated vehicle data
                        for (_, item) in data.enumerated() {
                            
                            // Get values for each relocated vehicle
                            var relocatedDate = item[self.common.relocatedDateTitle()] as? String ?? ""
                            let make = item[self.common.relocatedMakeTitle()] as? String ?? ""
                            let color = item[self.common.relocatedColorTitle()] as? String ?? ""
                            let plate = item[self.common.relocatedPlateTitle()] as? String ?? ""
                            let state = item[self.common.relocatedStateTitle()] as? String ?? ""
                            let relocatedToAddressNumber = item[self.common.relocatedToAddressNumberTitle()] as? String ?? ""
                            let relocatedToDirection = item[self.common.relocatedToDirectionTitle()] as? String ?? ""
                            let relocatedToStreet = item[self.common.relocatedToStreetTitle()] as? String ?? ""
                            let relocatedReason = item[self.common.relocatedReasonTitle()] as? String ?? ""
                            let relocatedFromLatitude = item[self.common.relocatedFromLatitudeTitle()] as? String ?? ""
                            let relocatedFromLongitude = item[self.common.relocatedFromLongitudeTitle()] as? String ?? ""
                            let relocatedFromAddressNumber = item[self.common.relocatedFromAddressNumberTitle()] as? String ?? ""
                            let relocatedFromDirection = item[self.common.relocatedFromDirectionTitle()] as? String ?? ""
                            let relocatedFromStreet = item[self.common.relocatedFromStreetTitle()] as? String ?? ""
                            
                            if (relocatedFromLatitude != "" && relocatedFromLongitude != "") {
                                
                                let relocatedLocation: CLLocation = CLLocation(latitude: Double(relocatedFromLatitude)!, longitude: Double(relocatedFromLongitude)!)
                                
                                // Get distance from favorite address to relocated vehicle
                                let distance = relocatedLocation.distance(from: favoriteLocation)
                                
                                // Show relocated vehicle on map if distance is less than or equal to 200 meters
                                if (distance <= 200) {
                                    
                                    self.relocatedVehicleCount += 1
                                    
                                    relocatedDate = Date.getFormattedDate(relocatedDate, "yyyy-MM-dd'T'HH:mm:ss.SSS")
                                    
                                    // Create annotation for relocated location
                                    let relocatedAnnotation = CustomAnnotation()
                                    relocatedAnnotation.customImageName = "pin-relocated"
                                    relocatedAnnotation.coordinate = relocatedLocation.coordinate
                                    relocatedAnnotation.subtitle = "Click on magnifying glass for details"
                                    relocatedAnnotation.title = "Make: \(make) - Plate #: \(plate)"
                                    
                                    let relocatedVehicle = VehicleModel()
                                    relocatedVehicle.relocatedToAddress = "\(relocatedToAddressNumber) \(relocatedToDirection) \(relocatedToStreet)"
                                    relocatedVehicle.color = color
                                    relocatedVehicle.make = make
                                    relocatedVehicle.plate = plate
                                    relocatedVehicle.state = state
                                    relocatedVehicle.relocatedDate = relocatedDate
                                    relocatedVehicle.relocatedFromLatitude = relocatedFromLatitude
                                    relocatedVehicle.relocatedFromLongitude = relocatedFromLongitude
                                    relocatedVehicle.relocatedFromAddress = "\(relocatedFromAddressNumber) \(relocatedFromDirection) \(relocatedFromStreet)"
                                    relocatedVehicle.relocatedReason = relocatedReason
                                    relocatedAnnotation.relocatedVehicle = relocatedVehicle
                                    
                                    // Add annotation to map
                                    let relocatedAnnotationView = MKPinAnnotationView(annotation: relocatedAnnotation, reuseIdentifier: "relocated")
                                    self.favoriteMapView.addAnnotation(relocatedAnnotationView.annotation!)
                                    
                                }
                            }
                        }
                    }
                    else {
                        //self.common.showAlert("Search Completed", "No vehicles near your address have been relocated.\n\nHide relocated vehicles in the settings menu to stop seeing this message.")
                    }
                case .error (let err):
                    print((err as NSError).userInfo.debugDescription)
                }
            }
        }
    }
    
    func addDivvyStationsToMap(_ favoriteLocation: CLLocation) {
        
        // Get show Divvy station setting from defaults
        let showDivvyStations = self.common.showDivvyStations()
        
        self.divvyStationCount = 0
        
        // Show Divvy stations if user has that option turned on
        if (showDivvyStations) {
            
            // Create SODA client
            let divvyClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
            
            // Create SODA query
            let divvyQuery = divvyClient.query(dataset: self.common.divvyDataset())
            
            divvyQuery.get { res in
                switch res {
                case .dataset (let data):
                    
                    if data.count > 0 {
                        
                        // Loop through Divvy data
                        for (_, item) in data.enumerated() {
                            
                            // Get values for each Divvy station
                            let latitude = item[self.common.divvyLatitudeTitle()] as? String ?? ""
                            let longitude = item[self.common.divvyLongitudeTitle()] as? String ?? ""
                            let name = item[self.common.divvyStationNameTitle()] as? String ?? ""
                            let docksInService = item[self.common.divvyDocksInServiceTitle()] as? String ?? ""
                            let status = item[self.common.divvyStatusTitle()] as? String ?? ""
                            let id = item[self.common.divvyIdTitle()] as? String ?? ""
                            
                            if (latitude != "" && longitude != "") {
                                
                                // Create station location
                                let stationLocation: CLLocation = CLLocation(latitude: Double(latitude)!, longitude: Double(longitude)!)
                                
                                // Get distance from favorite address to station
                                let distance = stationLocation.distance(from: favoriteLocation)
                                
                                // Show station on map if distance is less than or equal to 300 meters
                                if (distance <= 300) {
                                    
                                    self.divvyStationCount += 1
                                    
                                    // Create annotation for divvy station
                                    let divvyAnnotation = CustomAnnotation()
                                    divvyAnnotation.customImageName = "pin-divvy"
                                    divvyAnnotation.coordinate = stationLocation.coordinate
                                    divvyAnnotation.title = name
                                    divvyAnnotation.subtitle = "Click on magnifying glass for details"
                                    
                                    let station = DivvyStationModel()
                                    station.id = id
                                    station.name = name
                                    station.latitude = latitude
                                    station.longitude = longitude
                                    station.docksInService = docksInService
                                    station.status = status
                                    divvyAnnotation.divvyStation = station
                                    
                                    // Add annotation to map
                                    let divvyAnnotationView = MKPinAnnotationView(annotation: divvyAnnotation, reuseIdentifier: "divvy")
                                    self.favoriteMapView.addAnnotation(divvyAnnotationView.annotation!)
                                    
                                }
                            }
                        }
                    }
                case .error (let err):
                    print((err as NSError).userInfo.debugDescription)
                }
            }
        }
    }
    
    @objc func openOptionsMenu() {
        
        // Add haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        
        // Get values from defaults
        let showDivvyStations = self.common.showDivvyStations()
        let showTowedVehicles = self.common.showTowedVehicles()
        
        // Create options alert
        let optionsAlert = UIAlertController(title: nil, message: "Options", preferredStyle: .actionSheet)
        
        // Create remove favorite option for options alert
        let removeFavoriteAction = UIAlertAction(title: "Remove Address", style: .default, handler:{ action in
            
            // Create remove favorite alert
            let removeFavoriteAlert = UIAlertController(title: "Are You Sure?", message: "You will no longer receive notifications for this address", preferredStyle: .alert)
            
            // Create yes option for remove favorite alert
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler:{ action in
                
                var favoriteAddresses = self.common.favoriteAddresses()
                
                for (index, element) in favoriteAddresses.enumerated() {
                    if element[0] == self.schedule.address {
                        favoriteAddresses[index][0] = ""
                        favoriteAddresses[index][1] = ""
                        favoriteAddresses[index][2] = ""
                        favoriteAddresses[index][3] = ""
                        favoriteAddresses[index][4] = ""
                        break
                    }
                }
                
                defaults.setValue(favoriteAddresses, forKey: "favoriteAddresses")
                
                // Clear favorite default values
                //defaults.set("", forKey: "favoriteAddress")
                defaults.set("", forKey: "favoriteWard")
                defaults.set("", forKey: "favoriteSection")
                defaults.set(0.0, forKey: "favoriteLongitude")
                defaults.set(0.0, forKey: "favoriteLatitude")
                defaults.set(nil, forKey: "favoriteCoordinatesArray")
                
                self.common.deleteNotificationsFromDatabase(self.schedule.address, self.common.constants.notificationsDatabaseName, completion: {completion in })
                
                // If on a view with a tab control then use it to go to the favorit list view
                self.tabBarController?.selectedIndex = 1
                
                // If not on a view with a tab control, use navigation controller to go to favorite list view
                if self.tabBarController == nil {
                    self.navigationController?.popViewController(animated: true)
                }
                
            })
            yesAction.setValue(UIColor.red, forKey: "titleTextColor")
            
            // Create and add no option for remove favorite alert
            removeFavoriteAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            // Add yes option to remove favorite alert
            removeFavoriteAlert.addAction(yesAction)
            
            // Present remove favorite alert
            self.present(removeFavoriteAlert, animated: true, completion: nil)
            
        })
        removeFavoriteAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        // Create view schedule options for alert
        let viewScheduleAction = UIAlertAction(title: "View Sweep Schedule", style: .default, handler:{ action in
            // Segue to schedule view
            if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
                destinationViewController.schedule = self.schedule
                self.navigationController?.pushViewController(destinationViewController, animated: true)
            }
        })
        let viewScheduleImage = UIImage(named: "list")
        if let icon = viewScheduleImage?.imageWithSize(scaledToSize: CGSize(width: 32, height: 32)) {
            viewScheduleAction.setValue(icon, forKey: "image")
        }
        optionsAlert.addAction(viewScheduleAction)
        
        // Create nearby Divvy stations options for alert
        if (showDivvyStations == false) {
            let showDivvyAction = UIAlertAction(title: "Show Nearby Divvy Stations", style: .default, handler:{ action in
                defaults.set(true, forKey: "showDivvyStations")
                self.loadFavoriteMap()
            })
            let showDivvyStationsImage = UIImage(named: "bike")
            if let icon = showDivvyStationsImage?.imageWithSize(scaledToSize: CGSize(width: 32, height: 32)) {
                showDivvyAction.setValue(icon, forKey: "image")
            }
            optionsAlert.addAction(showDivvyAction)
        }
        else {
            let hideDivvyAction = UIAlertAction(title: "Hide Nearby Divvy Stations (\(divvyStationCount))", style: .default, handler:{ action in
                defaults.set(false, forKey: "showDivvyStations")
                self.loadFavoriteMap()
            })
            let hideDivvyStationsImage = UIImage(named: "bike")
            if let icon = hideDivvyStationsImage?.imageWithSize(scaledToSize: CGSize(width: 32, height: 32)) {
                hideDivvyAction.setValue(icon, forKey: "image")
            }
            optionsAlert.addAction(hideDivvyAction)
        }
        
        // Create nearby towed/relocated vehicle options for alert
        if (showTowedVehicles == false) {
            let showRelocatedAction = UIAlertAction(title: "Show Nearby Relocated Vehicles", style: .default, handler:{ action in
                defaults.set(true, forKey: "showTowedVehicles")
                self.loadFavoriteMap()
            })
            let showRelocatedVehiclesImage = UIImage(named: "pin-address")
            if let icon = showRelocatedVehiclesImage?.imageWithSize(scaledToSize: CGSize(width: 32, height: 32)) {
                showRelocatedAction.setValue(icon, forKey: "image")
            }
            optionsAlert.addAction(showRelocatedAction)
        }
        else {
            let hideRelocatedAction = UIAlertAction(title: "Hide Relocated Vehicles (\(relocatedVehicleCount))", style: .default, handler:{ action in
                defaults.set(false, forKey: "showTowedVehicles")
                self.loadFavoriteMap()
            })
            let hideRelocatedVehiclesImage = UIImage(named: "pin-address")
            if let icon = hideRelocatedVehiclesImage?.imageWithSize(scaledToSize: CGSize(width: 32, height: 32)) {
                hideRelocatedAction.setValue(icon, forKey: "image")
            }
            optionsAlert.addAction(hideRelocatedAction)
        }
        
        let showTowedAction = UIAlertAction(title: "Search Towed Vehicles", style: .default, handler:{ action in
            // Segue to towed search view
            if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "TowedSearchViewController") as? TowedSearchViewController {
                self.navigationController?.pushViewController(destinationViewController, animated: true)
            }
        })
        let searchTowedVehiclesImage = UIImage(named: "search-fill")
        if let icon = searchTowedVehiclesImage?.imageWithSize(scaledToSize: CGSize(width: 32, height: 32)) {
            showTowedAction.setValue(icon, forKey: "image")
        }
        optionsAlert.addAction(showTowedAction)
        
        // Create cancel option for options alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Add options to options alert
        optionsAlert.addAction(cancelAction)
        
        let removeFavoriteImage = UIImage(named: "house_alt")
        if let icon = removeFavoriteImage?.imageWithSize(scaledToSize: CGSize(width: 32, height: 32)) {
            removeFavoriteAction.setValue(icon, forKey: "image")
        }
        optionsAlert.addAction(removeFavoriteAction)
        
        // Present options alert
        self.present(optionsAlert, animated: true, completion: nil)
        
    }
    
    @objc func timePickerChanged(picker: UIDatePicker) {
        
        // Save form values
        saveDefaultNotificationValues()
        
        // Update notifications when picker is changed
        if self.pushNotificationsSwitch.isOn {
            self.common.deleteNotificationsFromDatabase(self.schedule.address, self.common.constants.notificationsDatabaseName, completion: {completion in
                self.getSchedule(true)
            })
        }
    }
    
    func loadNotificationControlValues() {
        
        self.navigationItem.title = self.schedule.address
        
        // Set required properties for when picker
        self.onPicker.delegate = self
        self.onPicker.dataSource = self
        
        let favoriteAddresses = self.common.favoriteAddresses()
        let favoriteAddress = favoriteAddresses.filter { $0[0] == self.schedule.address }
        let notificationsToggled = Bool(favoriteAddress[0][1])
        
        var when = ""
        var whenIndex = 0
        var hour = ""
        var hourInt = 0
        var minute = ""
        var minuteInt = 0
        
        for (index, element) in favoriteAddresses.enumerated() {
            if element[0] == self.schedule.address {
                when = favoriteAddresses[index][2]
                whenIndex = whenData.firstIndex(of: when) ?? 0
                hour = favoriteAddresses[index][3]
                minute = favoriteAddresses[index][4]
                break
            }
        }
        
        if hour != "" {
            hourInt = Int(hour) ?? 0
        }
        
        if minute != "" {
            minuteInt = Int(minute) ?? 0
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        let date = dateFormatter.date(from: "\(hourInt):\(minuteInt)")
        
        self.onPicker.selectRow(whenIndex, inComponent: 0, animated: false)
        self.timePicker.date = date!
        
        timePicker.addTarget(self, action: #selector(timePickerChanged(picker:)), for: .valueChanged)
        
        // Get schedule so we have the most update to date version
        // Used to pass schedule model to schedule view
        // I don't think this is needed anymore after favorite list page was added
        self.getSchedule(false)
        
        self.pushNotificationsSwitch.isOn = notificationsToggled!
        self.pushNotificationsSwitch.isUserInteractionEnabled = true
        self.onPicker.isUserInteractionEnabled = notificationsToggled!
        self.timePicker.isUserInteractionEnabled = notificationsToggled!
        
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "more_vert"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(openOptionsMenu))
        
        if self.tabBarController == nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "more_vert"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(openOptionsMenu))
        }
    }
    
    // Save form values to defaults
    func saveDefaultNotificationValues() {
        
        var favoriteAddresses = self.common.favoriteAddresses()
        
        let time = self.timePicker.date
        let comp = Calendar.current.dateComponents([.hour, .minute], from: time)
        let hour = comp.hour!
        let minute = comp.minute!
        let when = self.whenData[self.onPicker.selectedRow(inComponent: 0)]
        
        for (index, element) in favoriteAddresses.enumerated() {
            if element[0] == self.schedule.address {
                favoriteAddresses[index][2] = String(when)
                favoriteAddresses[index][3] = String(hour)
                favoriteAddresses[index][4] = String(minute)
                break
            }
        }
        
        defaults.setValue(favoriteAddresses, forKey: "favoriteAddresses")
    }
    
    // Populate schedule model and add notifications if applicable
    // useDefaultNotificationValues is set to true when running getSchedule from outside notifications view controller
    func getSchedule(_ registerForPushNotifications: Bool,
                     _ useDefaultNotificationValues: Bool = false,
                     _ address: String = "",
                     _ when: String = "",
                     _ hour: Int = 0,
                     _ minute: Int = 0,
                     _ favoriteSection: String = "") {
        
        if (address != "") {
            self.schedule.address = address
        }
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(self.schedule.address) { placemarks, error in
            
            if error != nil {
                
                print("getSchedule geocode error: \((error! as NSError).userInfo.debugDescription)")
                
                // Remove schedule button in the top left if there's an error getting the coordinates
                // If there's an error getting the coornidates then the schedule won't be populated correctly
                self.navigationItem.leftBarButtonItem = nil
                
            }
            
            if placemarks != nil {
                
                let placemark = placemarks?.first
                
                var coordinates = CLLocationCoordinate2D()
                coordinates.latitude = placemark?.location?.coordinate.latitude ?? 0
                coordinates.longitude = placemark?.location?.coordinate.longitude ?? 0
                self.schedule.locationCoordinate = coordinates
                
                let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
                
                let wardQuery = wardClient.query(dataset: self.common.wardDataset())
                    .filter("intersects(\(self.common.geomTitle()),'POINT(\(self.schedule.locationCoordinate.longitude) \(self.schedule.locationCoordinate.latitude))')")
                    .limit(1)
                
                wardQuery.get { res in
                    switch res {
                    case .dataset (let data):
                        
                        if data.count > 0 {
                            
                            let ward = data[0][self.common.wardTitle()] as? String ?? ""
                            let section = data[0][self.common.sectionTitle()] as? String ?? ""
                            let the_geom = data[0][self.common.geomTitle()] as? [String: Any] ?? [:]
                            let coordinatesWrapper = the_geom[self.common.coordinatesTitle()] as? NSMutableArray
                            let coordinatesArray = coordinatesWrapper?[0] as? [[NSMutableArray]]
                            
                            self.schedule.polygonCoordinates.removeAll()
                            
                            for(_, coordinate) in coordinatesArray!.enumerated() {
                                
                                for item in coordinate {
                                    
                                    var coordinate = CLLocationCoordinate2D()
                                    coordinate.longitude = item[0] as? Double ?? 0
                                    coordinate.latitude = item[1] as? Double ?? 0
                                    
                                    self.schedule.polygonCoordinates.append(coordinate)
                                    
                                }
                            }
                            
                            self.schedule.ward = ward
                            self.schedule.section = String(section).trimmingCharacters(in: .whitespaces)
                            
                            if self.schedule.section.isEmpty {
                                //self.schedule.section = self.common.favoriteSection()
                                self.schedule.section = favoriteSection
                            }
                            
                            let scheduleQuery = wardClient.query(dataset: self.common.scheduleDataset())
                                .filter("\(self.common.wardTitle()) = '\(ward)' AND \(self.common.sectionTitle()) = '\(self.schedule.section)'")
                                .orderAscending(self.common.monthNumberTitle())
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        self.schedule.months.removeAll()
                                        
                                        for (_, item) in data.enumerated() {
                                            
                                            let monthName = item[self.common.monthNameTitle()] as? String ?? ""
                                            let monthNumber = item[self.common.monthNumberTitle()] as? String ?? ""
                                            let dates = item[self.common.dates()] as? String ?? ""
                                            let datesArray = dates.components(separatedBy: ",").sorted {$0.localizedStandardCompare($1) == .orderedAscending}
                                            
                                            let month = MonthModel()
                                            month.name = monthName
                                            month.number = monthNumber
                                            
                                            for day in datesArray {
                                                
                                                if !day.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                    
                                                    let date = DateModel()
                                                    date.date = Int(day) ?? 0
                                                    
                                                    if !month.dates.contains(where: { $0.date == Int(day) ?? 0}) {
                                                        month.dates.append(date)
                                                    }
                                                }
                                            }
                                            
                                            self.schedule.months.append(month)
                                            
                                        }
                                        
                                        if registerForPushNotifications == true {
                                            
                                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                                                granted, error in
                                                
                                                if granted == false {
                                                    
                                                    // User's notifications are disabled in settings. Prompt them to open settings
                                                    DispatchQueue.main.async {
                                                        
                                                        let alertController = UIAlertController (title: "Notifications Are Disabled", message: "Do you want to go to settings and turn notifications back on?", preferredStyle: .alert)
                                                        
                                                        let settingsAction = UIAlertAction(title: "Yes", style: .default) { (_) -> Void in
                                                            
                                                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                                                return
                                                            }
                                                            
                                                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                                                })
                                                            }
                                                        }
                                                        alertController.addAction(settingsAction)
                                                        
                                                        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler:{ action in
                                                            
                                                            self.pushNotificationsSwitch.isOn = false
                                                            self.timePicker.isUserInteractionEnabled = false
                                                            self.onPicker.isUserInteractionEnabled = false
                                                            
                                                        })
                                                        alertController.addAction(cancelAction)
                                                        
                                                        self.present(alertController, animated: true, completion: nil)
                                                    }
                                                }
                                                else {
                                                    
                                                    // Do not remove DispatchQueue
                                                    DispatchQueue.main.async {
                                                        
                                                        //let center = UNUserNotificationCenter.current()
                                                        let calendar = Calendar.current
                                                        let currentYear = self.common.latestAppVersion()
                                                        let notificationWhenDefault = when
                                                        let notificationHourDefault = hour
                                                        let notificationMinuteDefault = minute
                                                        var hour = 0
                                                        var minute = 0
                                                        var when = ""
                                                        
                                                        if useDefaultNotificationValues == true {
                                                            hour = notificationHourDefault
                                                            minute = notificationMinuteDefault
                                                            when = notificationWhenDefault
                                                        }
                                                        else {
                                                            let time = self.timePicker.date
                                                            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
                                                            hour = timeComponents.hour!
                                                            minute = timeComponents.minute!
                                                            when = self.whenData[self.onPicker.selectedRow(inComponent: 0)]
                                                        }
                                                        
                                                        for monthInSchedule in self.schedule.months {
                                                            
                                                            for dayInMonth in monthInSchedule.dates {
                                                                
                                                                let currentDate = Date()
                                                                let dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current, year: currentYear, month: Int(monthInSchedule.number), day: dayInMonth.date, hour: hour, minute: minute, second: 0)
                                                                var date = calendar.date(from: dateComponents)
                                                                
                                                                switch when {
                                                                case "1 Day Prior":
                                                                    date = calendar.date(byAdding: .day, value: -1, to: date!)
                                                                case "2 Days Prior":
                                                                    date = calendar.date(byAdding: .day, value: -2, to: date!)
                                                                case "3 Days Prior":
                                                                    date = calendar.date(byAdding: .day, value: -3, to: date!)
                                                                case "4 Days Prior":
                                                                    date = calendar.date(byAdding: .day, value: -4, to: date!)
                                                                case "5 Days Prior":
                                                                    date = calendar.date(byAdding: .day, value: -5, to: date!)
                                                                case "6 Days Prior":
                                                                    date = calendar.date(byAdding: .day, value: -6, to: date!)
                                                                case "7 Days Prior":
                                                                    date = calendar.date(byAdding: .day, value: -7, to: date!)
                                                                default:
                                                                    break
                                                                }
                                                                
                                                                if date! >= currentDate {
                                                                
                                                                    // Create notificaton trigger
    ///                                                               let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: date!)
    //                                                                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
    //
    //                                                                // Create notification contents
    //                                                                let content = UNMutableNotificationContent()
    //                                                                content.title = "Street Sweeping \(monthInSchedule.number)/\(dayInMonth.date)"
    //                                                                content.body = "Check your neighborhood for signage and move your vehicle to avoid tickets."
    //                                                                let soundName = UNNotificationSoundName("notification.m4r")
    //                                                                content.sound = UNNotificationSound(named: soundName)
    //                                                                content.badge = 1
    //                                                                content.userInfo = ["address":self.schedule.address]
    //
    //                                                                // Create notificaton identifier
    //                                                                let identifier = "LocalNotification-\(triggerComponents.month!)-\(triggerComponents.day!)-\(triggerComponents.hour!)-\(triggerComponents.minute!)-\(triggerComponents.second!)"
    //
    //                                                                // Create notification request
    //                                                                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    //
    //                                                                // Add notification
    //                                                                center.add(request, withCompletionHandler: { (error) in
    //                                                                    if let error = error {
    //                                                                        print("Error adding notification: \(error.localizedDescription)")
    //                                                                    }
    //                                                                    else {
    //                                                                        //print("Notification added: \(date!.description(with: Locale.current))")
    //                                                                    }
    //                                                                })
                                                                    
                                                                    // Add notification to database
                                                                    
                                                                    let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: date!)
                                                                    let sweepDay = "\(monthInSchedule.number)/\(dayInMonth.date)"
                                                                    let notificationTime = "\(String(format: "%02d", triggerComponents.month!))/\(String(format: "%02d", triggerComponents.day!))/\(triggerComponents.year!) \(String(format: "%02d", triggerComponents.hour!)):\(String(format: "%02d", triggerComponents.minute!)):\(String(format: "%02d", triggerComponents.second!))"
                                                                    
                                                                    self.insertNotificatinIntoDatabase(address: self.schedule.address, notificationTime: notificationTime, sweepDay: sweepDay, tableName: self.common.constants.notificationsDatabaseName)
                                                                    
                                                                }
                                                            }
                                                        }
                                                        
                                                        // Set the last year when notifications were updated.
                                                        // Use the value to alert them if they loaded the app after a new year came out
                                                        let notificationsYear = self.common.notificationsYear()
                                                        let latestAppVersion = self.common.latestAppVersion()
                                                        if notificationsYear < latestAppVersion {
                                                            self.common.showAlert("Notifications Updated", "Chicago has released the \(latestAppVersion) schedule and your push notifications have been automatically updated.")
                                                        }
                                                        defaults.set(latestAppVersion, forKey: "notificationsYear")
                                                        
                                                        // Set the latest dataset version when notifications were updated
                                                        // Use the value to alert them if they loaded the app after Chicago changed the schedule
                                                        let latestDatasetVersion = self.common.latestDatasetVersion()
                                                        let userDatasetVersion = self.common.userDatasetVersion()
                                                        if userDatasetVersion < latestDatasetVersion {
                                                            
                                                            defaults.set(latestDatasetVersion, forKey: "userDatasetVersion")
                                                            
                                                            // Create dataset updated alert
                                                            let datasetUpdatedAlert = UIAlertController(title: "Notifications Updated", message: "Chicago has changed the \(latestAppVersion) schedule and your push notifications have been automatically updated.", preferredStyle: .alert)
                                                            
                                                            // Create view schedule option for dataset updated alert
                                                            let viewScheduleAction = UIAlertAction(title: "View Schedule", style: .default, handler:{ action in
                                                                
                                                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                                                
                                                                if let destinationViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
                                                                    destinationViewController.schedule = self.schedule
                                                                    
                                                                    let navigationController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
                                                                    navigationController.pushViewController(destinationViewController, animated: true)
                                                                }
                                                            })
                                                            
                                                            // Create and add OK option for dataset updated alert
                                                            datasetUpdatedAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                                            
                                                            // Add view shedule option to dataset updated alert
                                                            datasetUpdatedAlert.addAction(viewScheduleAction)
                                                            
                                                            var rootViewController = UIApplication.shared.keyWindow?.rootViewController
                                                            
                                                            if let navigationController = rootViewController as? UINavigationController {
                                                                rootViewController = navigationController.viewControllers.first
                                                            }
                                                            
                                                            // Present dataset updated alert
                                                            rootViewController?.present(datasetUpdatedAlert, animated: true, completion: nil)
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                case .error (let err):
                                    print((err as NSError).userInfo.debugDescription)
                                    self.navigationItem.leftBarButtonItem = nil
                                }
                            }
                        }
                        else {
                            print(self.common.constants.notFound)
                            self.navigationItem.leftBarButtonItem = nil
                        }
                    case .error (let err):
                        print((err as NSError).userInfo.debugDescription)
                        self.navigationItem.leftBarButtonItem = nil
                    }
                }
            }
            else {
                print(self.common.constants.notFound)
                self.navigationItem.leftBarButtonItem = nil
            }
        }
    }
    
    func insertNotificatinIntoDatabase(address: String, notificationTime: String, sweepDay: String, tableName: String) {
        
        if self.common.notificationOneSignalPlayerId() != "" {
        
            let host = self.common.constants.websiteURL + "/insert-notification.php"
            let url = NSURL(string: host)
            var request = URLRequest(url: url! as URL)
            request.httpMethod = "POST"
                            
            var params = "playerId=\(self.common.notificationOneSignalPlayerId())"
            params += "&address=\(address)"
            params += "&notificationTime=\(notificationTime)"
            params += "&sweepDay=\(sweepDay)"
            params += "&tableName=\(tableName)"
                
            let data = params.data(using: .utf8)
            do
            {
                let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
                    
                    if error != nil {
                        print("Error adding notification to database")
                    }
                    else
                    {
                        //if let response = String(data: data!, encoding: .utf8) {
                        //    print("Response:\(response)")
                        //}
                    }
                }
                task.resume()
            }
        }
    }
    
    func sendTestNotifications() {
        
        // Get notification center
        let center = UNUserNotificationCenter.current()
        
        // Set notification date and time
        let calendar = Calendar.current
        let notificationDate = calendar.date(byAdding: .second, value: 15, to: Date())
        
        // Create notification trigger components
        let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: notificationDate!)
        
        // Create notification trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        // Get notification sound
        let soundName = UNNotificationSoundName("notification.m4r")
        
        // Create notification content
        let content = UNMutableNotificationContent()
        
        // Set notification properties
        content.title = "Street Sweeping 7/9 (Test)"
        content.body = "Check your neighborhood for signage and move your vehicle to avoid tickets."
        content.sound = UNNotificationSound(named: soundName)
        content.badge = 1
        content.userInfo = ["address":"750 N Dearborn St. Chicago, IL"]
        
        // Create notification id
        let identifier = "LocalNotification-\(triggerComponents.month!)-\(triggerComponents.day!)-\(triggerComponents.hour!)-\(triggerComponents.minute!)-\(triggerComponents.second!)"
        
        // Create notification request with id, content, and trigger
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Add notification request to notification center
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print("Unable to create test notification with error: \(error.localizedDescription)")
            }
            else {
                //print("Test notification added: \(identifier)")
            }
        })
    }
    
    // When and time picker methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return whenData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // Save default notification form values when picker is changed
        self.saveDefaultNotificationValues()
        
        // Update notifications after picker is changed
        if self.pushNotificationsSwitch.isOn {
            self.common.deleteNotificationsFromDatabase(self.schedule.address, self.common.constants.notificationsDatabaseName, completion: {completion in
                self.getSchedule(true)
            })
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return whenData[row]
    }
    
    // Required to load polygons on favorites map
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
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotationView.canShowCallout = true
        annotationView.annotation = annotation
        
        let customPointAnnotation = annotation as! CustomAnnotation
        annotationView.image = UIImage(named: customPointAnnotation.customImageName)
        annotationView.centerOffset = CGPoint(x: 0, y: -(annotationView.image!.size.height)/2)
        annotationView.subviews.forEach({ $0.removeFromSuperview() })
        annotationView.leftCalloutAccessoryView = nil
        
        if (customPointAnnotation.customImageName == "pin-address") {
            
            let annotationLabel = THLabel(frame: CGRect(x: -40, y: 50, width: 125, height: 30))
            annotationLabel.lineBreakMode = .byWordWrapping
            annotationLabel.textAlignment = .center
            annotationLabel.font = .boldSystemFont(ofSize: 11)
            annotationLabel.text = annotation.title!
            annotationLabel.strokeColor = UIColor.white
            annotationLabel.strokeSize = 1 //self.common.selectedAnnotationStrokeSize()
            annotationView.addSubview(annotationLabel)
            
        }
        else if (customPointAnnotation.customImageName == "pin-relocated" || customPointAnnotation.customImageName == "pin-divvy") {
            
            let detailsButton = UIButton()
            detailsButton.frame.size.width = 35
            detailsButton.frame.size.height = 35
            
            if (customPointAnnotation.customImageName == "pin-relocated") {
                detailsButton.setImage(UIImage(named: "search-orange"), for: .normal)
            }
            else {
                detailsButton.setImage(UIImage(named: "search-blue"), for: .normal)
            }
            
            annotationView.leftCalloutAccessoryView = detailsButton
            
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let annotation = view.annotation as? CustomAnnotation {
            
            defaults.set(annotation.coordinate.longitude, forKey: "selectedAnnotationLongitude")
            defaults.set(annotation.coordinate.latitude, forKey: "selectedAnnotationLatitude")
            
            if (annotation.customImageName == "pin-relocated") {
                
                // Segue to relocated detail view
                if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "RelocatedDetailViewController") as? RelocatedDetailViewController {
                    destinationViewController.relocatedVehicle = annotation.relocatedVehicle
                    self.navigationController?.pushViewController(destinationViewController, animated: true)
                }
                
            }
            else if (annotation.customImageName == "pin-divvy") {
                
                // Segue to divvy detail view
                if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "DivvyDetailViewController") as? DivvyDetailViewController {
                    destinationViewController.station = annotation.divvyStation
                    self.navigationController?.pushViewController(destinationViewController, animated: true)
                }
            }
        }
    }
    
    //MARK: Actions
    
    // Push notifications toggle switch event
    @IBAction func pushNotificationsTapped(_ sender: Any) {
        
        if pushNotificationsSwitch.isOn == true {
            
            let latestAppVersion = self.common.latestAppVersion()
            let latestDatasetVersion = self.common.latestDatasetVersion()
            
            // Save settings to defaults
            //defaults.set(true, forKey: "notificationsToggled")
            defaults.set(latestAppVersion, forKey: "notificationsYear")
            defaults.set(latestDatasetVersion, forKey: "userDatasetVersion")
            
            // Enable when and time controls
            self.timePicker.isUserInteractionEnabled = true
            self.onPicker.isUserInteractionEnabled = true
            
            // Save form values to defaults
            saveDefaultNotificationValues()
            
            var favoriteAddresses = self.common.favoriteAddresses()
            for (index, element) in favoriteAddresses.enumerated() {
                if element[0] == self.schedule.address {
                    favoriteAddresses[index][1] = "true"
                    break
                }
            }
            
            defaults.set(favoriteAddresses, forKey: "favoriteAddresses")
            
            self.common.deleteNotificationsFromDatabase(self.schedule.address, self.common.constants.notificationsDatabaseName, completion: {(completion)-> Void in
                // Get schedule and update user's local notifications
                self.getSchedule(true)
            })
            
        }
        else {
            
            var favoriteAddresses = self.common.favoriteAddresses()
            for (index, element) in favoriteAddresses.enumerated() {
                if element[0] == self.schedule.address {
                    favoriteAddresses[index][1] = "false"
                    break
                }
            }
            defaults.set(favoriteAddresses, forKey: "favoriteAddresses")
            
            // Disable when and time controls
            self.timePicker.isUserInteractionEnabled = false
            self.onPicker.isUserInteractionEnabled = false
            
            // Delete notifications in database for address that was disabled
            self.common.deleteNotificationsFromDatabase(self.schedule.address, self.common.constants.notificationsDatabaseName, completion: {completion in })
            
        }
    }
}
