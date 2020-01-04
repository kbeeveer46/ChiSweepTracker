import UIKit
import MapKit
import EventKit

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate {
   
    @IBOutlet weak var Calendar: UICollectionView!
    @IBOutlet weak var calendarMapView: MKMapView!

	let common = Common()
	var schedule = ScheduleModel()
	let toast = Toast()
	
	var currentYear = 0
    var selectedMonthNumber = 0
    var selectedMonthName = ""
    var selectedDates = ""
    
	// Used determine what month has been selected enable to calculate start day position
    var firstDayOfSweepingInMonth = 0
    var weekDayNumberOfFirstDayOfSweepingInMonth = 0
    
    var DaysInMonths = [31,28,31,30,31,30,31,31,30,31,30,31]
    var NumberOfEmptyBox = Int()
    var NextNumberOfEmptyBox = Int()
    var PreviousNumberOfEmptyBox = 0
    var Direction = 0
    var PositionIndex = 0
    var dayCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		currentYear = self.common.latestAppVersion() //self.common.constants.appVersion
        
		// Get selected month name from schedule view and set it as the title
        selectedMonthName = selectedMonthName.lowercased().capitalizingFirstLetter()
        self.title = "\(selectedMonthName) Schedule - \(currentYear)"
        
		// Get first day of sweeping month from string of days from the schedule view. Used to calculate start day position
        firstDayOfSweepingInMonth = Int(selectedDates.prefix(2).trimmingCharacters(in: .whitespaces))!
        
        // Create date for first day of sweeping. Used to calculate start day position
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = selectedMonthNumber
        dateComponents.day = firstDayOfSweepingInMonth
        let firstDateOfSweepingInMonth = Foundation.Calendar.current.date(from: dateComponents)
        
        weekDayNumberOfFirstDayOfSweepingInMonth = Foundation.Calendar.current.component(.weekday, from: firstDateOfSweepingInMonth!) - 1
        if weekDayNumberOfFirstDayOfSweepingInMonth == 0 {
            weekDayNumberOfFirstDayOfSweepingInMonth = 7
        }
        
        calculateStartDateDayPosition()
        
        loadCalendarMap()
    }
    
	// Load calendar map with annotation and polygons
    func loadCalendarMap() {
        
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
    
	// Required method to add polygons to calendar map
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
    
    // Calculates the number of "empty" boxes at the start of every month
    func calculateStartDateDayPosition() {
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
			return
            //fatalError()
        }
    }

	// Required method for calendar collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Direction{
        case 0:
            return DaysInMonths[selectedMonthNumber - 1] + NumberOfEmptyBox
        case 1...:
            return DaysInMonths[selectedMonthNumber - 1] + NextNumberOfEmptyBox
        case -1:
            return DaysInMonths[selectedMonthNumber - 1] + PreviousNumberOfEmptyBox
        default:
			return 0
            //fatalError()
        }
    }
    
	// If user clicks on a sweep date then prompt them to add an event to their calendar
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Add haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        
        let cell = collectionView.cellForItem(at: indexPath) as! DateCollectionViewCell
        let dateLabel = cell.viewWithTag(1) as! UILabel
        let date = dateLabel.text
        
		// Only allow user to create ane event on a sweep day
        if cell.Circle.isHidden == false {
        
			let alert = UIAlertController(title: "Add calendar event?", message: "An event will be added to the calendar on your device on \(self.selectedMonthNumber)/\(date!)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
                
                let eventStore = EKEventStore()

                eventStore.requestAccess(to: .event) { (granted, error) in

                    if (granted) && (error == nil) {
                        print("Event access granted: \(granted)")

                        let event:EKEvent = EKEvent(eventStore: eventStore)

						// Create begin and end dates (9am and 2pm)
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
                        endDateComponents.hour = 14 // 2 pm
                        endDateComponents.minute = 0
                        endDateComponents.day = Int(date!)
                        let endDate = Foundation.Calendar.current.date(from: endDateComponents)
                        
                        event.title = "Street Sweeping"
                        event.startDate = startDate
                        event.endDate = endDate
                        event.notes = "Street sweeping in your neighborhood between 9 am and 2 pm. Check for signage and move your vehicle to avoid tickets."
                        event.calendar = eventStore.defaultCalendarForNewEvents
                        
						do {
                            try eventStore.save(event, span: .thisEvent)
                        } catch let error as NSError {
							print("Failed to add event with error: \(error.localizedDescription)")
							self.common.showAlert(self.common.constants.errorTitle, "Unable to add event to calendar")
                        }
                        
                        DispatchQueue.main.async {
							self.common.showAlert(self.common.constants.successTitle, "Event named 'Street Sweeping' was added to your calendar")
							//self.toast.toast("Event was added to your calendar on \(self.selectedMonthNumber)/\(date!)")
                        }
                        
                        print("Added event")
                    }
                    else{
                        if error != nil {
                            print("Error adding event to calendar: \(error!)")
							self.common.showAlert(self.common.constants.errorTitle, "Unable to add event to your calendar")
                        }
                    }
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
	// Required method for calendar collection view to populate view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Calendar", for: indexPath) as! DateCollectionViewCell
        
        cell.backgroundColor = UIColor.clear
        cell.DateLabel.textColor = UIColor.black
        cell.Circle.isHidden = true

        if cell.isHidden {
            cell.isHidden = false
        }

		// The first cells that need to be hidden (if needed) will be negative or zero so we can hide them
        switch Direction {
        case 0:
            cell.DateLabel.text = "\(indexPath.row + 1 - NumberOfEmptyBox)"
        case 1:
            cell.DateLabel.text = "\(indexPath.row + 1 - NextNumberOfEmptyBox)"
        case -1:
            cell.DateLabel.text = "\(indexPath.row + 1 - PreviousNumberOfEmptyBox)"
        default:
			cell.DateLabel.text = ""
        }

		// Hide the negative numbers or zero
        if Int(cell.DateLabel.text!)! < 1 {
            cell.isHidden = true
        }

		// Set weekend days color to light gray
        switch indexPath.row {
        case 5,6,12,13,19,20,26,27,33,34:
            if Int(cell.DateLabel.text!)! > 0 {
                cell.DateLabel.textColor = UIColor.lightGray
            }
        default:
            break
        }
        
		// Add circles to dates that are being swept in the selected month
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

// Capitalize first lett of month name
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

