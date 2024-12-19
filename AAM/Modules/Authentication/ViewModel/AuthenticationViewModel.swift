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
import FirebaseAuth





class AuthenticationViewModel{
    var emailSocial = ""
    var cases = ""
    var pendingCredential : AuthCredential!
    var currentNonce: String?
    var uid = ""
    var userName = ""
    var userEmail = ""
    var bio: String?
        var country: String?
        var location: String?
        var profileImage: String?
    private let firebaseService = FirebaseService()
    
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
    
    

    func saveUserInfoToFirebase(completion: @escaping (Result<Void, Error>) -> Void) {
            guard let currentUser = Auth.auth().currentUser else {
                completion(.failure(NSError(domain: "Authentication", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])))
                return
            }
            
            // Construct the user model. Email is must, others if available
            let user = UserModel(uid: currentUser.uid,
                                 email: currentUser.email ?? self.userEmail,
                                 name: self.userName,
                                 bio: self.bio,
                                 country: self.country,
                                 location: self.location,
                                 profileImage: self.profileImage)
            
            firebaseService.saveUserInformation(user: user, completion: completion)
        }
    
}



