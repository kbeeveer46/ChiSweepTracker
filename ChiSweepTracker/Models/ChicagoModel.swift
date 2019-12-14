//
//  ChicagoModel.swift
//  ChiSweepTracker
//
//  Created by Macbook on 12/13/19.
//  Copyright © 2019 Kyle Beverforden. All rights reserved.
//

import Foundation
import Firebase

class ChicagoModel {
    
    func scheduleDataset() -> String {
        
        let db = Firestore.firestore()
        var scheduleDataset = ""
        
        db.collection("Schedules")
            .order(by: "year", descending: true)
            .limit(to: 1)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    fatalError("Could not get data from Firebase: \(err)")
                } else {
                    for document in querySnapshot!.documents {

                        print(document.data()["scheduleDataset"]!)
                        scheduleDataset = document.data()["scheduleDataset"] as! String
                    }
                }
        }
        
        return scheduleDataset
    }
    
    func wardDataset() {
        
        
        
    }
    
    let the_geom = "the_geom"
    let ward = "ward"
    let section = "section"
    let coordinates = "coordinates"
    let month_name = "month_name"
    let month_number = "month_number"
    let dates = "dates"
    
}
