import UIKit
import UserNotifications
import Firebase
import FirebaseMessaging
import IQKeyboardManagerSwift
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSSubscriptionObserver {
    
	// This line is required or the screen is black on iPhone 8
    var window: UIWindow?
	
	// Required for Firebase remote notifications
    let gcmMessageIDKey = "gcm.message_id"
	
	// Classes
    let common = Common()
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            defaults.set(uuid, forKey: "deviceUUID")
        }
        
		// Configure Firebase
		FirebaseApp.configure()
		
		// Initialize Firebase Cloud Messaging
		Messaging.messaging().delegate = self
		UNUserNotificationCenter.current().delegate = self
		
		// Initilize custom keyboard (it allows the keyboard to rise and not cover text boxes)
		IQKeyboardManager.shared.enable = true
        
        // Set up an actin to take when a user opens a remote One Signal notification
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
        OneSignal.setAppId("2a6b2ed6-b4a7-4da0-8917-899cef558a0a")
        OneSignal.add(self as OSSubscriptionObserver)
        OneSignal.setLogLevel(.LL_ERROR, visualLevel: .LL_NONE)
        
        // This code is required for old users migrating to multiple address
        // Do not remove
        
//        defaults.set("750 N Dearborn St Chicago", forKey: "favoriteAddress")
//        defaults.set(true, forKey: "notificationsToggled")
//        defaults.set("1 Day Prior", forKey: "notificationWhen")
//        defaults.set(8, forKey: "notificationHour")
//        defaults.set(30, forKey: "notificationMinute")
        
        let favoriteAddress = self.common.favoriteAddress()
        
        if favoriteAddress != "" {
            
            // insert address into database
            self.common.insertAddressIntoDatabase(address: favoriteAddress,
                                                  notificationsEnabled: self.common.notificationsToggled() ? 1 : 0,
                                                  notificationsWhen: self.common.notificationWhen(),
                                                  notificationsHour: self.common.notificationHour(),
                                                  notificationsMinute: self.common.notificationMinute())
            
            self.common.updateNotifications()
            
            defaults.set("", forKey: "favoriteAddress")
        }
        
        // Request permission for notifications when app is first opened
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
                    
            if granted == false  {
                
                OneSignal.disablePush(true);
                print("OneSignal disabled")
                
                DispatchQueue.main.async {
                    // Unregister for Firebase Cloud Messaging and APN notifications
                    UIApplication.shared.unregisterForRemoteNotifications()
                }
                
            }
            else {
                
                OneSignal.disablePush(false);
                print("OneSignal enabled")
                
                DispatchQueue.main.async {
                    // Register for Firebase Cloud Messaging and APN notifications
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
            }
        }
        
        return true
    }
    
    // This method will be called when the notification subscription property changes.
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges) {
        
        if !stateChanges.from.isSubscribed && stateChanges.to.isSubscribed {
            
            print("Subscribed for OneSignal push notifications!")
            
            if let oneSignalDeviceStatus = OneSignal.getDeviceState() {
                
                print("playerId: \(oneSignalDeviceStatus.userId ?? "")")
                defaults.set(oneSignalDeviceStatus.userId, forKey: "notificationOneSignalPlayerId")
                
                self.common.updateNotifications()
            }
            
        }
        
        if stateChanges.from.isSubscribed && !stateChanges.to.isSubscribed {
            print("Unsubscribed for OneSignal push notifications!")
        }
    
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
		
		// Clear badge number when app opens
        application.applicationIconBadgeNumber = 0
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if(settings.authorizationStatus == .authorized && self.common.notificationOneSignalPlayerId() == "") {
                OneSignal.disablePush(false)
            }
        }
        
		// Get data from database tables and update notifications
		self.common.getDataFromDatabase(completion: { message in })

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
		//	print("Message ID: \(messageID)")
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
		//	print("Message ID: \(messageID)")
        //}
        
        // Print full message.
        //print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        		
		let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        
        let token = tokenParts.joined()
        
        print("didRegisterForRemoteNotificationsWithDeviceToken: \(token)")
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("didFailToRegisterForRemoteNotificationsWithError: \(error)")
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
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
		 // This method runs before the notification is presented on the screen when the app is in the foreground
		
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        //if let messageID = userInfo[gcmMessageIDKey] {
		//	print("Message ID: \(messageID)")
        //}
        
        // Print full message.
        //print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
		// This method runs when a notification is opened when the app is in the background and foreground
        // This method runs when clicking on a notification from Firebase and OneSignal
        
		// Clear badge number when app opens
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let userInfo = response.notification.request.content.userInfo
        
        // Print full message.
        //print(userInfo)
        
        // Send the user to the updates tab by default
		//if userInfo[gcmMessageIDKey] != nil {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
				if let navigationController = rootViewController as? UINavigationController {
					if let tabBarController = navigationController.viewControllers[0] as? UITabBarController {
						tabBarController.selectedIndex = 3
					}
				}
			}
        //}
		
        // If the clicks on a sweep notification then get the schedule and redirect them to the schedule page
		if let address = userInfo["address"] as? String {
			if (address.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
                self.common.goToScheduleFromNotification(address)
			}
		}
        
        completionHandler()
        
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
		// This method runs each time the app opens and whenever a new Firebase token is generated.
        // This token can be used to send test message in the Firebase console
		
        if fcmToken != nil {
        
            print("didReceiveRegistrationToken: \(fcmToken!)")
            
            let dataDict:[String: String] = ["token": fcmToken!]
            
            NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
            
        }
  
    }
}
