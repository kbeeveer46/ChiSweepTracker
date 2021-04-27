import UIKit
import Alamofire

class UpdatesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Controls
    @IBOutlet weak var newsTableView: UITableView!
    
    // Classes
    let common = Common()
    
    // Shared
    var updatesList = [UpdatesModel]()
    var updatesLastViewedDate = ""
    let dateFormatter = DateFormatter()
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Set title
        self.tabBarController?.navigationItem.title = "Latest Sweeping Updates"
        
        // Clear top navigation items
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        // Set required properties for table view
        self.newsTableView.separatorColor = UIColor(white: 0.95, alpha: 1)
        self.newsTableView.dataSource = self
        self.newsTableView.delegate = self
        
        // Set dateFormatter properties
        dateFormatter.dateFormat = "M/dd/yyyy H:m:ss"
        dateFormatter.locale = .current
        
        // Get the date and time the last time the user views the updates page
        updatesLastViewedDate = self.common.updatesLastViewDate()
        
        // Save the current date to defaults so it can be used to determine if there are any new updates the next time the app is opened
        let currentDate = self.dateFormatter.string(from: Date())
        defaults.set(currentDate, forKey: "updatesLastViewDate")
        
        // Get list of latest updates
        getLatestUpdates()
    }
    
    func getLatestUpdates() {
        
        let urlTo = self.common.constants.websiteURL + "/get-news-data.php"
        let parameters = ["tableName": self.common.constants.newsDatabaseName]
        
        AF.request(urlTo, parameters: parameters).validate().responseJSON() { response in
            switch response.result {
            case .failure(let error):
                print(error)
            case .success:
                if let value = response.data {
                    
                    let json =  (try? JSONSerialization.jsonObject(with: value)) as! [[String: String]]
                    
                    self.updatesList.removeAll()
                    
                    for update in json.enumerated() {
                        
                        let subject = update.element["subject"]
                        let body = update.element["body"]
                        let date = update.element["date"]
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let dateFormatted = dateFormatter.date(from: date!)!
                        let ampm = Calendar.current.component(.hour, from: dateFormatted) < 12 ? "AM" : "PM"
                        let minute = Calendar.current.component(.minute, from: dateFormatted)
                        var hour = Calendar.current.component(.hour, from: dateFormatted)
                        let day = Calendar.current.component(.day, from: dateFormatted)
                        let month = Calendar.current.component(.month, from: dateFormatted)
                        let year = Calendar.current.component(.year, from: dateFormatted)
                        let showNewImage = self.showNewImage("\(month)/\(day)/\(year) \(hour):\(minute):00")
                        
                        if hour == 0 {
                            hour = 12
                        }
                        else if hour > 12 {
                            hour = hour - 12
                        }
                        
                        let update = UpdatesModel()
                        update.body = body!
                        update.subject = subject!
                        update.year = year
                        update.month = month
                        update.day = day
                        update.hour = hour
                        update.minute = minute
                        update.ampm = ampm
                        update.showNewImage = showNewImage
                        self.updatesList.append(update)
                        
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.newsTableView.reloadData()
                        
                        // Clear updates tab bar badge
                        self.tabBarController?.tabBar.items?.last!.badgeValue = nil
                    }
                    
                }
            }
        }
    }
    
    func showNewImage(_ date: String!) -> Bool {
        
        // Compare the update date to the date the user last opened the news page to determine if the new image should show next to the title
        
        if !updatesLastViewedDate.isEmpty {
            
            let updateDate = dateFormatter.date(from: date)
            let lastViewed = dateFormatter.date(from: updatesLastViewedDate)
            
            if updateDate! > lastViewed! {
                return true
            } else {
                return false
            }
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updatesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get cell from table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "updatesTableCell", for: indexPath)
        
        cell.contentView.backgroundColor = UIColor(hexString: self.common.constants.background)
        
        // Get labels and new image from cell
        let subjectLabel = cell.viewWithTag(1) as! UILabel
        let dateLabel = cell.viewWithTag(2) as! UILabel
        let bodyLabel = cell.viewWithTag(3) as! UILabel
        let newImage = cell.viewWithTag(4) as! UIImageView
        
        // Set label values
        subjectLabel.text = self.updatesList[indexPath.row].subject
        dateLabel.text = "\(self.updatesList[indexPath.row].month)/\(self.updatesList[indexPath.row].day)/\(self.updatesList[indexPath.row].year)"
        bodyLabel.text = self.updatesList[indexPath.row].body
        
        // Hide or show new image
        if self.updatesList[indexPath.row].showNewImage == false {
            newImage.isHidden = true
        }
        else {
            newImage.isHidden = false
        }
        
        return cell
    }
}
