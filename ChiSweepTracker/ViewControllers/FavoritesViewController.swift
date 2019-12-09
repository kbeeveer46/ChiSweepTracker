import UIKit
import CoreData

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    var schedule = ScheduleModel()
    var favorites = Favorites()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let notificationButton = UIBarButtonItem(image: UIImage(named: "bell_circle"),
                                                 landscapeImagePhone: nil, style: .plain,
                                                 target: self, action: #selector(loadNotificationView))
        self.navigationItem.rightBarButtonItem = notificationButton
        
        //self.title = "Favorites"
        //self.tabBarController?.title = "Favorites"
        
        //retrieveData()
        //deleteData()
    }
    
    func retrieveData() {
            
            //As we know that container is set up in the AppDelegates so we need to refer that container.
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            //We need to create a context from this container
            let managedContext = appDelegate.persistentContainer.viewContext
            
            //Prepare the request of type NSFetchRequest  for the entity
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
            
    //        fetchRequest.fetchLimit = 1
    //        fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur")
    //        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "email", ascending: false)]
    //
            do {
                let result = try managedContext.fetch(fetchRequest)
                for data in result as! [NSManagedObject] {
                    print(data.value(forKey: "address") as! String)
                }
                
            } catch {
                
                print("Failed")
            }
        }
    
    func deleteData(){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        fetchRequest.predicate = NSPredicate(format: "address = %@", "address-5")
       
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            
            do{
                try managedContext.save()
            }
            catch
            {
                print(error)
            }
            
        }
        catch
        {
            print(error)
        }
    }
    
    @objc func loadNotificationView() {
        
        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsViewController") as? NotificationsViewController {
            
            destinationViewController.schedule = self.schedule
            self.navigationController?.pushViewController(destinationViewController, animated: true)
            
        }
        
        //self.performSegue(withIdentifier: "notificationsSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritesTableViewCell", for: indexPath)
            
        let label = cell.viewWithTag(1) as! UILabel
    
        label.text = "test"
        
        return cell
    }
}
