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
    
    
    func logoutUser() {
        // call from any screen
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
    }
    
    

    
    
}



