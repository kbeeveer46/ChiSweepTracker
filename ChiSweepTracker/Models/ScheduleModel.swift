import Foundation
import CoreLocation

public class ScheduleModel {
    var address = ""
    var ward = ""
    var section = ""
    var months: [MonthModel] = []
    var locationCoordinate = CLLocationCoordinate2D()
    var polygonCoordinates = [CLLocationCoordinate2D]()
}

class MonthModel: Identifiable  {
    var name = ""
    var number = ""
    var dates: [DateModel] = []
}

class DateModel: Identifiable {
    var date = 0
}
