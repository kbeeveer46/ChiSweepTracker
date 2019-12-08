import  Foundation

protocol NotificationsModelDelegate {
    
    func userDownloaded(user: UserModel)
    
}

class NotificationsModel {
    
    var delegate:NotificationsModelDelegate?

    func getUser(_ email: String) {
        
        let serviceURL = "http://chicagosweeptracker.info/test.php?email=\(email)"
        
        let url = URL(string: serviceURL)
        
        if let url = url {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
             
                if error == nil {
                    
                    self.parseUser(data!)
                    
                }
                else {
                    
                    // Error
                }
                
            })
            
            task.resume()
            
        }
        
    }
    
    func parseUser(_ data: Data) {
        
        let user = UserModel()
        
        do {
            
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as! [Any]
            
            let userArray = jsonArray[0] as? [String: Any] ?? [:]
            
            user.id = userArray["id"] as! String
            user.email = userArray["email"] as! String
            user.ward = userArray["ward"] as! String
            user.section = userArray["section"] as! String
            user.when_day = userArray["when_day"] as! String
            user.when_hour = userArray["when_hour"] as! String
            user.when_minute = userArray["when_minute"] as! String
            user.when_ampm = userArray["when_ampm"] as! String
            
            //print(userArray)
            
            DispatchQueue.main.async {
            
                self.delegate?.userDownloaded(user: user)
                
            }
        
        }
        catch {
            
        }
    }
    
//    func insertUser(_ email: String, _ email: String, _ w) {
//
//
//
//    }
//
//    func updateUser {
//
//
//
//    }
    
}
