import UIKit
import CoreLocation
import MapKit

class ScheduleViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var scheduleMapView: MKMapView!
    @IBOutlet weak var scheduleTableView: UITableView!
    
    let constants = Constants()
    var schedule = Schedule()
    
//    class Months {
//
//        var monthName = ""
//        var days: [String] = []
//
//        init(monthName: String, days: [String]) {
//            self.monthName = monthName
//            self.days = days
//        }
//
//
//    }
    
    
    //var address = ""
    //var testMonths: [Months] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Address from segue \(schedule.address)")
        
//        let month1 = Months(monthName: "January", days: ["1", "2", "3"])
//        let month2 = Months(monthName: "February", days: ["5", "10", "15", "20", "25", "30" ])
//        testMonths.append(month1)
//        testMonths.append(month2)
        
        if #available(iOS 13.0, *) {
            let notificationButton = UIBarButtonItem(image: UIImage(systemName: "bell"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(loadNotificationView))
            self.navigationItem.rightBarButtonItem = notificationButton
        }
        

        
        //print("Address \(address)")
        
        //getSchedule(schedule.address)
        loadSchedule()
        
//        getSchedule(address) {
//            loadSchedule(schedule)
//        }
        
        self.scheduleTableView.dataSource = self
        self.scheduleTableView.delegate = self
        self.scheduleTableView.reloadData()

        
    }
    
    @objc func loadNotificationView() {
        
        self.performSegue(withIdentifier: "notificationsSegue", sender: self)
        
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

    
}
