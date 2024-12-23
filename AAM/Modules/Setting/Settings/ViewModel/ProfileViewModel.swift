//
//  ProfileViewModel.swift
//  AAM
//
//  Created by Arif on 17/12/2024.
//

import Foundation



class ProfileViewModel {
    
    // MARK: - Properties
    var uid: String = ""
    var name: String = ""
    var email: String = ""
    var location: String = ""
    var country: String = ""
    var bio:  String = ""
    
    /// Stores the user’s profile image URL from Firestore
    var profileImageLink: String = ""
    
     let firebaseService = FirebaseService()
    
    /// Fetch user profile from Firebase and update local properties
    func fetchUserProfile(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUID = firebaseService.auth.currentUser?.uid else {
            let error = NSError(domain: "ProfileViewModel",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "No current user found"])
            completion(.failure(error))
            return
        }
        
        firebaseService.fetchUserInformation(uid: currentUID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userModel):
                self.uid = userModel.uid
                self.name = userModel.name ?? ""
                self.email = userModel.email      // email is not updatable
                self.location = userModel.location ?? ""
                self.country = userModel.country ?? ""
                self.bio = userModel.bio ?? ""
                self.profileImageLink = userModel.profileImage ?? ""
                
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // NEW:
    /// Updates user profile in Firestore with new data
    /// - Parameters:
    ///   - newImageURL: The newly uploaded image URL (if image changed), else pass `nil`.
    ///   - completion: Returns Result<Void, Error>.
    func updateUserProfile(newImageURL: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        
        // If there's a new image URL, overwrite existing one
        if let newImageURL = newImageURL {
            profileImageLink = newImageURL
        }
        
        // Create a UserModel object with updated fields
        let updatedUser = UserModel(
            uid: uid,
            email: email,
            name: name,
            bio: bio,
            country: country,
            location: location,
            profileImage: profileImageLink
        )
        
        // Save to Firestore
        firebaseService.saveUserInformation(user: updatedUser) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}



