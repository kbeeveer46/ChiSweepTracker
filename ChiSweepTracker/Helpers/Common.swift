import UIKit

class Common {
    
    let constants = Constants()

    public func showAlert(_ title: String, _ message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        
        rootViewController?.present(alert, animated: true, completion: nil)
        
        return
        
    }
    
    public func styleButton(_ button: UIButton, _ image: String?) {
        
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 7.0
        button.tintColor = .white
        
        if image != nil {
            button.leftImage(image: UIImage(named: image!)!)
        }
    }
    
    class Constants {
        
        // MARK: SODA
        
        let wardDataset = "eiv4-4c3n"
        let scheduleDataset = "k737-xg34"
        
        let the_geom = "the_geom"
        let ward = "ward"
        let section = "section"
        let coordinates = "coordinates"
        let month_name = "month_name"
        let month_number = "month_number"
        let dates = "dates"
        
        let SODAToken = "dM3SUsRUNwyTWQGy83lvBv4X3"
        let SODADomain = "data.cityofchicago.org"
        
        // MARK: Alerts
        
        let successTitle = "Success"
        let errorTitle = "Something went wrong..."
        let notFound = "Could not find sweep area. Address must reside in Chicago."

    }

}

public extension UIButton {
    
    // Add image on left view
    func leftImage(image: UIImage) {
        self.setImage(image, for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image.size.width)
    }
}

