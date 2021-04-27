import Foundation

class AddressModel: Decodable {
    
    var address = ""
    var notificationsEnabled = ""
    var notificationsWhen = ""
    var notificationsHour = ""
    var notificationsMinute = ""
    var nextSweepDay: Date?
    
}
