import IQKeyboardManagerSwift
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSSubscriptionObserver {
    
	// This line is required or the screen is black on iPhone 8
    var window: UIWindow?
	
	// Classes
    let common = Common()
    let defaults = Defaults()
    let database = Database()
    
    // Shared
    let userDefaults = UserDefaults(suiteName: "group.com.kylebeverforden.chisweeptracker.defaults")
    let userDefaultsOld = UserDefaults.standard
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
          
//        userDefaultsOld.set("123", forKey: "deviceUUID")
        
        // Testing code for when old users migrate to the new app with multiple addresses
//        defaults.set("750 N Dearborn St Chicago", forKey: "favoriteAddress")
//        defaults.set(true, forKey: "notificationsToggled")
//        defaults.set("1 Day Prior", forKey: "notificationWhen")
//        defaults.set(8, forKey: "notificationHour")
//        defaults.set(30, forKey: "notificationMinute")
        
        // Existing user with old defaults
        if !(self.userDefaultsOld.string(forKey: "deviceUUID") ?? "").isEmpty && self.defaults.deviceUUID().isEmpty {
            
            // Migrate old defaults to new defaults
            self.common.migrateOldUsersToUseNewDefaults()
        }
        
        // New user
        else if (self.userDefaultsOld.string(forKey: "deviceUUID") ?? "").isEmpty && self.defaults.deviceUUID().isEmpty {
            
            // Get UUID and save it to defaults so it can be used throughout the app and database
            userDefaults!.set(UUID().uuidString, forKey: "deviceUUID")
        }
        userDefaults!.synchronize()
        print("uuid: \(self.defaults.deviceUUID())")
        
        // Required for didReceive when mass notification is opened
		UNUserNotificationCenter.current().delegate = self
		
		// Initilize custom keyboard (it allows the keyboard to rise and not cover text boxes)
		IQKeyboardManager.shared.enable = true
        
        // Set up an action to take when a user opens a remote One Signal sweep notificaton (not from a mass send)
        let notificationOpenedBlock: OSNotificationOpenedBlock = { result in
            if let address = result.notification.additionalData?["address"] as? String {
                if (address.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
                    self.common.goToScheduleFromNotification(address)
                }
            }
        }
        
        // OneSignal initialization
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setNotificationOpenedHandler(notificationOpenedBlock)
        OneSignal.setAppId(common.constants.OneSignalAppId)
        OneSignal.add(self as OSSubscriptionObserver)
        OneSignal.setLogLevel(.LL_ERROR, visualLevel: .LL_NONE)
        
        // Request permission for notifications when app is first opened
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
                    
            if granted == false  {
                
                OneSignal.disablePush(true);
                DispatchQueue.main.async {
                    UIApplication.shared.unregisterForRemoteNotifications()
                }
            }
            else {
                
                OneSignal.disablePush(false);
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        // Get data from database tables and update notifications
        let gettingValuesFromDatabase = self.defaults.gettingValuesFromDatabase()
        if gettingValuesFromDatabase == false {
            self.database.getValuesFromDatabase(completion: { message in
                self.userDefaults!.setValue(false, forKey: "gettingValuesFromDatabase")
            })
        }
        
        return true
    }
    
    // This method will be called when the OneSignal notification subscription property changes.
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges) {
        
        if !stateChanges.from.isSubscribed && stateChanges.to.isSubscribed {
                        
            if let oneSignalDeviceStatus = OneSignal.getDeviceState() {
                
                // Set the playerId in defaults
                print("playerId: \(oneSignalDeviceStatus.userId ?? "")")
                self.userDefaults!.set(oneSignalDeviceStatus.userId, forKey: "notificationOneSignalPlayerId")
             
                // Update notifications so user has the latest notifications
                self.database.updateNotificationsAndSweepDayInDatabase()
            }
        }
        
        if stateChanges.from.isSubscribed && !stateChanges.to.isSubscribed {
            //print("Unsubscribed for OneSignal push notifications!")
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
		
		// Clear badge number when app opens
        application.applicationIconBadgeNumber = 0

        // This is needed when a user initially doesn't allow notifications but then goes into the settings and enables it and comes back to the app.
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if(settings.authorizationStatus == .authorized && self.defaults.notificationOneSignalPlayerId() == "") {
                OneSignal.disablePush(false)
            }
        }

		// Get data from database tables and update notifications
        let gettingValuesFromDatabase = self.defaults.gettingValuesFromDatabase()
        if gettingValuesFromDatabase == false {
            self.database.getValuesFromDatabase(completion: { message in
                self.userDefaults!.setValue(false, forKey: "gettingValuesFromDatabase")
            })
        }
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

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
		// This method runs when a notification is opened when the app is in the background and foreground
        // This method runs when clicking on a notification from OneSignal when sending mass notifications (not sweep notifications)
        
        //let userInfo = response.notification.request.content.userInfo
        //print(userInfo)
        
		// Clear badge number when app opens
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Send the user to the updates tab
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            if let navigationController = rootViewController as? UINavigationController {
                if let tabBarController = navigationController.viewControllers[0] as? UITabBarController {
                    tabBarController.selectedIndex = 3
                }
            }
        }
        
        completionHandler()
    }
}
