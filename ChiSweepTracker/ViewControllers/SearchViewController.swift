import UIKit
import CoreLocation
import MapKit

class SearchViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var searchAddressButton: UIButton!
    @IBOutlet weak var useMyLocationButton: UIButton!
    @IBOutlet weak var chicagoMapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    //var schedule = Schedule()
    var addressFromTextField = ""
    var addressFromCoordinates = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addressTextField.delegate = self
        
        searchAddressButton.backgroundColor = UIColor.init(red: 48/255, green: 178/255, blue: 99/255, alpha: 1)
        searchAddressButton.layer.cornerRadius = 7.0
        searchAddressButton.tintColor = .white
        if #available(iOS 13.0, *) {
            searchAddressButton.leftImage(image: UIImage(systemName: "magnifyingglass.circle")!)
        }
        
        useMyLocationButton.backgroundColor = UIColor.init(red: 48/255, green: 178/255, blue: 99/255, alpha: 1)
        useMyLocationButton.layer.cornerRadius = 7.0
        useMyLocationButton.tintColor = .white
        if #available(iOS 13.0, *) {
            useMyLocationButton.leftImage(image: UIImage(systemName: "location.circle")!)
        }
        
        // Load Chicago map
        
        chicagoMapView.delegate = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: chicagoMapView, action: #selector(addAnnotation(gesture:)))
        longPressGesture.minimumPressDuration = 2.0
        chicagoMapView.addGestureRecognizer(longPressGesture)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
        
        var chicagoCoordinate = CLLocationCoordinate2D()
        chicagoCoordinate.latitude = 41.882698
        chicagoCoordinate.longitude = -87.694779
        
        let region = MKCoordinateRegion(center: chicagoCoordinate, span: span)
        
        chicagoMapView.setRegion(region, animated: true)
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
    
    @objc func addAnnotation(gesture: UILongPressGestureRecognizer) {
        
        print("addAnnotation has fired")
        
        if gesture.state == .ended {
            
            let point = gesture.location(in: chicagoMapView)
            let coordinate = chicagoMapView.convert(point, toCoordinateFrom: chicagoMapView)
            print(coordinate)
            
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            //annotation.title = "Title"
            //annotation.subtitle = "subtitle"
            
            chicagoMapView.addAnnotation(annotation)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        //addressFromTextField = addressTextField.text!.trimmingCharacters(in: .whitespaces)
        //addressFromTextField = "750 N Dearborn St. Chicago, IL"
        //addressFromTextField = "1060 W Addison Chicago, IL"
        addressFromTextField = "1601 North Clark Street, Chicago, IL, USA"
        
//        if (sender as? UIButton == searchAddressButton) {
//
//            if addressFromTextField.isEmpty {
//
//                // Show error
//
//                return false
//
//            }
//
//        } else if (sender as? UIButton == useMyLocationButton) {
//
//            if addressFromCoordinates.isEmpty {
//
//                // Show error
//
//                return false
//
//            }
//
//
//        }
//
       return true
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        let scheduleViewController = segue.destination as! ScheduleViewController
//
//        if (sender as? UIButton == searchAddressButton) {
//
//            //print("search address button")
//            scheduleViewController.address = addressFromTextField
//
//        } else if (sender as? UIButton == useMyLocationButton) {
//
//            //print("my location button")
//            scheduleViewController.address = addressFromCoordinates
//
//        }
        
    }
    
    @IBAction func searchAddressTapped(_ sender: Any) {
        
         self.performSegue(withIdentifier: "selectSectionSegue", sender: self)
        
//        if launchedBefore  {
//               /*Use the Identifier you given in story Board*/
//                      self.performSegue(withIdentifier: "otherVC", sender: self)
//
//                   } else {
//           /*Use the Identifier you given in story Board*/
//               self.performSegue(withIdentifier: "register", sender: self))
//                       UserDefaults.standard.set(true, forKey: "launchedBefore")
//                   }
        
    }
    
    @IBAction func useMyLocationTapped(_ sender: Any) {
        
        
    }
    
    func getAddressFromCoordinates(_ location: CLLocation) {
        
        var address = ""
        let ceo: CLGeocoder = CLGeocoder()
        let loc: CLLocation = CLLocation(latitude: location.coordinate.latitude,
                                         longitude: location.coordinate.longitude)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                
                if placemarks != nil {
                    
                    if placemarks!.count > 0 {
                        
                        let pm = placemarks! as [CLPlacemark]
                        
                        if pm.count > 0 {
                            
                            let pm = placemarks![0]
                            
                            if pm.subLocality != nil {
                                address = address + pm.subThoroughfare! + " "
                            }
                            if pm.thoroughfare != nil {
                                address = address + pm.thoroughfare! + ", "
                            }
                            if pm.locality != nil {
                                address = address + pm.locality! + " "
                            }
                            if pm.postalCode != nil {
                                address = address + pm.postalCode! + " "
                            }
                            
                            self.addressFromCoordinates = address.trimmingCharacters(in: .whitespaces)
                            
                            print("getAddressFromCoordinates: \(self.addressFromCoordinates)")
                            
                        }
                    }
                }
        })
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            
            getAddressFromCoordinates(location)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.denied {
            
            showLocationDisabledPopup()
            
        }
        
    }
    
    func showLocationDisabledPopup() {
        
        let alertController = UIAlertController(title: "Location Access Disabled", message: "You will have to manually search for your address if you wish to disable location access", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            
            if let url = URL(string: UIApplication.openSettingsURLString) {
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            }
        }
        
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UIButton {
    
    // Add image on left view
    func leftImage(image: UIImage) {
        self.setImage(image, for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image.size.width)
    }
}

