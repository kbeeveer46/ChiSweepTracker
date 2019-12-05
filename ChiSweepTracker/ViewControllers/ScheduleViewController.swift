import UIKit
import CoreLocation
import MapKit

class ScheduleViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var scheduleMapView: MKMapView!
    @IBOutlet weak var scheduleTableView: UITableView!
    
    let constants = Constants()
    var schedule = Schedule()
    
    class Months {
        
        var monthName = ""
        var days: [String] = []
        
        init(monthName: String, days: [String]) {
            self.monthName = monthName
            self.days = days
        }

        
    }
    
    
    var address = ""
    var testMonths: [Months] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let month1 = Months(monthName: "January", days: ["1", "2", "3"])
        let month2 = Months(monthName: "February", days: ["5", "10", "15", "20", "25", "30" ])
        testMonths.append(month1)
        testMonths.append(month2)
        
        if #available(iOS 13.0, *) {
            let notificationButton = UIBarButtonItem(image: UIImage(systemName: "bell"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(loadNotificationView))
            self.navigationItem.rightBarButtonItem = notificationButton
        }
        

        
        print("Address \(address)")
        
       getSchedule(address)
        
//        getSchedule(address) {
//            loadSchedule(schedule)
//        }
        

        
    }
    
    @objc func loadNotificationView() {
        
        print("Go to notification view")
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule.months.count
        //return testMonths.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleTableCell", for: indexPath)
        
        let monthNameLabel = cell.viewWithTag(1) as! UILabel
        let daysLabel = cell.viewWithTag(2) as! UILabel
        
        
        var dates = ""
        for date in schedule.months[indexPath.row].dates  {
            
            dates = dates + String(date.date).padding(toLength: 5, withPad: " ", startingAt: 0)
            
        }
        
//        var dates = ""
//        for day in testMonths[indexPath.row].days {
//
//            dates = dates + day.padding(toLength: 5, withPad: " ", startingAt: 0)
//
//        }
//
        //monthNameLabel.text = testMonths[indexPath.row].monthName
        monthNameLabel.text = schedule.months[indexPath.row].name
        daysLabel.text = dates
        
        return cell
        
    }
    
    
    
    //func loadSchedule(_ schedule: Schedule) {
    func loadSchedule() {
        
        scheduleMapView.delegate = self
        
        let coordinates = self.schedule.polygonCoordinatesForMap
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

    //func getSchedule(_ address: String, _ finished: () -> Void) {
    func getSchedule(_ address: String) {
        
        self.schedule.months.removeAll()
        self.schedule.polygonCoordinatesForMap.removeAll()
        
        print("Address: \(address)")
        
        self.schedule.address = address
        
        // 1. Get coordinates
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            
            if error != nil {
                
                //self.showingError = true
                //self.errorMessage = (error! as NSError).userInfo.debugDescription
            }
            
            if placemarks != nil {
            
                let placemark = placemarks?.first
                
                var coordinates = CLLocationCoordinate2D()
                coordinates.latitude = placemark?.location?.coordinate.latitude ?? 0
                coordinates.longitude = placemark?.location?.coordinate.longitude ?? 0
                self.schedule.locationCoordinate = coordinates
                
                print("Latitude: \(self.schedule.locationCoordinate.latitude)")
                print("Longitude: \(self.schedule.locationCoordinate.longitude)")
                
                let wardClient = SODAClient(domain: self.constants.SODADomain, token: self.constants.SODAToken)
                
                // 2. Get ward and section JSON from City of Chicago
                
                //print("Ward query: intersects(the_geom,'POINT(\(self.longitude) \(self.latitude))')")
                
                let wardQuery = wardClient.query(dataset: self.constants.wardDataset)
                    .filter("intersects(\(self.constants.the_geom),'POINT(\(self.schedule.locationCoordinate.longitude) \(self.schedule.locationCoordinate.latitude))')")
                
                wardQuery.get { res in
                    switch res {
                    case .dataset (let data):
                        
                        if data.count > 0 {
                            
                            let ward = data[0]["ward"] as? String ?? ""
                            let section = data[0]["section"] as? String ?? ""
                            let the_geom = data[0][self.constants.the_geom] as? [String: Any] ?? [:]
                            let coordinatesWrapper = the_geom["coordinates"] as? NSMutableArray
                            let coordinatesArray = coordinatesWrapper?[0] as? [[NSMutableArray]]
                            
                            for(_, coordinate) in coordinatesArray!.enumerated() {
                                
                                for item in coordinate {
                                    
                                    var coordinate = CLLocationCoordinate2D()
                                    coordinate.longitude = item[0] as? Double ?? 0
                                    coordinate.latitude = item[1] as? Double ?? 0
                                    
                                    self.schedule.polygonCoordinatesForMap.append(coordinate)
                                    
                                }
                            }
                            
                            print("Ward: \(ward)")
                            print("Section: \(section)")
                            
                            self.schedule.ward = ward
                            
                            if section.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                
                                //self.multipleSections = true
                                return
                                
                            }
                            
                            self.schedule.section = section
                            
                            // 3. Get schedule JSON from City of Chicago
                            
                            let scheduleQuery = wardClient.query(dataset: self.constants.scheduleDataset)
                                .filter("ward = '\(ward)' \(section != "" ? "AND section = '\(section)'" : "") ")
                            
                            scheduleQuery.get { res in
                                switch res {
                                case .dataset (let data):
                                    
                                    if data.count > 0 {
                                        
                                        //self.schedules = data
                                        
                                        // 4. Populate schedule model to be used on schedule view
                                        
                                        for (_, item) in data.enumerated() {
                                            
                                            let monthName = item["month_name"] as? String ?? ""
                                            let monthNumber = item["month_number"] as? Int ?? 0
                                            let dates = item["dates"] as? String ?? ""
                                            let datesArray = dates.components(separatedBy: ",")
                                            
                                            print("Month name: \(monthName)")
                                            print("Dates: \(datesArray)")
                                            
                                            let month = Month()
                                            month.name = monthName
                                            month.number = monthNumber
                                            
                                            for day in datesArray {
                                                
                                                print("Date: \(day)")
                                                
                                                if !day.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                    
                                                    let date = Date()
                                                    date.date = Int(day) ?? 0
                                                    
                                                    if !month.dates.contains(where: { $0.date == Int(day) ?? 0}) {
                                                        month.dates.append(date)
                                                    }
                                                }
                                            }
                                            
                                            self.schedule.months.append(month)
                                            
                                        }
                                        
                                        //self.showingSchedule = true
                                        self.loadSchedule()
                                        
                                        self.scheduleTableView.dataSource = self
                                        self.scheduleTableView.delegate = self
                                        self.scheduleTableView.reloadData()
                                        
                                    }
                                case .error (let err):
                                    
                                    print((err as NSError).userInfo.debugDescription)
                                    
                                    //self.showingError = true
                                    //self.errorMessage = (err as NSError).userInfo.debugDescription
                                }
                            }
                        }
                        else {
                            //self.showingError = true
                            //self.errorMessage = "Could not find sweep area. Please try again."
                        }
                    case .error (let err):
                        
                        print((err as NSError).userInfo.debugDescription)
                        
                        //self.showingError = true
                        //self.errorMessage = (err as NSError).userInfo.debugDescription
                        
                    }
                }
            }
            else {
                //self.showingError = true
                //self.errorMessage = "Could not find sweep area. Please try again."
            }
        }
        
        //return schedule
        //finished()
        
    }

}
