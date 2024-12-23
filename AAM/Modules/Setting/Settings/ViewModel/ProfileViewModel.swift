//
//  ProfileViewModel.swift
//  AAM
//
//  Created by Arif on 17/12/2024.
//

import Foundation

class ProfileViewModel {
    
    // MARK: - Properties
    var name: String = ""
    var email: String = ""
    var location: String = ""
    var country: String = ""
    var bio: String = ""
    var profileImageLink: String = ""
    // MARK: - FirebaseService (You can inject or directly instantiate)
    private let firebaseService = FirebaseService()
    
    /// Fetch user profile from Firebase and update local properties
    /// - Parameter completion: A completion handler with `Result<Void, Error>`
    func fetchUserProfile(completion: @escaping (Result<Void, Error>) -> Void) {
        // Ensure a user is logged in (use your own logic or Auth if needed)
        guard let uid = firebaseService.auth.currentUser?.uid else {
            let error = NSError(domain: "ProfileViewModel",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "No current user found"])
            completion(.failure(error))
            return
        }
        
        // Call FirebaseService method to fetch user info
        firebaseService.fetchUserInformation(uid: uid) { result in
            switch result {
            case .success(let userModel):
                // Update the viewModel’s properties
                self.name = userModel.name ?? ""
                self.email = userModel.email
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
}


