//import  Foundation
//
//protocol NotificationsModelDelegate {
//    
//    func userDownloaded(user: UserModel)
//    
//}
//
//class NotificationsModel {
//    
//    var delegate:NotificationsModelDelegate?
//    
//    func insertUpdateUser(id: String,
//                          email: String,
//                          active: Int,
//                          ward: String,
//                          section: String,
//                          whenDay: String,
//                          whenHour: String,
//                          whenMinute: String,
//                          pushNotifications: Int) {
//        
//        var serviceURL = "http://chicagosweeptracker.info/insertupdateuser.php?active=\(active)&email=\(email)&ward=\(ward)&section=\(section)&when_day=\(whenDay)&when_hour=\(whenHour)&when_minute=\(whenMinute)&id=\(id)&push_notifications=\(pushNotifications)"
//            
//        serviceURL = serviceURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//        
//        let url = URL(string: serviceURL)
//        
//        if let url = url {
//            
//            let session = URLSession(configuration: .default)
//            
//            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
//             
//                if error == nil {
//                    
//                    self.parseUser(data!)
//                    
//                }
//                else {
//                    
//                    print(error!.localizedDescription)
//                }
//            })
//            
//            task.resume()
//            
//        }
//    }
//    
//
//    func getUser(_ email: String) {
//        
//        let serviceURL = "http://chicagosweeptracker.info/getuser.php?email=\(email)"
//        
//        let url = URL(string: serviceURL)
//        
//        if let url = url {
//            
//            let session = URLSession(configuration: .default)
//            
//            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
//             
//                if error == nil {
//                    
//                    self.parseUser(data!)
//                    
//                }
//                else {
//                    
//                    // Error
//                }
//            })
//            
//            task.resume()
//            
//        }
//    }
//    
//    func parseUser(_ data: Data) {
//        
//        let user = UserModel()
//        
//        do {
//            
//            let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as! [Any]
//            
//            let userArray = jsonArray[0] as? [String: Any] ?? [:]
//            
//            user.id = userArray["id"] as! String
//            user.email = userArray["email"] as! String
//            user.ward = userArray["ward"] as! String
//            user.section = userArray["section"] as! String
//            user.whenDay = userArray["when_day"] as! String
//            user.whenHour = userArray["when_hour"] as! String
//            user.whenMinute = userArray["when_minute"] as! String
//            
//            let active = userArray["active"] as! String
//            if active == "1" {
//                user.active = true
//            }
//            else {
//                user.active = false
//            }
//            
//            let pushNotifications = userArray["push_notifications"] as! String
//            if pushNotifications == "1" {
//                user.pushNotifications = true
//            }
//            else {
//                user.pushNotifications = false
//            }
//            
//            //print(userArray)
//            
//            DispatchQueue.main.async {
//            
//                self.delegate?.userDownloaded(user: user)
//                
//            }
//        
//        }
//        catch {
//            
//        }
//    }
//    
//}
