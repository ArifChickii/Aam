//
//  MerchantServices.swift
//  AAM
//
//  Created by Arif on 20/01/2025.
//

import Foundation
import Alamofire

class MerchantService {
    func addMerchant(email: String, country: String, businessType: String, companyName: String?, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(Constants.shared.baseUrl)add-merchant"
        let params: [String: Any] = [
            "email": email,
            "country": country,
            "business_type": businessType,
            "company_name": companyName ?? ""
        ]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseDecodable(of: AddMerchantResponse.self) { response in
                switch response.result {
                case .success(let merchantResponse):
                    // merchantResponse.account.id = "acct_abc123"
                    completion(.success(merchantResponse.account.id))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

struct AddMerchantResponse: Decodable {
    let message: String
    let account: MerchantAccount
}

struct MerchantAccount: Decodable {
    let id: String  // e.g. "acct_abc123"
}
