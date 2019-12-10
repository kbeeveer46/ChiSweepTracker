import Foundation
import CoreLocation

public class ScheduleModel /*: NSObject, NSCoding*/  {

    var address = ""
    var ward = ""
    var section = ""
    var months: [MonthModel] = []
    var locationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var polygonCoordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    
//    init(address: String,
//         ward: String,
//         section: String,
//         months: [MonthModel],
//         locationCoordinate: CLLocationCoordinate2D,
//         polygonCoordinates: [CLLocationCoordinate2D]) {
//        self.address = address
//        self.ward = ward
//        self.section = section
//        self.months = months
//        self.locationCoordinate = locationCoordinate
//        self.polygonCoordinates = polygonCoordinates
//    }
//
//    public required convenience init(coder aDecoder: NSCoder) {
//
//        let address = aDecoder.decodeObject(forKey: "address") as! String
//        let ward = aDecoder.decodeObject(forKey: "ward") as! String
//        let section = aDecoder.decodeObject(forKey: "section") as! String
//        let months = aDecoder.decodeObject(forKey: "months") as! [MonthModel]
//        let locationCoordinate = aDecoder.decodeObject(forKey: "locationCoordinate") as! CLLocationCoordinate2D
//        let polygonCoordinates = aDecoder.decodeObject(forKey: "polygonCoordinates") as! [CLLocationCoordinate2D]
//
//        self.init(address: address,
//                  ward: ward,
//                  section: section,
//                  months: months,
//                  locationCoordinate: locationCoordinate,
//                  polygonCoordinates: polygonCoordinates)
//    }
//
//    public func encode(with aCoder: NSCoder) {
//
//        aCoder.encode(address, forKey: "address")
//        aCoder.encode(ward, forKey: "ward")
//        aCoder.encode(section, forKey: "section")
//        aCoder.encode(months, forKey: "months")
//        aCoder.encode(locationCoordinate, forKey: "locationCoordinate")
//        aCoder.encode(polygonCoordinates, forKey: "polygonCoordinates")
//
//    }
//
}

class MonthModel: /*NSObject, NSCoding,*/ Identifiable  {
    
    var name = ""
    var number = ""
    var dates: [DateModel] = []
    
//    init(name: String,
//         number: String,
//         dates: [DateModel]) {
//        self.name = name
//        self.number = number
//        self.dates = dates
//    }
//
//    required convenience init(coder aDecoder: NSCoder) {
//
//        let name = aDecoder.decodeObject(forKey: "name") as! String
//        let number = aDecoder.decodeObject(forKey: "number") as! String
//        let dates = aDecoder.decodeObject(forKey: "dates") as! [DateModel]
//
//        self.init(name: name,
//                  number: number,
//                  dates: dates)
//    }
//
//    func encode(with aCoder: NSCoder) {
//
//        aCoder.encode(name, forKey: "name")
//        aCoder.encode(number, forKey: "number")
//        aCoder.encode(dates, forKey: "dates")
//
//    }
    
}

class DateModel: /*NSObject, NSCoding,*/ Identifiable {
    
    var date = 0
    
//    init(date: Int) { self.date = date }
//
//    required convenience init(coder aDecoder: NSCoder) {
//        
//        let date = aDecoder.decodeInteger(forKey: "date") 
//        
//        self.init(date: date)
//    }
//
//    func encode(with aCoder: NSCoder) {
//        
//        aCoder.encode(date, forKey: "date")
//
//    }
//    
}
