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
    
    public func styleButton(_ button: UIButton, _ image: String?,_ color: String?) {
        
        button.backgroundColor = .systemBlue
        if color != nil {
            button.backgroundColor = UIColor(hexString: "#\(color!)")
        }
        button.layer.cornerRadius = 7.0
        button.tintColor = .white
        
        if image != nil {
            button.leftImage(image: UIImage(named: image!)!, name: image)
        }
    }
    
    class Constants {
        
        let defaults = UserDefaults.standard
        
        // MARK: SODA
        
		let schedulesTable = "Schedules"
        let appVersion = "2019"
        let wardDataset = "jqxt-c6gd" // Use this dataset to find ward and section based off coordinates
        let scheduleDataset = "k737-xg34" // Use this dataset to find schedule based off ward and section
        let the_geom = "the_geom"
        let ward = "ward"
        let section = "section"
        let coordinates = "coordinates"
        let month_name = "month_name"
        let month_number = "month_number"
        let dates = "dates"
        
//        func wardDataset() -> String {
//            return self.defaults.string(forKey: "officialWardDataset") ?? ""
//        }
//        func scheduleDataset() -> String {
//            return self.defaults.string(forKey: "officialScheduleDataset") ?? ""
//        }
//        func the_geom() -> String {
//            return self.defaults.string(forKey: "geomTitle") ?? ""
//        }
//        func ward() -> String {
//            return self.defaults.string(forKey: "wardTitle") ?? ""
//        }
//        func section() -> String {
//            return self.defaults.string(forKey: "sectionTitle") ?? ""
//        }
//        func coordinates() -> String {
//            return self.defaults.string(forKey: "coordinatesTitle") ?? ""
//        }
//        func month_name() -> String {
//            return self.defaults.string(forKey: "monthNameTitle") ?? ""
//        }
//        func month_number() -> String {
//            return self.defaults.string(forKey: "monthNumberTitle") ?? ""
//        }
//        func dates() -> String {
//            return self.defaults.string(forKey: "datesTitle") ?? ""
//        }
        
        let SODAToken = "dM3SUsRUNwyTWQGy83lvBv4X3"
        let SODADomain = "data.cityofchicago.org"
        
        // MARK: Alerts
        
        let successTitle = "Success"
        let errorTitle = "Something went wrong..."
        let notFound = "Could not find sweep area. Address must reside in Chicago."

    }

}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

public extension UIButton {
    
    // Add image on left view
    func leftImage(image: UIImage, name: String?) {
        
        if name == "finished" || name == "new" {
            self.setImage(image, for: .normal)
        } else {
            self.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image.size.width)
    }
}

