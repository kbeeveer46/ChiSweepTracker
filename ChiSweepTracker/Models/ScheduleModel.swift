import Foundation
import CoreLocation

public class ScheduleModel /*: Decodable, Encodable*/ {
    var address = ""
    var ward = ""
    var section = ""
    var months: [MonthModel] = []
    var locationCoordinate = CLLocationCoordinate2D()
    var polygonCoordinates = [CLLocationCoordinate2D]()
    
//    private enum CodingKeys: String, CodingKey {
//        case address
//        case ward
//        case section
//        case months
//        case locationCoordinate
//        case polygonCoordinates
//    }
//
//    init(address: String, ward: String, section: String, months: [MonthModel], locationCoordinate: CLLocationCoordinate2D, polygonCoordinates: [CLLocationCoordinate2D]) {
//        self.address = address
//        self.ward = ward
//        self.section = section
//        self.months = months
//        self.locationCoordinate = locationCoordinate
//        self.polygonCoordinates = polygonCoordinates
//    }
//
//    public required init(from decoder:Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
//        ward = try values.decodeIfPresent(String.self, forKey: .ward) ?? ""
//        section = try values.decodeIfPresent(String.self, forKey: .section) ?? ""
//        //months = try values.decodeIfPresent([MonthModel].self, forKey: .months) ?? [MonthModel]()
//        //locationCoordinate = try values.decode(CLLocationCoordinate2D.self, forKey: .locationCoordinate)
//        //polygonCoordinates = try values.decode([CLLocationCoordinate2D].self, forKey: .polygonCoordinates)
//    }
}

class MonthModel: Identifiable {
    var name = ""
    var number = ""
    var dates: [DateModel] = []
}

class DateModel: Identifiable {
    var date = 0
}
