import UIKit
import MapKit
import EventKit
import THLabel

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate {
   
	//MARK: Controls
    @IBOutlet weak var Calendar: UICollectionView!
    @IBOutlet weak var calendarMapView: MKMapView!
	@IBOutlet weak var calendarMapViewHeightConstraint: NSLayoutConstraint!
	
	//MARK: Classes
	let common = Common()
	var schedule = ScheduleModel()
	
	//MARK: Shared
	var currentYear = 0
    var selectedMonthNumber = 0
    var selectedMonthName = ""
    var selectedDates = ""
    
	// Used to determine what month has been selected enable to calculate start day position
    var firstDayOfSweepingInMonth = 0
    var weekDayNumberOfFirstDayOfSweepingInMonth = 0
    
    var daysInMonths = [31,28,31,30,31,30,31,31,30,31,30,31]
    var numberOfEmptyBox = Int()
    var nextNumberOfEmptyBox = Int()
    var previousNumberOfEmptyBox = 0
    var direction = 0
    var positionIndex = 0
    var dayCounter = 0
	
	// MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Get latest app version (year)
        currentYear = self.common.defaults.latestAppVersion()
        
		// Get selected month name from schedule view and set it as the title
        selectedMonthName = selectedMonthName.lowercased().capitalizingFirstLetter()
        self.title = "\(selectedMonthName) Sweep Schedule - \(currentYear)"
        
		// Get first day of sweeping month from string of days from the schedule view. Used to calculate start day position
        firstDayOfSweepingInMonth = Int(selectedDates.prefix(2).trimmingCharacters(in: .whitespaces))!
        
        // Create date for first day of sweeping. Used to calculate start day position
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = selectedMonthNumber
        dateComponents.day = firstDayOfSweepingInMonth
        let firstDateOfSweepingInMonth = Foundation.Calendar.current.date(from: dateComponents)
        
		// Get week day number from first day in month
        weekDayNumberOfFirstDayOfSweepingInMonth = Foundation.Calendar.current.component(.weekday, from: firstDateOfSweepingInMonth!) - 1
        if weekDayNumberOfFirstDayOfSweepingInMonth == 0 {
            weekDayNumberOfFirstDayOfSweepingInMonth = 7
        }
        
		// Calculates the number of "empty" boxes at the start of every month
		self.calculateStartDateDayPosition()
        
		// Load calendar map with annotation and polygons
		self.loadCalendarMap()
		
		// Initialize controls per device
		self.initializeControlsPerDevice()
    }
	
	func initializeControlsPerDevice() {
		
		switch UIDevice().type {
		case .iPhoneSE:
			calendarMapViewHeightConstraint.constant = 175
			self.title = "\(selectedMonthName) Schedule - \(currentYear)"
		default:
			break
		}
		
	}
    
	// Load calendar map with annotation and polygons
    func loadCalendarMap() {
        
		// Set required properties for map
        calendarMapView.delegate = self
        
		// Get polygon coordinates from schedule
        let coordinates = self.schedule.polygonCoordinates
		
		// Create polygons from coordinates
        let polygons = MKPolygon(coordinates: coordinates, count: coordinates.count)
        
		// Create map annotation
        let annotation = CustomAnnotation()
		annotation.customImageName = "pin-address"
		annotation.coordinate = self.schedule.locationCoordinate
        annotation.title = "\(self.schedule.address)"
		annotation.subtitle = "Ward: \(self.schedule.ward) - Section: \(self.schedule.section)"
		
		// Create map span
        let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
		
		// Create map region from span
        let region = MKCoordinateRegion(center: self.schedule.locationCoordinate, span: span)
        
		// Set map region
        calendarMapView.setRegion(region, animated: false)
		
		// Add polygons to map
        calendarMapView.removeOverlays(calendarMapView.overlays)
        calendarMapView.addOverlay(polygons)
		
		// Add annotation to map
        calendarMapView.addAnnotation(annotation)
        
    }
    
    // Calculates the number of "empty" boxes at the start of every month
    func calculateStartDateDayPosition() {
        
        switch direction {
        
        case 0:
            
            numberOfEmptyBox = weekDayNumberOfFirstDayOfSweepingInMonth
            dayCounter = firstDayOfSweepingInMonth
            
            while dayCounter > 0 {
                
                numberOfEmptyBox = numberOfEmptyBox - 1
                dayCounter = dayCounter - 1
                
                if numberOfEmptyBox == 0 {
                    numberOfEmptyBox = 7
                }
            }
            
            if numberOfEmptyBox == 7 {
                numberOfEmptyBox = 0
            }
            
            positionIndex = numberOfEmptyBox
            
        case 1...:
            
            nextNumberOfEmptyBox = (positionIndex + daysInMonths[selectedMonthNumber])%7
            positionIndex = nextNumberOfEmptyBox
            
        case -1:
            
            previousNumberOfEmptyBox = (7 - (daysInMonths[selectedMonthNumber] - positionIndex)%7)
            
            if previousNumberOfEmptyBox == 7 {
                previousNumberOfEmptyBox = 0
            }
            
            positionIndex = previousNumberOfEmptyBox
            
        default:
            return
        }
    }
    
    // MARK: Map view methods
    
	// Required method to add polygons to calendar map
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
		
		let reuseIdentifier = "pin"
		
		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
		
		if annotationView == nil {
			
			annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
			annotationView?.canShowCallout = true
			
		}
		else {
			
			annotationView?.annotation = annotation
			
		}
		
		let customPointAnnotation = annotation as! CustomAnnotation
		annotationView?.image = UIImage(named: customPointAnnotation.customImageName)
		annotationView?.centerOffset = CGPoint(x: 0, y: -(annotationView?.image!.size.height)!/2)
		annotationView?.subviews.forEach({ $0.removeFromSuperview() })
		
		let annotationLabel = THLabel(frame: CGRect(x: -40, y: 50, width: 125, height: 30))
		annotationLabel.lineBreakMode = .byWordWrapping
		annotationLabel.textAlignment = .center
		annotationLabel.font = .boldSystemFont(ofSize: 11)
		annotationLabel.text = annotation.title!
		annotationLabel.strokeSize = 1 //self.common.selectedAnnotationStrokeSize()
		annotationLabel.strokeColor = UIColor.white
		annotationView?.addSubview(annotationLabel)
		
		return annotationView
	}
    
    // MARK: Collection view methods
    
	// Required method for calendar collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
        switch direction {
			
        case 0:
            return daysInMonths[selectedMonthNumber - 1] + numberOfEmptyBox
			
        case 1...:
            return daysInMonths[selectedMonthNumber - 1] + nextNumberOfEmptyBox
			
        case -1:
            return daysInMonths[selectedMonthNumber - 1] + previousNumberOfEmptyBox
			
        default:
			return 0
        }
    }
    
	// If user clicks on a sweep date then prompt them to add an event to their calendar
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Add haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        
		// Get cell from collection view
        let cell = collectionView.cellForItem(at: indexPath) as! DateCollectionViewCell
		
		// Get date label from cell
        let dateLabel = cell.viewWithTag(1) as! UILabel
		
		// Get date from date label
        let date = dateLabel.text
        
		// Only allow user to create ane event on a sweep day
        if cell.Circle.isHidden == false {
        
			// Creat alert
			let alert = UIAlertController(title: "Add Calendar Event?", message: "An event will be added to the calendar on your device on \(self.selectedMonthNumber)/\(date!)/\(currentYear).", preferredStyle: .alert)
            
			// Yes option
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
                
				// Create event store
                let eventStore = EKEventStore()

				// Request calendar access
                eventStore.requestAccess(to: .event) { (granted, error) in

                    if (granted) && (error == nil) {
						
                        print("Event access granted: \(granted)")

						// Create event
                        let event:EKEvent = EKEvent(eventStore: eventStore)

						// Create begin date (9 am)
                        var startDateComponents = DateComponents()
                        startDateComponents.year = self.currentYear
                        startDateComponents.month = self.selectedMonthNumber
                        startDateComponents.hour = 9
                        startDateComponents.minute = 0
                        startDateComponents.day = Int(date!)
                        let startDate = Foundation.Calendar.current.date(from: startDateComponents)
                        
						// Create end date (2 pm)
                        var endDateComponents = DateComponents()
                        endDateComponents.year = self.currentYear
                        endDateComponents.month = self.selectedMonthNumber
                        endDateComponents.hour = 14 // 2 pm
                        endDateComponents.minute = 0
                        endDateComponents.day = Int(date!)
                        let endDate = Foundation.Calendar.current.date(from: endDateComponents)
                        
						// Set event properties
                        event.title = "Street Sweeping"
                        event.startDate = startDate
                        event.endDate = endDate
                        event.notes = "Street sweeping between 9 am and 2 pm. Check for signage and move your vehicle to avoid tickets."
                        event.calendar = eventStore.defaultCalendarForNewEvents
                        
						// Add reminder 30 minutes before event startDate
//						let reminder = EKAlarm(relativeOffset: -1800)
//						event.addAlarm(reminder)
						
						// Add event to calendar
						do {
                            try eventStore.save(event, span: .thisEvent)
                        }
						catch let error as NSError {
							print("Failed to add event with error: \(error.localizedDescription)")
							self.common.showAlert(self.common.constants.errorTitle, "Unable to add event to your calendar.")
                        }
                        
						// Alert user event was added
                        DispatchQueue.main.async {
							self.common.showAlert("Event Added", "Event named 'Street Sweeping' was added to your calendar.")
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
            
			// No option
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
			// Present alert
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
	// Required method for calendar collection view to populate view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
		// Get cell from collection view
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Calendar", for: indexPath) as! DateCollectionViewCell
        
		// Set cell properties
        cell.backgroundColor = UIColor.clear
        //cell.DateLabel.textColor = UIColor.black
        cell.Circle.isHidden = true

        if cell.isHidden {
            cell.isHidden = false
        }

		// The first cells that need to be hidden (if needed) will be negative or zero so we can hide them
        switch direction {
			
        case 0:
            cell.DateLabel.text = "\(indexPath.row + 1 - numberOfEmptyBox)"
			
        case 1:
            cell.DateLabel.text = "\(indexPath.row + 1 - nextNumberOfEmptyBox)"
			
        case -1:
            cell.DateLabel.text = "\(indexPath.row + 1 - previousNumberOfEmptyBox)"
			
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
            if indexPath.row + 1 - numberOfEmptyBox == Int(date) {
                cell.Circle.isHidden = false
                cell.DrawCircle()
            }
        }

        return cell
    }
}

