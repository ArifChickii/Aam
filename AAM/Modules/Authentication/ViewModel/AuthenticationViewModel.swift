//
//  AuthenticationViewModel.swift
//  AAM
//
//  Created by Arif ww on 05/08/2024.
//

import Foundation
import AuthenticationServices
import CryptoKit
import GoogleSignIn
import AVFoundation
import FirebaseCore
import FirebaseAuth
import NVActivityIndicatorView
import Firebase
import CryptoKit





class AuthenticationViewModel{
    var emailSocial = ""
    var cases = ""
    var pendingCredential : AuthCredential!
    var currentNonce: String?
    var uid = ""
    var userName = ""
    var userEmail = ""
    
    
    // Logout function with completion handler
    func logoutUser(completion: ((Result<Void, Error>) -> Void)? = nil) {
        do {
            try Auth.auth().signOut()
            print("User successfully logged out.")
            completion?(.success(()))
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            completion?(.failure(signOutError))
        }
    }
    
    

    
    
}



