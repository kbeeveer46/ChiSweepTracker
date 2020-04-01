import UIKit
import Firebase

class UpdatesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	// Controls
	@IBOutlet weak var newsTableView: UITableView!
	
	// Classes
	let common = Common()
	
	// Shared
	var updatesList = [UpdatesModel]()
	var updatesLastViewedDate = ""
	
    override func viewWillAppear(_ animated: Bool) {

		// Set title
		self.tabBarController?.navigationItem.title = "Latest Sweeping Updates"
		
		// Clear top navigation items
		self.tabBarController?.navigationItem.leftBarButtonItem = nil
		self.tabBarController?.navigationItem.rightBarButtonItem = nil
		
		updatesLastViewedDate = self.common.updatesLastViewDate()
		
		getLatestUpdates()
    }
	
	func getLatestUpdates() {
		
		let db = Firestore.firestore()
		//var count = 1
		
		// Figure out how to determine if there has been a new news item
		// If there's a new item set the badge number
		
		// Get updates data
		db.collection(self.common.constants.newsDatabaseName)
			.order(by: "date", descending: true)
			.limit(to: 5)
			.getDocuments() { (querySnapshot, err) in
				if let err = err {
					print("Could not get updates from Firebase: \(err)")
				} else {
					
					self.updatesList.removeAll()
					
					for document in querySnapshot!.documents {
						
						let data = document.data()
						
						let subject = data["subject"] as! String
						let body = data["body"] as! String
						let date = data["date"] as! Timestamp
						let ampm = Calendar.current.component(.hour, from: date.dateValue()) < 12 ? "AM" : "PM"
						let minute = Calendar.current.component(.minute, from: date.dateValue())
						var hour = Calendar.current.component(.hour, from: date.dateValue())
						let day = Calendar.current.component(.day, from: date.dateValue())
						let month = Calendar.current.component(.month, from: date.dateValue())
						let year = Calendar.current.component(.year, from: date.dateValue())
						let showNewImage = self.showNewImage("\(month)/\(day)/\(year) \(hour):\(minute):00")
						
						if hour == 0 {
							hour = 12
						}
						else if hour > 12 {
							hour = hour - 12
						}
						
						//print(ampm)
						//print(minute)
						//print(hour)
						//print(day)
						//print(month)
						//print(year)
						//print(subject)
						//print(body)
						
						let update = UpdatesModel()
						update.body = body
						update.subject = subject
						update.year = year
						update.month = month
						update.day = day
						update.hour = hour
						update.minute = minute
						update.ampm = ampm
						update.showNewImage = showNewImage
						self.updatesList.append(update)
						
						//count += 1
					}
					
					// Set required properties for table view
					self.newsTableView.dataSource = self
					self.newsTableView.delegate = self
					self.newsTableView.reloadData()
					
					self.tabBarController?.tabBar.items?.last!.badgeValue = nil
					
					let dateFormatter = DateFormatter()
					dateFormatter.dateFormat = "M/dd/yyyy H:m:ss"
					dateFormatter.locale = .current
					let currentDate = dateFormatter.string(from: Date())
					defaults.set(currentDate, forKey: "updatesLastViewDate")
				}
		}
		
	}
	
	func showNewImage(_ date: String!) -> Bool {
		
		if updatesLastViewedDate != "" {
		
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "M/dd/yyyy H:m:ss"
			dateFormatter.locale = .current
			let datecomponents = dateFormatter.date(from: date)
			
			let lastViewed = dateFormatter.date(from: updatesLastViewedDate)
			
			if (datecomponents! > lastViewed!) {
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
		
		// Get labels from cell
		let subjectLabel = cell.viewWithTag(1) as! UILabel
		let dateLabel = cell.viewWithTag(2) as! UILabel
		let bodyLabel = cell.viewWithTag(3) as! UILabel
		let newImage = cell.viewWithTag(4) as! UIImageView
		
		// Set section label text with ward and section number
		subjectLabel.text = self.updatesList[indexPath.row].subject
		dateLabel.text = "\(self.updatesList[indexPath.row].month)/\(self.updatesList[indexPath.row].day)/\(self.updatesList[indexPath.row].year) \(self.updatesList[indexPath.row].hour) \(self.updatesList[indexPath.row].ampm)"
		bodyLabel.text = self.updatesList[indexPath.row].body
		
		if self.updatesList[indexPath.row].showNewImage == false {
			newImage.isHidden = true
		}
		else {
			newImage.isHidden = false
		}
		
		return cell
	}

}
