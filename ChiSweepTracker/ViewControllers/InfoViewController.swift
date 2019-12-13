//
//  InfoViewController.swift
//  ChiSweepTracker
//
//  Created by Macbook on 12/12/19.
//  Copyright © 2019 Kyle Beverforden. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var signsButton: UIButton!
    @IBOutlet weak var ticketButton: UIButton!
    
    let common = Common()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.common.styleButton(infoButton, "sweeper", "007AFF")
        self.common.styleButton(signsButton, "warning", "FF7832")
        self.common.styleButton(ticketButton, "dollar_circle", "86A697")
        
    }

}
