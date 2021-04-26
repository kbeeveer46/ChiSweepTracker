import UIKit
import StoreKit
import Alamofire

class InfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	// Controls
	@IBOutlet weak var infoTableView: UITableView!
	
	// Classes
	let common = Common()
	
	// Shared
	var infoList = [InfoModel]()
	var rateCardView = CardView()
	var requestCardView = CardView()
	let generator = UISelectionFeedbackGenerator()
	
	override func viewWillAppear(_ animated: Bool) {
        
		// Set title
		self.tabBarController?.navigationItem.title = "Sweeping Info"
		
		// Clear top navigation items
		self.tabBarController?.navigationItem.leftBarButtonItem = nil
		self.tabBarController?.navigationItem.rightBarButtonItem = nil
		
        // Set required properties for table view
        self.infoTableView.separatorColor = UIColor(white: 0.95, alpha: 1)
        self.infoTableView.dataSource = self
        self.infoTableView.delegate = self
        
		getInfo()
        
    }
	
	func getInfo() {
        
        let urlTo = self.common.constants.websiteURL + "/get-info-data.php"
        let parameters = ["tableName": self.common.constants.infoDatabaseName]
        
        AF.request(urlTo, parameters: parameters).validate().responseJSON() { response in
            switch response.result {
            case .failure:
                print("Error getting info from database")
            case .success:
                if let value = response.data {
                    
                    let json = (try? JSONSerialization.jsonObject(with: value)) as! [[String: String]]
                    
                    self.infoList.removeAll()
                    
                    for info in json.enumerated() {
                        
                        let message = info.element["message"]
                        let color = info.element["color"]
                        let image = info.element["image"]
                        let title = info.element["title"]
                        
                        let info = InfoModel()
                        info.message = message!
                        info.color = color!
                        info.image = image!
                        info.title = title!
                        self.infoList.append(info)
                    }
                    
                    DispatchQueue.main.async {
                        self.infoTableView.reloadData()
                    }
                }
            }
        }
	}

	@objc func rateCardTapped(_ sender:UITapGestureRecognizer){
		
		if #available(iOS 10.3, *) {
			
			// Add haptic feedback
			generator.prepare()
			generator.selectionChanged()
			
			rateCardView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
			
			UIView.animate(withDuration: 1.0,
						   delay: 0,
						   usingSpringWithDamping: 1.0,
						   initialSpringVelocity: 2.0,
						   options: .allowUserInteraction,
						   animations: { [weak self] in
							self?.rateCardView.transform = .identity
				},
						   completion: { (_) -> Void in
							SKStoreReviewController.requestReview()
							
			})
			
		}
		else {
			// Fallback on earlier versions
		}
		
	}
	
	@objc func requestCardTapped(_ sender:UITapGestureRecognizer){
					
		// Add haptic feedback
		generator.prepare()
		generator.selectionChanged()
		
		requestCardView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
		
		UIView.animate(withDuration: 1.0,
					   delay: 0,
					   usingSpringWithDamping: 1.0,
					   initialSpringVelocity: 2.0,
					   options: .allowUserInteraction,
					   animations: { [weak self] in
						self?.requestCardView.transform = .identity
			},
					   completion: { (_) -> Void in
						
						let url = URL(string: "tel://311")
						UIApplication.shared.open(url!, options: [:], completionHandler:nil)
						
						
		})
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return infoList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// Get cell from table view
		let cell = tableView.dequeueReusableCell(withIdentifier: "infoTableCell", for: indexPath)
		
		// Set cell background color
		cell.contentView.backgroundColor = UIColor(hexString: self.common.constants.background)

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
		
        if self.infoList[indexPath.row].title == "Rate" {
		
			rateCardView = cardView
			
			// Add rate card view tap gesture
			let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.rateCardTapped (_:)))
			cardView.addGestureRecognizer(gesture)
		}
        else if self.infoList[indexPath.row].title == "Request" {
			
			requestCardView = cardView
			
			// Add rate card view tap gesture
			let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.requestCardTapped (_:)))
			cardView.addGestureRecognizer(gesture)
		}
		
		return cell
	}

}
