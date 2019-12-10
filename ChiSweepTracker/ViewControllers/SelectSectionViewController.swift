import UIKit
import CoreLocation

class SelectSectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sectionTableView: UITableView!
    
    var schedule = ScheduleModel()
    let common = Common()
    var sections: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get all sections in ward so user can select a section before going to the schedule view
        getSections()
            
    }
    
    func getSchedule() {
        
        schedule.months.removeAll()
        
        let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
        
        let scheduleQuery = wardClient.query(dataset: self.common.constants.scheduleDataset)
            .filter("\(self.common.constants.ward) = '\(self.schedule.ward)' \(self.schedule.section != "" ? "AND \(self.common.constants.section) = '\(self.schedule.section)'" : "") ")
        
        scheduleQuery.get { res in
            switch res {
            case .dataset (let data):
                
                if data.count > 0 {
                    
                    for (_, item) in data.enumerated() {
                        
                        let monthName = item[self.common.constants.month_name] as? String ?? ""
                        let monthNumber = item[self.common.constants.month_number] as? String ?? ""
                        let dates = item[self.common.constants.dates] as? String ?? ""
                        let datesArray = dates.components(separatedBy: ",")
                        
                        print("Month name: \(monthName)")
                        print("Dates: \(datesArray)")
                        
                        let month = MonthModel()
                        month.name = monthName
                        month.number = monthNumber
                        
                        for day in datesArray {
                            
                            print("Date: \(day)")
                            
                            if !day.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                
                                let date = DateModel()
                                date.date = Int(day) ?? 0
                                
                                if !month.dates.contains(where: { $0.date == Int(day) ?? 0}) {
                                    month.dates.append(date)
                                }
                            }
                        }
                        
                        self.schedule.months.append(month)
                        
                    }
                
                    // Segue to schedule view now that schedule model is populated
                    self.performSegue(withIdentifier: "viewScheduleSegue", sender: self)
            
                }
            case .error (let err):
                
                self.common.showAlert(self.common.constants.errorTitle, (err as NSError).userInfo.debugDescription)
                
            }
        }
        
    }
    
    func getSections() {
        
        // Use Chicago data portal API to get sweep sections in a ward
        
        sections.removeAll()
        
        let ward = self.schedule.ward
        
        let wardClient = SODAClient(domain: self.common.constants.SODADomain, token: self.common.constants.SODAToken)
        
        let scheduleQuery = wardClient.query(dataset: self.common.constants.scheduleDataset)
            .filter("\(self.common.constants.ward) = '\(ward)'")
        
        scheduleQuery.get { res in
            switch res {
            case .dataset (let data):
                
                if data.count > 0 {
                    
                    for (_, item) in data.enumerated() {
                        
                        let section = item[self.common.constants.section] as? String ?? ""
                        
                        if !section.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            
                            if !self.sections.contains(where: { $0 == section}) {
                                 self.sections.append(section)
                            }
                        }
                    }
                    
                    self.sectionTableView.dataSource = self
                    self.sectionTableView.delegate = self
                    self.sectionTableView.reloadData()
                }
            case .error (let err):
                
                self.common.showAlert(self.common.constants.errorTitle, (err as NSError).userInfo.debugDescription)
            }
        }
        
    }
    
    // Section table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionTableCell", for: indexPath)
        let sectionLabel = cell.viewWithTag(1) as! UILabel
        sectionLabel.text = "Ward \(schedule.ward) - Section \(self.sections[indexPath.row])"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        
        self.schedule.section = sections[row]
        
        // Get schedule and go to schedule view when a user selects a section
        getSchedule()
        
    }
    
    // Pass schedule model to schedule view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let scheduleViewController = segue.destination as? ScheduleViewController {
            scheduleViewController.schedule = schedule
        }
    }
}
