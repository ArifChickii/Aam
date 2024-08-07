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

        // Do any additional setup after loading the view.
    }
    
    
    func startPreviousLoginProcess(){
        
        switch viewModel.cases {
        case "google":
            self.showAlertForLinking(desc: Constants.shared.googleLinkingDesc)
        case "apple":
            self.showAlertForLinking(desc: Constants.shared.appleLinkingDesc)
        default:
            print("do nothing")
        }
        
    }
    
    
    func showAlertForLinking(desc: String){
        Helper.showAlert(title: Constants.shared.linkingAlertTitle, msg: desc, vc: self) { indexx in
            if indexx == 0{
                print("")
            }else{
                self.loginWithPreviousProvider()
            }
        }
        
    }

    func loginWithPreviousProvider(){
        if !viewModel.cases.elementsEqual(""){
            if viewModel.cases.elementsEqual("google"){
                self.handleGoogleCase()
            }else if viewModel.cases.elementsEqual("apple"){
//                self.handleAppleCase()
            }
        }
    }
 

}

/// google part
extension AuthenticationVC{
    
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
              // ...
                self.activityIndicator.stopAnimating()
              return
            }
            
            

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
            
              self.activityIndicator.stopAnimating()
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            
            
            let googleMail = user.profile?.email ?? ""
            viewModel.emailSocial = googleMail
    //        second fetch Providers
            
      
            Auth.auth().fetchSignInMethods(forEmail: googleMail) { (providers, err) in
                if err == nil{
                    
                    if providers != nil{
                        
                    
                    
                    if (providers?.contains(GoogleAuthProviderID))!{
                        

                        if self.viewModel.cases.elementsEqual("google") {
                            self.linkTwoAccounts(pendCred: self.viewModel.pendingCredential, newCredential: credential)

                        }else{
                            self.authenticateGoogleWithFirebase(credential: credential, user: user)
                        }
                    }else if (providers?.contains(FacebookAuthProviderID))!{
                        print("link faceBook")
                        viewModel.cases = "facebook"
                        viewModel.pendingCredential = credential
                        self.startPreviousLoginProcess()


                    }else {
                        if providers?.count != 0{
                            if #available(iOS 13, *){
                                viewModel.cases = "apple"
                                viewModel.pendingCredential = credential
                                self.startPreviousLoginProcess()

                            }else{
                                self.activityIndicator.stopAnimating()
                                Helper.showAlert(title: "Error", msg: "Apple Sign up functionality not available in less then ios 13", vc: self, completion: {indexx in
                                    
                                })
                            }
                            
                            
                           
                        }else{
                            self.activityIndicator.stopAnimating()
                            print("no provider found")
                        }



                    }
                    }else{
                        self.authenticateGoogleWithFirebase(credential: credential, user: user)
                    }
                }else{
                    print(err?.localizedDescription)

                    if viewModel.cases.elementsEqual("google") {
                        self.linkTwoAccounts(pendCred: viewModel.pendingCredential, newCredential: credential)
                       
                    }else{
                        self.authenticateGoogleWithFirebase(credential: credential, user: user)
                    }



                }
            }

     
        }

        
        

    }
    
    
    
    
    

    func linkTwoAccounts(pendCred: AuthCredential, newCredential: AuthCredential){
        if viewModel.cases.elementsEqual("google"){
            
            
            Auth.auth().signIn(with: newCredential) { (authResult, err) in
                if err != nil{
                    self.activityIndicator.stopAnimating()
                    print("error in login with previous provider \(err?.localizedDescription)")
                }else{
                    let currentUser = Auth.auth().currentUser?.displayName ?? ""
                    Auth.auth().currentUser?.link(with: pendCred, completion: { (result, error) in
                        if error == nil{
                            print(result)
                            print("user linked successfully")
                            
                            
                            let user = result?.user
                            
                            let useruid = Auth.auth().currentUser?.uid
                            
                            
//                            self.moveToHome()
                            self.activityIndicator.stopAnimating()
                            Helper.shared.showToast(message: "move to home", vc: self)

                            
                            
                        }else{
                            self.activityIndicator.stopAnimating()
                            print("error in linking user \(error?.localizedDescription ?? "")")
                        }
                    })
                }
            }
        }else if viewModel.cases.elementsEqual("apple"){
           
            Auth.auth().signIn(with: newCredential) { (authResult, error) in
              if (error != nil) {
                // Error. If error.code == .MissingOrInvalidNonce, make sure
                // you're sending the SHA256-hashed nonce as a hex string with
                // your request to Apple.
                  self.activityIndicator.stopAnimating()
                  
                  print(error!.localizedDescription)
                return
              }
              if let user = authResult?.user{
                  print("you are now signed in with userID \(user.uid) , email: \(user.email ?? "unknown")")
              
              // User is signed in to Firebase with Apple.
              // ...
              
              print("you are signed in to firebase using apple")
                
                Auth.auth().currentUser?.link(with: pendCred, completion: { (result, error) in
                    if error == nil{
                        print(result)
                        print("user linked successfully")
                        
                        
                        let user = result?.user
                        
                        let useruid = Auth.auth().currentUser?.uid
                        self.activityIndicator.stopAnimating()
                        Helper.shared.showToast(message: "move to home", vc: self)
//                        self.moveToHome()
                        
                        
                        
                        
                    }else{
                        self.activityIndicator.stopAnimating()
                        print("error in linking user \(error?.localizedDescription)")
                    }
                })
              }
              
            }

            
            
        }
    }
    
    @IBAction func googleBtnAction(sender: UIButton){
        
//        send event log
        self.activityIndicator.startAnimating()
       
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            viewModel.logoutUser()
            if let user = Auth.auth().currentUser{
                print("user exist")
            }else{
                print("userLogedOut")
            }
            
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                self.activityIndicator.stopAnimating()
                return
                
            }
            self.logintoGoogle()
           
        }else{
            self.activityIndicator.stopAnimating()
            Helper.shared.showToast(message: "Please connect to the internet and try again", vc: self)
            print("Internet Connection not Available!")
//            constant.shared.showNoInternetAlert(vc: self)
        }
        
   
    }
    //    authentication of google sign up with firebase
    
        func  authenticateGoogleWithFirebase(credential: AuthCredential, user: GIDGoogleUser!){
            
            
            Auth.auth().signIn(with: credential) { [self] (authResult, error) in
              if let error = error {
                  
                let authError = error as NSError
                print("erroer in sign in with google with firebase authentication")
            
                  // Other errors.
                  if error != nil {
                    // handle the error.
                      self.activityIndicator.stopAnimating()
                    print(error.localizedDescription)
//                    constant.shared.showAlert(title: "Error", msg: error.localizedDescription, vc: self)
                    return
                  }

                  // Sign in with the credential.
                  if credential != nil {
                    print(credential)

                  }
                

                // ...
                return
              }
                print("user signINwithgoogle")
              // User is signed in

                
                
                guard let userInfo = user.profile else {
                    self.activityIndicator.stopAnimating()
                    return
                    
                }
                var userImage = ""
                if user.profile!.hasImage
                {
                    let pic = "\(user.profile!.imageURL(withDimension: 100)!)"
                    print(pic)
                    
                    userImage = "\(pic)"
                }
                
                let uuid = Auth.auth().currentUser?.uid
                let name  = userInfo.givenName ?? ""
                let email = userInfo.email
                viewModel.userEmail = email
                viewModel.userName = name
                print(uuid!)
//                self.moveToHome()
                self.activityIndicator.stopAnimating()
                Helper.shared.showToast(message: "move to home", vc: self)
               
            }
        }
    
}


////apple part
extension AuthenticationVC{

    func handleAppleCase(){
        if #available(iOS 13.0, *) {

//            self.imgSocialAccountPrev.image = UIImage.init(named: "apple")
//            self.lblDetailPrevSocialAccount.text = "You have already created your account using email '\(self.emailSocial)'. Please enter password for the same email and continue to link your social media account."
            self.openAppleFlow()
        } else {
            // Fallback on earlier versions
            print("older version not supported in apple case")
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

        //        send event log

        self.activityIndicator.startAnimating()
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            viewModel.logoutUser()
            if let user = Auth.auth().currentUser{
                print("user exist")
            }else{
                print("userLogedOut")
            }

            let request = self.createAppleIdRequest()
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()

        }else{
            self.activityIndicator.stopAnimating()
            Helper.shared.showToast(message: "Please connect to the internet and try again", vc: self)
            print("Internet Connection not Available!")
//            constant.shared.showNoInternetAlert(vc: self)
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



    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
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
extension AuthenticationVC: ASAuthorizationControllerDelegate{


    @available(iOS 13.0, *)
      func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        var  appleUserName = ""
        var apple_email = ""
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {

            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName?.givenName ?? ""
            let email = appleIDCredential.email
            print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))")
            appleUserName =  "\(String(describing: fullName))"
            apple_email = String(describing: email)
            
            viewModel.userName = appleIDCredential.fullName?.givenName ?? ""
            viewModel.userEmail = appleIDCredential.email ?? ""
            
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
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
          }
          // Initialize a Firebase credential.
          let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                    idToken: idTokenString,
                                                    rawNonce: nonce)




            viewModel.emailSocial = "dummy"
//            fetch providers
//            if email exist, after i will be available for saving email to userdefaults then use it again
            Auth.auth().fetchSignInMethods(forEmail: email ?? "static") { (providers, err) in
                if err == nil{

                    if providers != nil{



                    if (providers?.contains(credential.provider))!{
                        if self.viewModel.cases.elementsEqual("apple"){
                            self.linkTwoAccounts(pendCred: self.viewModel.pendingCredential, newCredential: credential)
                        }else{
                            self.authenticateAppleToFirebase(credential: credential)
                        }
                    }else{

                          
                            if (providers?.contains(GoogleAuthProviderID))!{

                                self.viewModel.cases = "google"
                                self.viewModel.pendingCredential = credential
                                self.startPreviousLoginProcess()
                                
                             


                            }else if (providers?.contains(FacebookAuthProviderID))!{
                                print("link faceBook")
                                self.viewModel.cases = "facebook"
                                self.viewModel.pendingCredential = credential
                                self.startPreviousLoginProcess()


                            }
                        
                    }

                }else{
                    
                    if self.viewModel.cases.elementsEqual("apple"){
                        self.linkTwoAccounts(pendCred: self.viewModel.pendingCredential, newCredential: credential)
                    }else{
                        self.authenticateAppleToFirebase(credential: credential)
                    }
                    
                }

                }else{
                    print(err?.localizedDescription)

                    if self.viewModel.cases.elementsEqual("apple"){
                        self.linkTwoAccounts(pendCred: self.viewModel.pendingCredential, newCredential: credential)
                    }else{
                        self.authenticateAppleToFirebase(credential: credential)
                    }



                }
            }

        }
      }


    func authenticateAppleToFirebase(credential: AuthCredential){
        // Sign in with Firebase.
        Auth.auth().signIn(with: credential) { (authResult, error) in
          if (error != nil) {
            // Error. If error.code == .MissingOrInvalidNonce, make sure
            // you're sending the SHA256-hashed nonce as a hex string with
            // your request to Apple.

              self.activityIndicator.stopAnimating()
              print(error!.localizedDescription)
            return
          }
          if let user = authResult?.user{
              print("you are now signed in with userID \(user.uid) , email: \(user.email ?? "unknown")")

          // User is signed in to Firebase with Apple.
          // ...

          print("you are signed in to firebase using apple")
            
              self.viewModel.uid = Auth.auth().currentUser!.uid

              print("apple login successfully")
              self.activityIndicator.stopAnimating()
//              self.moveToHome()
//            self.handleUserForServerToLoginOrRegister(name: user.displayName ?? "", email:  user.email ?? "", phone: user.phoneNumber ?? "", uid:  self.uid, provider: "apple.com", meta_data: meta_data, userImg: "")


          }

        }
    }
//    func moveToHome(){
//        
//            Network.init().getUserProfileFromDatabase {
//                DispatchQueue.main.async {
//                    let User = DataManager.getUserProfile()
//                    if let user = User{
//                        DispatchQueue.main.async {
//                            Network.init().getDefaultKharchBook { idArray in
//                                guard var controllers = self.navigationController?.viewControllers else {
//                                    self.activityIndicator.stopAnimating()
//                                   return
//                                }
//                                DispatchQueue.main.async {
//                                    if idArray.count > 0 {
//                                        self.activityIndicator.stopAnimating()
//                                        let vc = homeVC.instantiateFromStoryboard("Home")
//                                        self.navigationController?.pushViewController(vc, animated: true)
//                                    }else{
//                                        self.activityIndicator.stopAnimating()
//                                        let vc1 = homeVC.instantiateFromStoryboard("Home")
//                                        let vc = CreateKBVC.instantiateFromStoryboard("Home")
//                                        controllers.append(vc1)
//                                        controllers.append(vc)
//                                        self.navigationController?.setViewControllers(controllers, animated: true)
//                                    }
//                                }
//                               
//                            }
//                        }
//                    }else{
//                        self.activityIndicator.stopAnimating()
//                        let vc = NameCurrencySelectionVC.instantiateFromStoryboard("UserProfile")
//                        vc.userName = self.userName
//                        vc.userEmail = self.userEmail
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
//                }
//            }
//        
//        
//        
//        
//        
//        
//        
//    }
    

//    func goNextFromNotificationPermissionsScreen(_ notification: Notification){
//        let idKb = DataManager.getSelectdBookId()
//        guard var controllers = self.navigationController?.viewControllers else {
//           return
//        }
//        if idKb == "" {
//            let vc1 = homeVC.instantiateFromStoryboard("Home")
//            let vc = CreateKBVC.instantiateFromStoryboard("Home")
//            controllers.append(vc1)
//            controllers.append(vc)
//            self.navigationController?.setViewControllers(controllers, animated: true)
//        }else{
//            let vc = homeVC.instantiateFromStoryboard("Home")
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        
//    }
    

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        self.activityIndicator.stopAnimating()
        print("error in sign in with apple: \(error.localizedDescription)")
    }
}
//
extension AuthenticationVC: ASAuthorizationControllerPresentationContextProviding{
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
    
}
