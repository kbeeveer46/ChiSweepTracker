import UIKit
import StoreKit
import Firebase

class InfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	// Controls
	@IBOutlet weak var infoTableView: UITableView!
	
	// Classes
	let common = Common()
	
	// Shared
	var infoList = [InfoModel]()
	
	override func viewDidLoad() {
        super.viewDidLoad()
       
		// Set title
		self.tabBarController?.navigationItem.title = "Sweeping Info"
		
		// Clear top navigation items
		self.tabBarController?.navigationItem.leftBarButtonItem = nil
		self.tabBarController?.navigationItem.rightBarButtonItem = nil
		
		// Add rate card view tap gesture
		//let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.rateCardTapped (_:)))
		//rateCardView.addGestureRecognizer(gesture)
		
		//initializeControlsPerDevice()
		
		getInfo()
		
		
    }
	
//	func initializeControlsPerDevice() {
		
//		switch UIDevice().type {
//		case .iPhoneSE:
//			
//		default:
//			break
//		}
		
//	}
    
	func getInfo() {
		
		let db = Firestore.firestore()
		
		// Get updates data
		db.collection(self.common.constants.infoDatabaseName)
			.order(by: "order")
			.getDocuments() { (querySnapshot, err) in
				if let err = err {
					print("Could not get info from Firebase: \(err)")
				} else {
					
					self.infoList.removeAll()
					
					for document in querySnapshot!.documents {
						
						let data = document.data()
						
						let message = data["message"] as! String
						let color = data["color"] as! String
						let image = data["image"] as! String
						let order = data["order"] as! Int
						
						let info = InfoModel()
						info.message = message
						info.color = color
						info.image = image
						info.order = order
						self.infoList.append(info)
						
					}
					
					// Set required properties for table view
					self.infoTableView.backgroundColor = UIColor(hexString: "#f2f2f2")
					self.infoTableView.separatorColor = UIColor(white: 0.95, alpha: 1)
					self.infoTableView.dataSource = self
					self.infoTableView.delegate = self
					self.infoTableView.reloadData()
					
				}
		}
	}

	@objc func rateCardTapped(_ sender:UITapGestureRecognizer){
		
		if #available(iOS 10.3, *) {
			SKStoreReviewController.requestReview()
		} else {
			// Fallback on earlier versions
		}
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return infoList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// Get cell from table view
		let cell = tableView.dequeueReusableCell(withIdentifier: "infoTableCell", for: indexPath)
		
		cell.contentView.backgroundColor =  UIColor(white: 0.95, alpha: 1)
		//cell.tintColor = UIColor(hexString: "#\(self.infoList[indexPath.row].color)")

		// Get label and image from cell
		let image = cell.viewWithTag(1) as! UIImageView
		let message = cell.viewWithTag(2) as! UILabel
		let cardView = cell.viewWithTag(3) as! CardView
		
		// Set label value
		message.text = self.infoList[indexPath.row].message
		
		// Set image source
		image.image = UIImage(named: self.infoList[indexPath.row].image)
		
		// Set card view background color
		cardView.backgroundColor =  UIColor(hexString: "#\(self.infoList[indexPath.row].color)")
		
		if self.infoList[indexPath.row].order == 1 {
		
			// Add rate card view tap gesture
			let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.rateCardTapped (_:)))
			cardView.addGestureRecognizer(gesture)
		}
		
		return cell
	}

}
