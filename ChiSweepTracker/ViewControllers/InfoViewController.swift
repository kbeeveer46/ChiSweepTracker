import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var signsButton: UIButton!
    @IBOutlet weak var ticketButton: UIButton!
    
    let common = Common()
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.navigationItem.title = "Sweeping Info"
        
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil

        self.common.styleButton(infoButton, "sweeper", "007AFF")
        self.common.styleButton(signsButton, "warning", "FF7832")
        self.common.styleButton(ticketButton, "dollar_circle", "86A697")
    }

}
