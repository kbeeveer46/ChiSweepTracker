import Intents
import Alamofire

class GetNextSweepDayIntentHandler: NSObject, GetNextSweepDayIntentHandling {
    
    //let database = Database()
    //let common = Common()
    let defaults = UserDefaults(suiteName: "group.com.kylebeverforden.chisweeptracker.defaults")
    
    func handle(intent: GetNextSweepDayIntent, completion: @escaping (GetNextSweepDayIntentResponse) -> Void) {
        
        getNextSweepDay(result: { nextSweepDay in
            
            //let nextSweepDay = "750 N Dearborn Chicago - 11/22/2021"
            completion(GetNextSweepDayIntentResponse.success(result: nextSweepDay))
            
        })
        
    }
    
    // Get all addresses and find the next sweeping day
    func getNextSweepDay(result: @escaping (String) -> Void) {

        var sweepDates = [Date]()

        //self.database.getAddresses(completion: { addresses in
        self.getAddresses(completion: { addresses in
            
            for address in addresses {
                if address.nextSweepDay != nil {
                    sweepDates.append(address.nextSweepDay!)
                }
            }

            if sweepDates.count > 0 {

                if let nextSweepDay = sweepDates.min() {

                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.year, .month, .day], from: nextSweepDay)
                    result("Your next sweeping is on \(components.month!)/\(components.day!)/\(components.year!)")

                }
            }
            else {
                result("You do not have any saved addresses")
            }
        })
    }
    
    func getAddresses(address: String = "", completion: @escaping (_ message: [AddressModel]) -> ()) {
        
        var addresses = [AddressModel]()
        var parameters = [String: String]()
        //let urlTo = self.common.constants.websiteURL + "/get-address-data.php"
        let urlTo = "https://chicagosweeptracker.info/get-address-data.php"
        
        //parameters = ["tableName": self.common.constants.addressesDatabaseName, "uuid": self.common.defaults.deviceUUID()]
        parameters = ["tableName": "addresses_dev", "uuid": self.defaults!.string(forKey: "deviceUUID") ?? ""]

        AF.request(urlTo, parameters: parameters).validate().responseJSON() { response in
            switch response.result {
            case .failure(let error):
                print(error)
                completion(addresses)
            case .success:
                if let value = response.data {
                    
                    let json =  (try? JSONSerialization.jsonObject(with: value)) as! [[String: String]]
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "M/dd/yyyy"
                    
                    for item in json.enumerated() {
                        
                        let address = AddressModel()
                        address.address = item.element["address"]!
                        address.notificationsEnabled = item.element["notificationsEnabled"]!
                        address.notificationsWhen = item.element["notificationsWhen"]!
                        address.notificationsHour = item.element["notificationsHour"]!
                        address.notificationsMinute = item.element["notificationsMinute"]!
                        
                        let nextSweepDay = item.element["nextSweepDay"]!
                        if nextSweepDay != "" {
                            address.nextSweepDay = dateFormatter.date(from: nextSweepDay)!
                        }
                        
                        addresses.append(address)
                    }
                    
                    completion(addresses)
                }
            }
        }
    }


}
