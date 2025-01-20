//
//  AuthenticationVC.swift
//  AAM
//
//  Created by Arif ww on 02/08/2024.
//



import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import NVActivityIndicatorView
import AuthenticationServices
import Firebase
import CryptoKit
import AVFoundation

class AuthenticationVC: UIViewController, Storyboarded {
    
    @IBOutlet weak var btnGoogle: UIButton!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var btnApple: UIButton!
    private let viewModel = AuthenticationViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func startPreviousLoginProcess() {
        switch viewModel.cases {
        case "google":
            self.showAlertForLinking(desc: Constants.shared.googleLinkingDesc)
        case "apple":
            self.showAlertForLinking(desc: Constants.shared.appleLinkingDesc)
        default:
            print("do nothing")
        }
    }
    
    func showAlertForLinking(desc: String) {
        Helper.showAlert(title: Constants.shared.linkingAlertTitle, msg: desc, vc: self) { indexx in
            if indexx == 0{
                print("")
            } else {
                self.loginWithPreviousProvider()
            }
        }
    }

    func loginWithPreviousProvider() {
        if !viewModel.cases.elementsEqual("") {
            if viewModel.cases.elementsEqual("google"){
                self.handleGoogleCase()
            } else if viewModel.cases.elementsEqual("apple"){
                // self.handleAppleCase() if needed
            }
        }
    }

    // MARK: - Google Sign-In Flow
    func handleGoogleCase(){
        self.logintoGoogle()
    }
    
    func logintoGoogle(){
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.activityIndicator.stopAnimating()
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            if error != nil {
                self.activityIndicator.stopAnimating()
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.activityIndicator.stopAnimating()
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            let googleMail = user.profile?.email ?? ""
            viewModel.emailSocial = googleMail
            
            Auth.auth().fetchSignInMethods(forEmail: googleMail) { (providers, err) in
                if err == nil {
                    if let providers = providers {
                        if providers.contains(GoogleAuthProviderID) {
                            if self.viewModel.cases.elementsEqual("google") {
                                self.linkTwoAccounts(pendCred: self.viewModel.pendingCredential, newCredential: credential)
                            } else {
                                self.authenticateGoogleWithFirebase(credential: credential, user: user)
                            }
                        } else if providers.contains(FacebookAuthProviderID) {
                            self.viewModel.cases = "facebook"
                            self.viewModel.pendingCredential = credential
                            self.startPreviousLoginProcess()
                        } else {
                            if !providers.isEmpty {
                                if #available(iOS 13, *){
                                    self.viewModel.cases = "apple"
                                    self.viewModel.pendingCredential = credential
                                    self.startPreviousLoginProcess()
                                } else {
                                    self.activityIndicator.stopAnimating()
                                    Helper.showAlert(title: "Error", msg: "Apple Sign up functionality not available in iOS less than 13", vc: self, completion: { _ in })
                                }
                            } else {
                                // No provider found, just authenticate normally
                                self.activityIndicator.stopAnimating()
                            }
                        }
                    } else {
                        // No providers found, proceed with normal auth
                        self.authenticateGoogleWithFirebase(credential: credential, user: user)
                    }
                } else {
                    // If error in fetching sign in methods
                    if self.viewModel.cases.elementsEqual("google") {
                        self.linkTwoAccounts(pendCred: self.viewModel.pendingCredential, newCredential: credential)
                    } else {
                        self.authenticateGoogleWithFirebase(credential: credential, user: user)
                    }
                }
            }
        }
    }

    func linkTwoAccounts(pendCred: AuthCredential, newCredential: AuthCredential){
        if viewModel.cases.elementsEqual("google") {
            Auth.auth().signIn(with: newCredential) { (authResult, err) in
                if err != nil {
                    self.activityIndicator.stopAnimating()
                    print("error in login with previous provider \(err?.localizedDescription ?? "")")
                } else {
                    Auth.auth().currentUser?.link(with: pendCred, completion: { (result, error) in
                        if let error = error {
                            self.activityIndicator.stopAnimating()
                            print("error in linking user \(error.localizedDescription)")
                        } else {
                            // User linked successfully
                            self.saveUserInfoAndRedirect()
                        }
                    })
                }
            }
        } else if viewModel.cases.elementsEqual("apple") {
            Auth.auth().signIn(with: newCredential) { (authResult, error) in
                if let error = error {
                    self.activityIndicator.stopAnimating()
                    print(error.localizedDescription)
                    return
                }
                Auth.auth().currentUser?.link(with: pendCred, completion: { (result, error) in
                    if let error = error {
                        self.activityIndicator.stopAnimating()
                        print("error in linking user \(error.localizedDescription)")
                    } else {
                        // User linked successfully
                        self.saveUserInfoAndRedirect()
                    }
                })
            }
        }
    }

    @IBAction func googleBtnAction(sender: UIButton){
        self.activityIndicator.startAnimating()
        if Reachability.isConnectedToNetwork() {
            viewModel.logoutUser(completion: nil)
            self.logintoGoogle()
        } else {
            self.activityIndicator.stopAnimating()
            Helper.shared.showToast(message: "Please connect to the internet and try again", vc: self)
        }
    }

    func  authenticateGoogleWithFirebase(credential: AuthCredential, user: GIDGoogleUser!){
        Auth.auth().signIn(with: credential) { [self] (authResult, error) in
            if let error = error {
                self.activityIndicator.stopAnimating()
                print(error.localizedDescription)
                return
            }
            
            print("user signINwithgoogle")
            guard let userInfo = user.profile else {
                self.activityIndicator.stopAnimating()
                return
            }

            // Update ViewModel info
            viewModel.userEmail = userInfo.email
            viewModel.userName = userInfo.givenName ?? ""
            if userInfo.hasImage {
                let pic = "\(userInfo.imageURL(withDimension: 100)!)"
                viewModel.profileImage = pic
            }

            self.saveUserInfoAndRedirect()
        }
    }

    // MARK: - After successful login or linking, save info and move to home
    private func saveUserInfoAndRedirect() {
        viewModel.saveUserInfoToFirebase { result in
            self.activityIndicator.stopAnimating()
            switch result {
            case .success():
                // 1) After we've successfully saved user info, ensure Stripe customer ID
                self.ensureStripeCustomerId()
                
                // 2) Continue with your usual flow
                Helper.shared.showToast(message: "Moving to home...", vc: self)
                LocalStorage.setUserisLogin()
                Router.setHomeAsRootVC()

            case .failure(let error):
                print("Failed to save user info: \(error.localizedDescription)")
                // Optionally still call `ensureStripeCustomerId()` or skip if user info is incomplete
                // For now, let's skip if we can't even save user info
                Helper.shared.showToast(message: "move to home", vc: self)
                LocalStorage.setUserisLogin()
                Router.setHomeAsRootVC()
            }
        }
    }

}

// MARK: - Apple Sign In Flow
extension AuthenticationVC {
    func handleAppleCase(){
        if #available(iOS 13.0, *) {
            self.openAppleFlow()
        } else {
            print("Apple Sign In not available for iOS < 13")
        }
    }

    @available(iOS 13.0, *)
    func openAppleFlow(){
        let request = self.createAppleIdRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    @available(iOS 13.0, *)
    @IBAction func appleSignUpAction(_ sender: UIButton){
        self.activityIndicator.startAnimating()
        if Reachability.isConnectedToNetwork(){
            viewModel.logoutUser(completion: nil)
            let request = self.createAppleIdRequest()
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            self.activityIndicator.stopAnimating()
            Helper.shared.showToast(message: "Please connect to the internet and try again", vc: self)
        }
    }

    @available(iOS 13.0, *)
    func createAppleIdRequest() -> ASAuthorizationAppleIDRequest{
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        let request = appleIdProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let nonce = self.randomNonceString()
        request.nonce = sha256(nonce)
        viewModel.currentNonce = nonce
        return request
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

extension AuthenticationVC: ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        var appleUserName = ""
        var apple_email = ""
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let fullName = appleIDCredential.fullName?.givenName ?? ""
            let email = appleIDCredential.email
            appleUserName = fullName
            apple_email = email ?? ""

            viewModel.userName = fullName
            viewModel.userEmail = email ?? ""

            guard let nonce = viewModel.currentNonce else {
                self.activityIndicator.stopAnimating()
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                self.activityIndicator.stopAnimating()
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.activityIndicator.stopAnimating()
                print("Unable to serialize token string")
                return
            }

            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)

            viewModel.emailSocial = "dummy"

            Auth.auth().fetchSignInMethods(forEmail: email ?? "static") { (providers, err) in
                if err == nil {
                    if let providers = providers {
                        if providers.contains(credential.provider) {
                            if self.viewModel.cases.elementsEqual("apple"){
                                self.linkTwoAccounts(pendCred: self.viewModel.pendingCredential, newCredential: credential)
                            } else {
                                self.authenticateAppleToFirebase(credential: credential)
                            }
                        } else {
                            if providers.contains(GoogleAuthProviderID) {
                                self.viewModel.cases = "google"
                                self.viewModel.pendingCredential = credential
                                self.startPreviousLoginProcess()
                            } else if providers.contains(FacebookAuthProviderID) {
                                self.viewModel.cases = "facebook"
                                self.viewModel.pendingCredential = credential
                                self.startPreviousLoginProcess()
                            }
                        }
                    } else {
                        if self.viewModel.cases.elementsEqual("apple"){
                            self.linkTwoAccounts(pendCred: self.viewModel.pendingCredential, newCredential: credential)
                        } else {
                            self.authenticateAppleToFirebase(credential: credential)
                        }
                    }
                } else {
                    print(err?.localizedDescription ?? "error")

                    if self.viewModel.cases.elementsEqual("apple"){
                        self.linkTwoAccounts(pendCred: self.viewModel.pendingCredential, newCredential: credential)
                    } else {
                        self.authenticateAppleToFirebase(credential: credential)
                    }
                }
            }
        }
    }

    func authenticateAppleToFirebase(credential: AuthCredential){
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                self.activityIndicator.stopAnimating()
                print(error.localizedDescription)
                return
            }
            
            // viewModel.userName and viewModel.userEmail already set
            // Apple doesn't always provide a profile image, so we won't set it here.
            
            self.saveUserInfoAndRedirect()
        }
    }

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.activityIndicator.stopAnimating()
        print("error in sign in with apple: \(error.localizedDescription)")
    }
}

extension AuthenticationVC: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
extension AuthenticationVC {
    
    /// Checks if the current Firebase user has a Stripe customer ID in Firestore.
    /// If not, it creates one and stores it in Firestore.
    func ensureStripeCustomerId() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user found.")
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(currentUser.uid)
        userRef.getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let stripeCustomerId = data["stripeCustomerId"] as? String,
               !stripeCustomerId.isEmpty {
                // Already have a Stripe customer ID
                print("Stripe customer ID exists: \(stripeCustomerId)")
            } else {
                // Need to create a new Stripe customer
                let email = currentUser.email ?? "no-email@example.com"
                let name = currentUser.displayName ?? "Unknown"

                let service = CustomerService()
                service.createCustomer(email: email, name: name) { result in
                    switch result {
                    case .success(let newCustId):
                        // Update Firestore with the new Stripe customer ID
                        userRef.updateData(["stripeCustomerId": newCustId]) { err in
                            if let err = err {
                                print("Failed to update Firestore with customer ID: \(err.localizedDescription)")
                            } else {
                                print("Created and stored new Stripe customer: \(newCustId)")
                            }
                        }
                    case .failure(let error):
                        print("Failed to create customer: \(error)")
                    }
                }
            }
        }
    }
}
