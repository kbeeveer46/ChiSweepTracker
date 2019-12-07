import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        self.window = UIWindow()
//
//        let defaults = UserDefaults.standard
//        //let schedule = defaults.object(forKey: "defaultSchedule") as? Schedule ?? Schedule()
//        
//        guard let scheduleData = defaults.object(forKey: "defaultSchedule") as? Data else {
//            return true
//        }
//        
//        // Use NSKeyedUnarchiver to convert Data / NSData back to Player object
//        guard let schedule = NSKeyedUnarchiver.unarchiveObject(with: scheduleData) as? Schedule else {
//            return true
//        }
//
//        if !schedule.ward.isEmpty && !schedule.section.isEmpty {
//
//            let scheduleViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleViewController")
//            self.window?.rootViewController = scheduleViewController
//
//        }
//
//        self.window?.makeKeyAndVisible()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

