//
//  AppDelegate.swift
//  AAM
//
//  Created by Arif ww on 01/08/2024.
//

import UIKit
import CoreData
import FirebaseCore
import IQKeyboardManagerSwift
import GoogleSignIn
import StripePayments
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    // MARK: - UIApplicationDelegate Methods

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Ask for Notification Permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        // Set UNUserNotificationCenter delegate to self
        UNUserNotificationCenter.current().delegate = self
        
        // Set Messaging delegate to self
        Messaging.messaging().delegate = self
        
        // Configure IQKeyboardManager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true // or false

        // Test URL scheme registration (optional, for debugging)
        if let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] {
            for urlType in urlTypes {
                if let urlSchemes = urlType["CFBundleURLSchemes"] as? [String],
                   let scheme = urlSchemes.first {
                    print("✅ URL Scheme registered: \(scheme)")
                }
            }
        } else {
            print("❌ URL Scheme not found in Info.plist")
        }
        
        
        StripeAPI.defaultPublishableKey = "pk_live_51OjZjHEXNMgV91NeH5rdn7xnSXjQH96qXQ3j67X2hboUNIh2DSQoMZ0wINXdZ58slnSC9KlNKgm9teXa4jAWUoiy00b9kYn4pg"
        
        return true
    }
    
    // Handle URL schemes (e.g., Google Sign-In)
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle Google Sign-In
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        
        // Other URL handling if necessary
        return false
    }
    
    // MARK: - APNs Token Registration
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass device token to Messaging
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // MARK: - FCM Token Refresh
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("FCM Registration Token: \(fcmToken)")
        
        // Store it in Firestore
        let service = FirebaseService()
        service.updateUserFCMToken(fcmToken) { result in
            switch result {
            case .success():
                print("✅ FCM token updated in Firestore")
            case .failure(let err):
                print("❌ Failed to update FCM token: \(err.localizedDescription)")
            }
        }
    }

    
    // MARK: - Handle Notification when App is in Foreground
    // This method is called when a notification arrives while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification alert (banner), and play a sound
        completionHandler([.alert, .sound])
    }
    
    // MARK: - Respond to User Tapping on Notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Process the user’s action when tapping the notification
        completionHandler()
    }
    

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Handle scene session discard if necessary
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AAM")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("❌ Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("❌ Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

