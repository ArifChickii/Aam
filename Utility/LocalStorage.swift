//
//  LocalStorage.swift
//  AAM
//
//  Created by Mac on 28/08/2024.
//

import Foundation
open class LocalStorage: NSObject {
    
    public static func isUserLogin() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.isUserLogin)
        
    }
    
    public static func setUserisLogin()  {
         UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isUserLogin)
        
    }
   

    
//    public static func getUserInfo() -> CustomerDetailObject? {
//        return UserDefaults.standard.getCustomObject(UserDefaultKeys.UserInfo)
//    }
    
    
    
//    public static func saveUserInfoObject(userInfo: CustomerDetailObject) {
//        UserDefaults.standard.setCustomObject(userInfo, forKey: UserDefaultKeys.UserInfo)
//        UserDefaults.standard.synchronize()
//    }
//    
//    public static func updateUserInfoObject(userInfo: CustomerDetailObject) {
//        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.UserInfo)
//        UserDefaults.standard.setCustomObject(userInfo, forKey: UserDefaultKeys.UserInfo)
//        UserDefaults.standard.synchronize()
//    }
    
//    public static func clearToken() {
//        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.AccessToken)
//        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.UserInfo)
//        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.secondsWhenReceivedToken)
//        UserDefaults.standard.synchronize()
//    }
    
    
}
