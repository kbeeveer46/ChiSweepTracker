import UIKit
import StoreKit

class Info2ViewController: UIViewController {

	// Controls
	@IBOutlet weak var rateCardView: CardView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
       
		// Set title
		self.tabBarController?.navigationItem.title = "Sweeping Info"
		
		// Clear top navigation items
		self.tabBarController?.navigationItem.leftBarButtonItem = nil
		self.tabBarController?.navigationItem.rightBarButtonItem = nil
		
		// Add rate card view tap gesture
		let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.rateCardTapped (_:)))
		rateCardView.addGestureRecognizer(gesture)
    }
    

	@objc func rateCardTapped(_ sender:UITapGestureRecognizer){
		
		if #available(iOS 10.3, *) {
			SKStoreReviewController.requestReview()
		} else {
			// Fallback on earlier versions
		}
		
	}

}
