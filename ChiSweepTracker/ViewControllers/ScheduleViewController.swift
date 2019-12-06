import UIKit
import CoreLocation
import MapKit

class ScheduleViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var scheduleMapView: MKMapView!
    @IBOutlet weak var scheduleTableView: UITableView!
    
    let constants = Constants()
    var schedule = Schedule()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationButton = UIBarButtonItem(image: UIImage(named: "settings"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(loadNotificationView))
        self.navigationItem.rightBarButtonItem = notificationButton
        
        loadSchedule()
        
        self.scheduleTableView.dataSource = self
        self.scheduleTableView.delegate = self
        self.scheduleTableView.allowsSelection = false
        self.scheduleTableView.reloadData()

    }
    
    @objc func loadNotificationView() {
        self.performSegue(withIdentifier: "notificationsSegue", sender: self)
    }
    
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

        let currentMonthNumber = Calendar.current.component(.month, from: Foundation.Date())

        if currentMonthNumber > schedule.months[indexPath.row].number {

            monthNameLabel.textColor = .lightGray
            daysLabel.textColor = .lightGray

        }

        return cell
        
    }
    
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

//class CustomCell: UITableViewCell {
//    var cellButton: UIButton!
//    //var cellLabel: UILabel!
//
//    init(frame: CGRect, title: String) {
//        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "customScheduleCell")
//
//        //cellLabel = UILabel(frame: CGRectMake(self.frame.width - 100, 10, 100.0, 40))
//        //cellLabel.textColor = UIColor.blackColor()
//        //cellLabel.font = //set font here
//
//        //cellButton = UIButton(frame: CGRectMake(5, 5, 50, 30))
//        cellButton.setTitle(title, for: UIControl.State.normal)
//
//        //addSubview(cellLabel)
//        addSubview(cellButton)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//}
