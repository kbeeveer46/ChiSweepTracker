//
//  Common.swift
//  ChiSweepTracker
//
//  Created by Macbook on 12/6/19.
//  Copyright © 2019 Kyle Beverforden. All rights reserved.
//

import UIKit

class Common {
    
    let constants = Constants()

    public func showError(_ error: String) {
        
        //self.errorMessage = errorMessage
        //self.performSegue(withIdentifier: "showErrorSegue", sender: self)
        
        let alert = UIAlertController(title: self.constants.errorTitle, message: error, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        alert.present(alert, animated: true)
        
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

}

public extension UIButton {
    
    // Add image on left view
    func leftImage(image: UIImage) {
        self.setImage(image, for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image.size.width)
    }
}
