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
import FirebaseDynamicLinks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - UIApplicationDelegate Methods

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure IQKeyboardManager
        IQKeyboardManager.shared.enable = true
        
        // Test URL scheme registration
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
        
        // Handle any dynamic links that opened the app
        if let url = launchOptions?[.url] as? URL {
            handleIncomingDynamicLink(url)
        }
        
        return true
    }
    
    // Handle URL schemes (e.g., Google Sign-In, Firebase Dynamic Links)
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle Google Sign-In
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        
        // Handle Dynamic Links
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            return handleDynamicLink(dynamicLink)
        }
        
        return false
    }
    
    // Handle Universal Links
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Handle Universal Links
        if let incomingURL = userActivity.webpageURL {
            return handleIncomingDynamicLink(incomingURL)
        }
        return false
    }
    
    // MARK: - Dynamic Link Handling
    
    private func handleIncomingDynamicLink(_ url: URL) -> Bool {
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { [weak self] dynamicLink, error in
            guard error == nil else {
                print("❌ Error handling dynamic link: \(error!.localizedDescription)")
                return
            }
            
            if let dynamicLink = dynamicLink {
                self?.handleDynamicLink(dynamicLink)
            }
        }
        return handled
    }
    
    private func handleDynamicLink(_ dynamicLink: DynamicLink) -> Bool {
        guard let url = dynamicLink.url else { return false }
        print("🔗 Incoming dynamic link: \(url)")
        
        // Extract product ID from URL components
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let productId = components?.queryItems?.first(where: { $0.name == "id" })?.value else {
            print("❌ Product ID not found in dynamic link")
            return false
        }
        
        // Navigate to Product Detail
        navigateToProductDetail(withID: productId)
        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Handle any Dynamic Links that launched the app
        if let userActivity = options.userActivities.first,
           let incomingURL = userActivity.webpageURL {
            _ = handleIncomingDynamicLink(incomingURL)
        }
        
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // Release any resources specific to the discarded scenes here.
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

// MARK: - Deep Link Navigation Helper
extension AppDelegate {
    func navigateToProductDetail(withID productId: String) {
        // Get the main window's root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("❌ Unable to access root view controller")
            return
        }
        
        // Find the appropriate navigation controller
        let navigationController: UINavigationController? = {
            if let nav = rootViewController as? UINavigationController {
                return nav
            } else if let nav = rootViewController.navigationController {
                return nav
            } else {
                return nil
            }
        }()
        
        // Create and push the product detail view controller
        if let nav = navigationController {

            let productDetailVC = ProductDetailVC.instantiate(storyBoardName: "Home")
            
            // Fetch product data and set it
            FirebaseService().fetchProduct(withId: productId) { [weak productDetailVC] product in
                guard let product = product else {
                    print("❌ Product not found for ID: \(productId)")
                    return
                }
                
                DispatchQueue.main.async {
                    productDetailVC?.productDetailObj = product
                    productDetailVC?.viewModel = ProductDetailViewModel(product: product)
                    
                    // If the view is already loaded, refresh it
                    if productDetailVC?.isViewLoaded == true {
                        productDetailVC?.productTblView.reloadData()
                    }
                    
                    nav.pushViewController(productDetailVC!, animated: true)
                }
            }
        } else {
            print("❌ Navigation Controller not found")
        }
    }
}

