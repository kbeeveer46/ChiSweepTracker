import UIKit
import MapKit
import EventKit

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate {
   
    @IBOutlet weak var Calendar: UICollectionView!
    @IBOutlet weak var MonthLabel: UILabel!
    @IBOutlet weak var calendarMapView: MKMapView!

    var currentYear = Foundation.Calendar.current.component(.year, from: Foundation.Date())
    let common = Common()
    var schedule = ScheduleModel()
    var selectedMonthNumber = 0
    var selectedMonthName = ""
    var selectedDates = ""
    
    var firstDayOfSweepingInMonth = 0
    var weekDayNumberOfFirstDayOfSweepingInMonth = 0
    
    let DaysOfMonth = ["Monday","Thuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    var DaysInMonths = [31,28,31,30,31,30,31,31,30,31,30,31]

    var NumberOfEmptyBox = Int()
    var NextNumberOfEmptyBox = Int()
    var PreviousNumberOfEmptyBox = 0
    var Direction = 0
    var PositionIndex = 0
    var LeapYearCounter = 2
    var dayCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedMonthName = selectedMonthName.lowercased().capitalizingFirstLetter()
        self.title = "\(selectedMonthName) Schedule - \(currentYear)"
        
        firstDayOfSweepingInMonth = Int(selectedDates.prefix(2).trimmingCharacters(in: .whitespaces))!
        
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = selectedMonthNumber
        dateComponents.day = firstDayOfSweepingInMonth
        let firstDateOfSweepingInMonth = Foundation.Calendar.current.date(from: dateComponents)
        
        weekDayNumberOfFirstDayOfSweepingInMonth = Foundation.Calendar.current.component(.weekday, from: firstDateOfSweepingInMonth!) - 1
        if weekDayNumberOfFirstDayOfSweepingInMonth == 0 {
            weekDayNumberOfFirstDayOfSweepingInMonth = 7
        }
        
        getStartDateDayPosition()
        
        loadScheduleMap()
    }
    
    func loadScheduleMap() {
        
        calendarMapView.delegate = self
        
        let coordinates = self.schedule.polygonCoordinates
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        
        let annotation = MKPointAnnotation()
        annotation.title = "\(self.schedule.address)"
        annotation.subtitle = "Ward \(self.schedule.ward) - Section \(self.schedule.section)"
        annotation.coordinate = self.schedule.locationCoordinate
        
        let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
        let region = MKCoordinateRegion(center: self.schedule.locationCoordinate, span: span)
        
        calendarMapView.setRegion(region, animated: true)
        calendarMapView.removeOverlays(calendarMapView.overlays)
        calendarMapView.addOverlay(polygon)
        calendarMapView.addAnnotation(annotation)
        
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
    
    //Calculates the number of "empty" boxes at the start of every month
    
    func getStartDateDayPosition() {
        switch Direction{
        case 0:                                     
            NumberOfEmptyBox = weekDayNumberOfFirstDayOfSweepingInMonth
            dayCounter = firstDayOfSweepingInMonth
            while dayCounter>0 {
                NumberOfEmptyBox = NumberOfEmptyBox - 1
                dayCounter = dayCounter - 1
                if NumberOfEmptyBox == 0 {
                    NumberOfEmptyBox = 7
                }
            }
            if NumberOfEmptyBox == 7 {
                NumberOfEmptyBox = 0
            }
            PositionIndex = NumberOfEmptyBox
        case 1...:
            NextNumberOfEmptyBox = (PositionIndex + DaysInMonths[selectedMonthNumber])%7
            PositionIndex = NextNumberOfEmptyBox
            
        case -1:
            PreviousNumberOfEmptyBox = (7 - (DaysInMonths[selectedMonthNumber] - PositionIndex)%7)
            if PreviousNumberOfEmptyBox == 7 {
                PreviousNumberOfEmptyBox = 0
            }
            PositionIndex = PreviousNumberOfEmptyBox
        default:
            fatalError()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Direction{
        case 0:
            return DaysInMonths[selectedMonthNumber] + NumberOfEmptyBox
        case 1...:
            return DaysInMonths[selectedMonthNumber] + NextNumberOfEmptyBox
        case -1:
            return DaysInMonths[selectedMonthNumber] + PreviousNumberOfEmptyBox
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Add haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        
        let cell = collectionView.cellForItem(at: indexPath)
        let dateLabel = cell!.viewWithTag(1) as! UILabel
        let date = dateLabel.text
        
        let alert = UIAlertController(title: "Add Calendar Event?", message: "An event will be added to the calendar on your device", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
            
            let eventStore = EKEventStore()

            eventStore.requestAccess(to: .event) { (granted, error) in

                if (granted) && (error == nil) {
                    print("Event access granted: \(granted)")
                    //print("error \(error)")

                    let event:EKEvent = EKEvent(eventStore: eventStore)

                    var startDateComponents = DateComponents()
                    startDateComponents.year = self.currentYear
                    startDateComponents.month = self.selectedMonthNumber
                    startDateComponents.hour = 9
                    startDateComponents.minute = 0
                    startDateComponents.day = Int(date!)
                    let startDate = Foundation.Calendar.current.date(from: startDateComponents)
                    
                    var endDateComponents = DateComponents()
                    endDateComponents.year = self.currentYear
                    endDateComponents.month = self.selectedMonthNumber
                    endDateComponents.hour = 14
                    endDateComponents.minute = 0
                    endDateComponents.day = Int(date!)
                    let endDate = Foundation.Calendar.current.date(from: endDateComponents)
                    
                    event.title = "Street Sweeping"
                    event.startDate = startDate
                    event.endDate = endDate
                    event.notes = "City of Chicago street sweeping between 9 am and 2 pm."
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    do {
                        try eventStore.save(event, span: .thisEvent)
                    } catch let error as NSError {
                        print("failed to save event with error : \(error)")
                    }
                    
                    DispatchQueue.main.async {
                        self.common.showAlert("Event Added To Calendar", "")
                    }
                    
                    print("Saved Event")
                }
                else{
                    print("failed to save event with error : \(error!) or access not granted")
                }
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Calendar", for: indexPath) as! DateCollectionViewCell
        
        cell.backgroundColor = UIColor.clear
        cell.DateLabel.textColor = UIColor.black
        cell.Circle.isHidden = true

        if cell.isHidden{
            cell.isHidden = false
        }

        switch Direction {      //the first cells that needs to be hidden (if needed) will be negative or zero so we can hide them
        case 0:
            cell.DateLabel.text = "\(indexPath.row + 1 - NumberOfEmptyBox)"
        case 1:
            cell.DateLabel.text = "\(indexPath.row + 1 - NextNumberOfEmptyBox)"
        case -1:
            cell.DateLabel.text = "\(indexPath.row + 1 - PreviousNumberOfEmptyBox)"
        default:
            fatalError()
        }

        if Int(cell.DateLabel.text!)! < 1{ //here we hide the negative numbers or zero
            cell.isHidden = true
        }

        switch indexPath.row { //weekend days color
        case 5,6,12,13,19,20,26,27,33,34:
            if Int(cell.DateLabel.text!)! > 0 {
                cell.DateLabel.textColor = UIColor.lightGray
            }
        default:
            break
        }
        
        var datesArray = selectedDates.components(separatedBy: " ")
        datesArray = datesArray.filter {$0 != ""}
        
        for date in datesArray {
            if indexPath.row + 1 - NumberOfEmptyBox == Int(date) {
                cell.Circle.isHidden = false
                cell.DrawCircle()
            }
        }

        return cell
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

