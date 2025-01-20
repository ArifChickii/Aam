//
//  CustomerService.swift
//  AAM
//
//  Created by Arif on 20/01/2025.
//

import Foundation
import Alamofire
class CustomerService {
    func createCustomer(email: String, name: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(Constants.shared.baseUrl)create-customer"
        let params: [String: Any] = ["email": email, "name": name]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseDecodable(of: CreateCustomerResponse.self) { response in
                switch response.result {
                case .success(let customerResponse):
                    completion(.success(customerResponse.customer.id))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

struct CreateCustomerResponse: Decodable {
    let message: String
    let customer: StripeCustomer
}

struct StripeCustomer: Decodable {
    let id: String
    let email: String
    let name: String?
}
