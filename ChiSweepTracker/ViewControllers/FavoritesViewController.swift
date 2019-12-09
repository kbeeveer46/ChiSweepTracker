import UIKit
import CoreData

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var favoritesTableView: UITableView!
    
    
    var schedule = ScheduleModel()
    var favorites = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let notificationButton = UIBarButtonItem(image: UIImage(named: "bell_circle"),
        //                                         landscapeImagePhone: nil, style: .plain,
        //                                         target: self, action: #selector(loadNotificationView))
        //self.navigationItem.rightBarButtonItem = notificationButton
        //self.tabBarController?.navigationItem.rightBarButtonItem = notificationButton

        
        //self.navigationController!.title = "Favorites"
        //self.title = "Favorites"
        //self.tabBarController?.title = "Favorites"
        //self.tabBarController?.navigationItem.title = "Favorites"
        
        //getFavorites()
        //deleteData()
        
        self.favoritesTableView.delegate = self
        self.favoritesTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

              //self.favoritesTableView.reloadData()
        
        let notificationButton = UIBarButtonItem(image: UIImage(named: "bell_circle"),
                                                landscapeImagePhone: nil, style: .plain,
                                                target: self, action: #selector(loadNotificationView))
        
        self.tabBarController?.navigationItem.rightBarButtonItem = notificationButton
        self.tabBarController?.navigationItem.title = "Favorites"
        
        getFavorites()

        //self.favoritesTableView.delegate = self
        //self.favoritesTableView.dataSource = self
        
//          DispatchQueue.main.async {
//
//              self.favoritesTableView.reloadData()
//          }
        

    }
    
    func getFavorites() {
        
        favorites.removeAll()
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "address", ascending: true)]
        
        do {
            
            let result = try managedContext.fetch(fetchRequest)
            
            for data in result as! [NSManagedObject] {
                
                print("Favorite: \(data.value(forKey: "address") as! String)")
                favorites.append(data.value(forKey: "address") as! String)

                
                //self.favoritesTableView.reloadData()
                
                //favoritesTableView.delegate = self
                //favoritesTableView.dataSource = self
            }
            
            //self.favoritesTableView.reloadData()
            
//            if favorites.count == 0 {
//                favorites.append("You do not have any favorites")
//            }
            
        } catch {
            
            print("Could not retrieve favorites from Core Data")
        }
        
        //self.favoritesTableView.reloadData()
    }
    
//    func deleteData(){
//
//        //As we know that container is set up in the AppDelegates so we need to refer that container.
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//
//        //We need to create a context from this container
//        let managedContext = appDelegate.persistentContainer.viewContext
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
//        fetchRequest.predicate = NSPredicate(format: "address = %@", "address-5")
//
//        do
//        {
//            let test = try managedContext.fetch(fetchRequest)
//
//            let objectToDelete = test[0] as! NSManagedObject
//            managedContext.delete(objectToDelete)
//
//            do{
//                try managedContext.save()
//            }
//            catch
//            {
//                print(error)
//            }
//
//        }
//        catch
//        {
//            print(error)
//        }
//    }
    
    @objc func loadNotificationView() {
        
        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsViewController") as? NotificationsViewController {
            
            destinationViewController.schedule = self.schedule
            self.navigationController?.pushViewController(destinationViewController, animated: true)
            
        }
        
        //self.performSegue(withIdentifier: "notificationsSegue", sender: self)
    }
    
    @objc func removeFavorite(sender: UIButton) {
        
        let buttonTag = sender.tag
        let address = favorites[buttonTag]
        
        print("Favorite removed: \(address)")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        fetchRequest.predicate = NSPredicate(format: "address = %@", address)
        
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            
            do{
                try managedContext.save()
                
                //self.getFavorites()
                
                favorites.remove(at: buttonTag)
                
                self.favoritesTableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return favorites.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritesTableViewCell", for: indexPath)
        
        let label = cell.viewWithTag(1) as! UILabel
        
        //let star = cell.viewWithTag(2) as! UIButton
        
        if let star = cell.contentView.viewWithTag(2) as? UIButton {
            star.addTarget(self, action: #selector(removeFavorite(sender:)), for: .touchUpInside)
            star.tag = indexPath.row
        }
        
        label.text = favorites[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let address = favorites[indexPath.row]
        
        print("Selected favorite: \(address)")
        
    }
}
