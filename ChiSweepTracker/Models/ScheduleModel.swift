import Foundation
import CoreLocation

public class Schedule  {

    var address = ""
    var ward = ""
    var section = ""
    var months: [Month] = []
    var locationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var polygonCoordinatesForMap: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    
}

class Month: Identifiable {
    
    var name = ""
    var number = 0
    var dates: [Date] = []
    
}

class Date: Identifiable {
    
    var date = 0
    
}
