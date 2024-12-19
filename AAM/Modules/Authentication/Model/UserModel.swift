//
//  UserModel.swift
//  AAM
//
//  Created by Arif on 19/12/2024.
//


import Foundation

struct UserModel: Codable {
    let uid: String
    let email: String
    var name: String?
    var bio: String?
    var country: String?
    var location: String?
    var profileImage: String?
    
    init(uid: String, email: String, name: String? = nil, bio: String? = nil, country: String? = nil, location: String? = nil, profileImage: String? = nil) {
        self.uid = uid
        self.email = email
        self.name = name
        self.bio = bio
        self.country = country
        self.location = location
        self.profileImage = profileImage
    }
}
