import UIKit
import UserNotifications
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    let defaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        application.registerForRemoteNotifications()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        getOfficialChicagoDataForCurrentYear()
        
        return true
    }
    
    func getOfficialChicagoDataForCurrentYear() {
        
        let db = Firestore.firestore()
        
        let year = Calendar.current.component(.year, from: Date())
        
        db.collection("Schedules").whereField("year", isEqualTo: year)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    self.defaults.set("eiv4-4c3n", forKey: "officialWardDataset")
                    self.defaults.set("k737-xg34", forKey: "officialScheduleDataset")
                    self.defaults.set("coordinates", forKey: "officialCoordinatesTitle")
                    self.defaults.set("dates", forKey: "officialDatesTitle")
                    self.defaults.set("the_geom", forKey: "officialGeomTitle")
                    self.defaults.set("month_name", forKey: "officialMonthNameTitle")
                    self.defaults.set("month_number", forKey: "officialMonthNumberTitle")
                    self.defaults.set("ward", forKey: "officialWardTitle")
                    self.defaults.set("section", forKey: "officialSectionTitle")
                } else {
                    for document in querySnapshot!.documents {
                        //print("\(document.documentID) => \(document.data())")
                        self.defaults.set(document.data()["wardDataset"]!, forKey: "officialWardDataset")
                        self.defaults.set(document.data()["scheduleDataset"]!, forKey: "officialScheduleDataset")
                        self.defaults.set(document.data()["coordinatesTitle"]!, forKey: "officialCoordinatesTitle")
                        self.defaults.set(document.data()["datesTitle"]!, forKey: "officialDatesTitle")
                        self.defaults.set(document.data()["geomTitle"]!, forKey: "officialGeomTitle")
                        self.defaults.set(document.data()["monthNameTitle"]!, forKey: "officialMonthNameTitle")
                        self.defaults.set(document.data()["monthNumberTitle"]!, forKey: "officialMonthNumberTitle")
                        self.defaults.set(document.data()["wardTitle"]!, forKey: "officialWardTitle")
                        self.defaults.set(document.data()["sectionTitle"]!, forKey: "officialSectionTitle") 
                    }
                }
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        //if let messageID = userInfo[gcmMessageIDKey] {
        //print("Message ID: \(messageID)")
        //}
        
        // Print full message.
        //print(userInfo)
        
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        //if let messageID = userInfo[gcmMessageIDKey] {
        //  print("Message ID: \(messageID)")
        //}
        
        // Print full message.
        //print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        //let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        
        //let token = tokenParts.joined()
        
        //print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("Failed to register: \(error)")
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
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        //if let messageID = userInfo[gcmMessageIDKey] {
        //print("Message ID: \(messageID)")
        //}
        
        // Print full message.
        //print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let userInfo = response.notification.request.content.userInfo
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        //print(userInfo)
        
        // TODO: Use the code below to send user to schedule page when opening notification
        //NotificationCenter.default.post(name: Notification.Name(rawValue: "sentFromNotification"), object: nil)
        
        // Not working!
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //        if  let conversationVC = storyboard.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController,
        //            let tabBarController = self.window?.rootViewController as? UITabBarController,
        //            let navController = tabBarController.selectedViewController as? UINavigationController {
        //
        //                // we can modify variable of the new view controller using notification data
        //                // (eg: title of notification)
        //                conversationVC.sentFromNotification = true
        //                // you can access custom data of the push notification by using userInfo property
        //                // response.notification.request.content.userInfo
        //                navController.pushViewController(conversationVC, animated: true)
        //        }
        
        //        if let navController = self.navigationController, let viewController = storyboard.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController{
        //            navController.pushViewController(viewController, animated: true)
        //        }
        
        //        if let destinationViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
        //            destinationViewController.sentFromNotification = true
        //
        //            let navigationController = application.windows[0].rootViewController as! UINavigationController
        //
        //            navigationController!.pushViewController(destinationViewController, animated: true)
        //        }
        
        completionHandler()
        
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String) {
        
        //print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
        print("Message data: \(remoteMessage.appData)")
        
    }
    
}
