import UIKit
import Firebase

class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	// Controls
	@IBOutlet weak var newsTableView: UITableView!
	
	// Classes
	let common = Common()
	
	// Shared
	var newsList = [NewsModel]()
	
    override func viewWillAppear(_ animated: Bool) {

		// Set title
		self.tabBarController?.navigationItem.title = "Sweeping News"
		
		// Clear top navigation items
		self.tabBarController?.navigationItem.leftBarButtonItem = nil
		self.tabBarController?.navigationItem.rightBarButtonItem = nil
		
		let db = Firestore.firestore()
		
		// Get schedule data
		db.collection(self.common.constants.newsDatabaseName)
			.order(by: "date", descending: true)
			.limit(to: 5)
			.getDocuments() { (querySnapshot, err) in
				if let err = err {
					print("Could not get news from Firebase: \(err)")
				} else {
					for document in querySnapshot!.documents {
						
						let data = document.data()
						
						let subject = data["subject"] as! String
						let body = data["body"] as! String
						let date = data["date"] as! Timestamp
						let day = Calendar.current.component(.day, from: date.dateValue())
						let month = Calendar.current.component(.month, from: date.dateValue())
						let year = Calendar.current.component(.year, from: date.dateValue())
						
						//print(day)
						//print(month)
						//print(year)
						//print(subject)
						//print(body)
						
						let news = NewsModel()
						news.body = body
						news.subject = subject
						news.year = year
						news.month = month
						news.day = day
						self.newsList.append(news)
					}
					
					// Set required properties for table view
					self.newsTableView.dataSource = self
					self.newsTableView.delegate = self
					self.newsTableView.reloadData()
				}
		}
    }

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return newsList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// Get cell from table view
		let cell = tableView.dequeueReusableCell(withIdentifier: "newsTableCell", for: indexPath)
		
		// Get labels from cell
		let subjectLabel = cell.viewWithTag(1) as! UILabel
		let dateLabel = cell.viewWithTag(2) as! UILabel
		let bodyLabel = cell.viewWithTag(3) as! UILabel
		
		// Set section label text with ward and section number
		subjectLabel.text = self.newsList[indexPath.row].subject
		dateLabel.text = "\(self.newsList[indexPath.row].month)/\(self.newsList[indexPath.row].day)/\(self.newsList[indexPath.row].year)"
		bodyLabel.text = self.newsList[indexPath.row].body
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		// Get schedule and go to schedule view when a user selects a section
		
		//let row = indexPath.row
		
		//self.schedule.section = sections[row]
		
		//getSchedule()
		
	}
}
