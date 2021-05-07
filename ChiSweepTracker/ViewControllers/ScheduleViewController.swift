import UIKit
import CoreLocation
import MapKit
import THLabel
import StoreKit

class ScheduleViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
	// Controls
    @IBOutlet weak var scheduleMapView: MKMapView!
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var scheduleMapViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var comingSoonStackView: UIStackView!
    @IBOutlet weak var comingSoonYearLabel: UILabel!
    
	// Shared
    let generator = UISelectionFeedbackGenerator()
    let currentYear = Calendar.current.component(.year, from: Date())
    
	// Classes
	let common = Common()
    var schedule = ScheduleModel()
    
    // In-app purchase
    var myProduct: SKProduct?
    var price: NSDecimalNumber?
    
	// MARK: Methods
	
    override func viewWillAppear(_ animated: Bool) {
        
		// Set title using latest app version (year)
		self.title = "Sweep Schedule - \(self.common.latestAppVersion())"
		
        // Show options menu in the top right
        self.showSaveFavoriteMenuItem()
        
		// Load map with annotations and overlays
		self.loadScheduleMap()
		
		// Initialize controls per device
		self.initializeControlsPerDevice()
        
        if (self.currentYear > self.common.latestAppVersion()) {
            self.comingSoonStackView.isHidden = false
            self.comingSoonYearLabel.text = "The \(self.currentYear) sweeping schedule is coming soon"
        }
        else {
            self.comingSoonStackView.isHidden = true
        }
		
		// Set required properties for schedule table view
		self.scheduleTableView.dataSource = self
		self.scheduleTableView.delegate = self
		self.scheduleTableView.reloadData()
        
        // Gets and sets the multiple addresses in-app purchase so users can buy it
        getMultipleAddressesInAppPurchase()
        
	}
    
    // Gets the multiple addresses in-app purchase
    func getMultipleAddressesInAppPurchase() {
        let request = SKProductsRequest(productIdentifiers: [common.constants.multipleAddressIAPurchase])
        request.delegate = self
        request.start()
    }
    
    // Sets the multiple addresses in-app purchase
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            self.myProduct = product
            self.price = product.price
        }
    }
    
    // Do not remove. Handles the in-app purchasing result
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break
            case .purchased:
                defaults.set(true, forKey: "enableMultipleAddresses")
                SKPaymentQueue.default().finishTransaction(transaction)
                self.common.showAlert("Purchase Complete", "Saving multiple addresses is now enabled. Click on the plus icon to save this address.")
                SKPaymentQueue.default().remove(self)
                break
            case .restored:
                defaults.set(true, forKey: "enableMultipleAddresses")
                SKPaymentQueue.default().finishTransaction(transaction)
                self.common.showAlert("Purchase Restored", "Saving multiple addresses is now enabled. Click on the plus icon to save this address.")
                SKPaymentQueue.default().remove(self)
                break
            case .failed:
                defaults.set(false, forKey: "enableMultipleAddresses")
                SKPaymentQueue.default().finishTransaction(transaction)
                self.common.showAlert("Purchase Did Not Complete", "Your device did not complete the purchase.")
                SKPaymentQueue.default().remove(self)
                break
            case .deferred:
                defaults.set(false, forKey: "enableMultipleAddresses")
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            default:
                defaults.set(false, forKey: "enableMultipleAddresses")
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            }
        }
    }
    
//    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
//        print(error.localizedDescription)
//    }
//
//    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
//        print(queue)
//    }
	
	func initializeControlsPerDevice() {
		
		switch UIDevice().type {
		case .iPhoneSE:
			scheduleMapViewHeightConstraint.constant = 175
			scheduleTableView.rowHeight = 37
		default:
			break
		}
	}
    
	// Method is called when user chooses yes to add a favorite
    @objc func saveAddress() {
        
        self.common.getAddresses(completion: { addresses in
            
            let favoriteAddressCount = addresses.count
            
            DispatchQueue.main.async {
                
                // Add haptic feedback
                self.generator.prepare()
                self.generator.selectionChanged()
                
                if favoriteAddressCount == 0  ||
                    favoriteAddressCount >= 1  && self.common.enableMultipleAddresses() == true ||
                    favoriteAddressCount >= 1  && self.common.enableMultipleAddresses() == false && self.myProduct == nil {
                
                    self.navigationItem.rightBarButtonItem = nil
                    
                    self.common.getNextSweepDay(address: self.schedule.address, completion: { date in
                        
                        var nextSweepDayFormatted = ""
                        
                        if date != nil {
                            let calendar = Calendar.current
                            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: date!)
                            nextSweepDayFormatted = "\(components.month!)/\(components.day!)/\(components.year!)"
                        }
                            
                        self.common.insertAddressIntoDatabase(address: self.schedule.address, notificationsEnabled: 0, notificationsWhen: "Day Of Sweep", notificationsHour: 0, notificationsMinute: 0, nextSweepDay: nextSweepDayFormatted, completion: { result in
                                                                
                            // Create alert
                            let alert = UIAlertController(title: "Address Saved", message: "Would you like to enable notifications?", preferredStyle: .alert)
                            
                            // Yes option
                            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
                                
                                // Segue to schedule view
                                if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "FavoriteViewController") as? FavoriteViewController {
                                    destinationViewController.schedule = self.schedule
                                    self.navigationController?.pushViewController(destinationViewController, animated: true)
                                }
                        
                            }))
                            
                            // No option
                            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                            
                            // Present alert
                            self.present(alert, animated: true, completion: nil)
                                                                
                        })
                    })
                }
                else if favoriteAddressCount != -1 {
                    
                    // Create alert
                    let alert = UIAlertController(title: "Premium Feature", message: "Saving more than one addresses requires a one-time purchase of $\(self.price!). Would you like to proceed to the purchase screen?", preferredStyle: .alert)

                    // Yes option
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
                        
                        guard let myProduct = self.myProduct else {
                            return
                        }
            
                        if SKPaymentQueue.canMakePayments() {
                            let payment = SKPayment(product: myProduct)
                            SKPaymentQueue.default().add(self)
                            SKPaymentQueue.default().add(payment)
                        }
                        else {
                            self.common.showAlert("Unable to purchase", "Your device does not have the required permissions to make this purchase.")
                        }
                
                    }))
                    
                    // Restore option
                    alert.addAction(UIAlertAction(title: "Restore Previous Purchase", style: .default, handler:{ action in
                        SKPaymentQueue.default().add(self)
                        SKPaymentQueue.default().restoreCompletedTransactions()
                    }))
                    
                    // No option
                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    
                    // Present alert
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
        })
    }
    
    // Show settings button in the top right
    func showSaveFavoriteMenuItem() {
        
        self.common.getAddresses(address: self.schedule.address, completion: { addresses in
            
            var doNotShowOptionsMenu = false
            
            if addresses.count > 0 {
                doNotShowOptionsMenu = true
            }
            
            DispatchQueue.main.async {
                if !doNotShowOptionsMenu {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(self.openSaveAddressMenuItem))
                }
                else {
                    self.navigationItem.rightBarButtonItem = nil
                }
            }
        })
    }
    
	@objc func openSaveAddressMenuItem() {
		
		// Add haptic feedback
		let generator = UISelectionFeedbackGenerator()
		generator.prepare()
		generator.selectionChanged()
		
		// Create options alert
		let optionsAlert = UIAlertController(title: nil, message: "Options", preferredStyle: .actionSheet)
		
		// Create add favorite option for options alert
		let saveFavoriteAction = UIAlertAction(title: "Save Address", style: .default, handler:{ action in
			self.saveAddress()
		})
        optionsAlert.addAction(saveFavoriteAction)
		
		let favoriteImage = UIImage(named: "house_alt")
		if let icon = favoriteImage?.imageWithSize(scaledToSize: CGSize(width: 32, height: 32)) {
			saveFavoriteAction.setValue(icon, forKey: "image")
		}
		
		// Create cancel option for options alert
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		
		// Add options to options alert
		optionsAlert.addAction(cancelAction)
		
		// Present options alert
		self.present(optionsAlert, animated: true, completion: nil)
		
	}
	
	// Load schedule map with annotation and polygons
	func loadScheduleMap() {
		
		// Set required map properties
		scheduleMapView.delegate = self
		
		// Create polygons
		let coordinates = self.schedule.polygonCoordinates
		let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
		
		// Create annotation
		let annotation = CustomAnnotation()
		annotation.customImageName = "pin-address"
		annotation.coordinate = self.schedule.locationCoordinate
		annotation.title = "\(self.schedule.address)"
		annotation.subtitle = "Ward: \(self.schedule.ward) - Section: \(self.schedule.section)"
		
		// Create span and region
		let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
		let region = MKCoordinateRegion(center: self.schedule.locationCoordinate, span: span)
		
		// Set region
		scheduleMapView.setRegion(region, animated: false)
		
		// Add polygons to map
		scheduleMapView.removeOverlays(scheduleMapView.overlays)
		scheduleMapView.addOverlay(polygon)
		
		// Add annotation to map
		scheduleMapView.addAnnotation(annotation)
		
	}

    // Months/Days table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule.months.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
        
        // Add haptic feedback
        generator.prepare()
        generator.selectionChanged()
        
		// Get selected month and send user to calendar view
		
		// Get cell from table view
        let cell = tableView.cellForRow(at: indexPath)!
		
		// Get days label from cell
        let daysLabel = cell.viewWithTag(2) as! UILabel
		
		// Get list of days from days label
        let days = daysLabel.text!.trimmingCharacters(in: .whitespaces)
        
        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController {
            
			// Pass month name, number, days, and schededule to calendar view
			destinationViewController.selectedMonthNumber = Int(schedule.months[indexPath.row].number) ?? 0
            destinationViewController.selectedMonthName = schedule.months[indexPath.row].name
            destinationViewController.selectedDates = days
            destinationViewController.schedule = self.schedule
            self.navigationController?.pushViewController(destinationViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
		// Get cell from table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleTableCell", for: indexPath)
        
		// Get labels from cell
		let monthNameLabel = cell.viewWithTag(1) as! UILabel
        let daysLabel = cell.viewWithTag(2) as! UILabel

        // Concatenate dates in one string and add padding between days
        var dates = ""
        for date in schedule.months[indexPath.row].dates  {
            dates = dates + String(date.date).padding(toLength: 5, withPad: " ", startingAt: 0)
        }

		// Set label text
        monthNameLabel.text = schedule.months[indexPath.row].name
		daysLabel.text = dates
		
		// If month equals the current month then change the labels to blue
		let date = Date()
		if (date.month.uppercased() == schedule.months[indexPath.row].name.uppercased()) &&
           (self.currentYear == self.common.latestAppVersion()) {
			daysLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
			daysLabel.textColor = UIColor(hexString: self.common.constants.systemBlue)
			monthNameLabel.textColor = UIColor(hexString: self.common.constants.systemBlue)
		}

        return cell
        
    }
    
	// Method required to add polygons to schedule map
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
}
