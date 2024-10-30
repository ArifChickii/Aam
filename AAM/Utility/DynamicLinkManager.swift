//
//  DynamicLinkManager.swift
//  AAM
//
//  Created by Arif on 28/10/2024.
//

import Foundation
import FirebaseDynamicLinks

class DynamicLinkManager {
    static let shared = DynamicLinkManager()
    private init() {}
    
    // Constants
    private struct Constants {
        static let domainURIPrefix = "https://chickiiaam.page.link"
        static let bundleID = "com.chickii-ventures.aam"
        static let baseURL = "https://chickiiaam.page.link"
    }
    
    // Handle dynamic link resolution and product ID extraction
    func handleDynamicLink(_ shortUrl: URL, completion: @escaping (String?) -> Void) {
        print("🔍 Resolving shortened URL: \(shortUrl.absoluteString)")
        
        DynamicLinks.dynamicLinks().handleUniversalLink(shortUrl) { dynamicLink, error in
            if let error = error {
                print("❌ Error resolving dynamic link: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let dynamicLink = dynamicLink,
                  let longUrl = dynamicLink.url else {
                print("❌ No URL found in dynamic link")
                completion(nil)
                return
            }
            
            print("✅ Resolved to long URL: \(longUrl.absoluteString)")
            
            // Extract product ID from the resolved URL
            if let productId = self.extractProductID(from: longUrl) {
                print("✅ Successfully extracted product ID: \(productId)")
                completion(productId)
            } else {
                print("❌ Could not extract product ID from resolved URL")
                completion(nil)
            }
        }
    }
    
    // Extract product ID from a resolved URL
    private func extractProductID(from url: URL) -> String? {
        print("🔍 Extracting product ID from resolved URL: \(url.absoluteString)")
        
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
    
    // Create dynamic link (unchanged)
    func createDynamicLink(for product: ProductInfo, completion: @escaping (URL?) -> Void) {
        guard let productID = product.id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("❌ Invalid product ID")
            completion(nil)
            return
        }
        
        // Create deep link URL with query parameter for better parsing
        let linkString = "\(Constants.baseURL)/product?id=\(productID)"
        guard let link = URL(string: linkString) else {
            print("❌ Invalid URL")
            completion(nil)
            return
        }
        
        guard let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: Constants.domainURIPrefix) else {
            print("❌ Failed to create DynamicLinkComponents")
            completion(nil)
            return
        }
        
        // iOS parameters
        linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: Constants.bundleID)
        
        // Social meta tags
        let socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        socialMetaTagParameters.title = product.title ?? "Check out this product"
        socialMetaTagParameters.descriptionText = product.description ?? "Price: \(product.price ?? "")"
        if let imageUrlString = product.images?.first,
           let imageUrl = URL(string: imageUrlString) {
            socialMetaTagParameters.imageURL = imageUrl
        }
        linkBuilder.socialMetaTagParameters = socialMetaTagParameters
        
        // Navigation info
        let navigationInfoParameters = DynamicLinkNavigationInfoParameters()
        navigationInfoParameters.isForcedRedirectEnabled = true
        linkBuilder.navigationInfoParameters = navigationInfoParameters
        
        // Analytics parameters
        linkBuilder.analyticsParameters = DynamicLinkGoogleAnalyticsParameters(
            source: "product_share",
            medium: "social",
            campaign: "product_sharing"
        )
        
        // Generate short link
        linkBuilder.shorten { shortURL, warnings, error in
            if let error = error {
                print("❌ Error creating dynamic link: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let warnings = warnings {
                warnings.forEach { print("⚠️ Dynamic Link Warning: \($0)") }
            }
            
            completion(shortURL)
        }
    }
}

