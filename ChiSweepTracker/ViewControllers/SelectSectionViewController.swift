import UIKit

class SelectSectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sectionTableView: UITableView!
    
    var schedule = Schedule()
    let constants = Constants()
    
    var sections: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getSections()
        
    }
    
    func getSections() {
        
        //sections.removeAll()
        
        let ward = self.schedule.ward
        
        let wardClient = SODAClient(domain: self.constants.SODADomain, token: self.constants.SODAToken)
        
        let scheduleQuery = wardClient.query(dataset: self.constants.scheduleDataset)
            .filter("ward = '\(ward)'")
        
        scheduleQuery.get { res in
            switch res {
            case .dataset (let data):
                
                if data.count > 0 {
                    
                    for (_, item) in data.enumerated() {
                        
                        let section = item["section"] as? String ?? ""
                        
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
                
                //self.showingError = true
                //self.errorMessage = (err as NSError).userInfo.debugDescription
                print((err as NSError).userInfo.debugDescription)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionTableCell", for: indexPath)
        
        let sectionLabel = cell.viewWithTag(1) as! UILabel
    
        sectionLabel.text = "Ward \(schedule.ward) Section \(self.sections[indexPath.row])"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        
        //print("Selected section: \(sections[row])")
        
        self.schedule.section = sections[row]
        
        self.performSegue(withIdentifier: "viewScheduleSegue", sender: self)
        //return
        
    }
    
    // Prepare segue and pass data to view controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let scheduleViewController = segue.destination as? ScheduleViewController {
            scheduleViewController.schedule = self.schedule
        }
    }
}
