//
//  SceneDelegate.swift
//  AAM
//
//  Created by Arif ww on 01/08/2024.
//

import UIKit
import GoogleSignIn
import FirebaseDynamicLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // MARK: - UISceneDelegate Methods
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Initialize the window if it's not set in the storyboard
        if window == nil {
            window = UIWindow(windowScene: windowScene)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let initialVC = storyboard.instantiateInitialViewController() else {
                fatalError("❌ Unable to instantiate initial view controller.")
            }
            window?.rootViewController = initialVC
            window?.makeKeyAndVisible()
        }
        
        // Handle any deep links that launched the app
        if let userActivity = connectionOptions.userActivities.first {
            self.scene(scene, continue: userActivity)
        }
        
        // Handle any URL contexts that launched the app
        if let urlContext = connectionOptions.urlContexts.first {
            self.scene(scene, openURLContexts: Set([urlContext]))
        }
    }
    
    // Handle Universal Links
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let incomingURL = userActivity.webpageURL {
            print("🔗 Received universal link: \(incomingURL.absoluteString)")
            _ = handleDynamicLink(incomingURL)
        }
    }
    
    // Handle URL scheme links
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        // Handle Google Sign-In
        if url.scheme?.hasPrefix("com.googleusercontent.apps") == true {
            GIDSignIn.sharedInstance.handle(url)
            return
        }
        
        // Handle Dynamic Links
        print("🔗 Received URL scheme: \(url.absoluteString)")
        _ = handleDynamicLink(url)
    }
    
    // MARK: - Dynamic Link Handling
    
    private func handleDynamicLink(_ url: URL) -> Bool {
        print("🔗 Processing dynamic link: \(url.absoluteString)")
        
        DynamicLinks.dynamicLinks().handleUniversalLink(url) { [weak self] dynamicLink, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error handling dynamic link: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.presentErrorAlert(message: "Unable to open product link. Please try again.")
                }
                return
            }
            
            guard let dynamicLink = dynamicLink,
                  let longUrl = dynamicLink.url else {
                print("❌ No URL found in dynamic link")
                return
            }
            
            print("✅ Resolved to long URL: \(longUrl.absoluteString)")
            
            // Extract product ID from the resolved URL
            if let productId = self.extractProductID(from: longUrl) {
                print("✅ Successfully extracted product ID: \(productId)")
                DispatchQueue.main.async {
                    self.navigateToProductDetail(withID: productId)
                }
            } else {
                print("❌ Could not extract product ID from resolved URL")
                DispatchQueue.main.async {
                    self.presentErrorAlert(message: "Unable to find product information.")
                }
            }
        }
        
        return true
    }
    
    private func extractProductID(from url: URL) -> String? {
        print("🔍 Extracting product ID from URL: \(url.absoluteString)")
        
        // First try query parameters
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let productId = components.queryItems?.first(where: { $0.name == "id" })?.value {
            print("✅ Found product ID in query parameters: \(productId)")
            return productId
        }
        
        // Then try path components
        let pathComponents = url.pathComponents
        if pathComponents.contains("product"),
           let productIndex = pathComponents.firstIndex(of: "product"),
           productIndex + 1 < pathComponents.count {
            let productId = pathComponents[productIndex + 1]
            print("✅ Found product ID in path: \(productId)")
            return productId
        }
        
        print("❌ No product ID found in URL")
        return nil
    }
    
    /**
     Navigates to the ProductDetailVC with the provided product ID.
     
     - Parameter productId: The ID of the product to display.
     */
    // In SceneDelegate.swift, replace the navigateToProductDetail method with:

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
            
            // Push the view controller first
            nav.pushViewController(productDetailVC, animated: true)
            
            // Then load the product
            productDetailVC.loadProduct(withId: productId)
        } else {
            print("❌ Navigation Controller not found")
            presentErrorAlert(message: "Unable to display product details.")
        }
    }
    
    // MARK: - Error Handling
    
    private func presentErrorAlert(message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("❌ Unable to present error alert: no root view controller")
            return
        }
        
        let topVC = getTopViewController(from: rootViewController)
        let alert = UIAlertController(title: "Error",
                                    message: message,
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        topVC?.present(alert, animated: true)
    }
    
    private func getTopViewController(from rootViewController: UIViewController) -> UIViewController? {
        if let presented = rootViewController.presentedViewController {
            return getTopViewController(from: presented)
        }
        
        if let navigationController = rootViewController as? UINavigationController {
            return navigationController.visibleViewController
        }
        
        if let tabBarController = rootViewController as? UITabBarController,
           let selected = tabBarController.selectedViewController {
            return getTopViewController(from: selected)
        }
        
        return rootViewController
    }
    
    // MARK: - Additional Scene Lifecycle Methods
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
