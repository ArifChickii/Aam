//
//  PaymentService.swift
//  AAM
//
//  Created by Arif on 21/01/2025.
//

import Foundation
import Alamofire

struct CreatePaymentIntentResponse: Decodable {
    let clientSecret: String
    let paymentIntentId: String
}

class PaymentService {
    func createPaymentIntent(amount: Int,
                             currency: String,
                             customerId: String,
                             merchantId: String,
                             paymentMethod: String?,
                             completion: @escaping (Result<CreatePaymentIntentResponse, Error>) -> Void) {
        let url = "\(Constants.shared.baseUrl)create-payment-intent"
        var params: [String: Any] = [
            "amount": amount,
            "currency": currency,
            "customerId": customerId,
            "merchantId": merchantId,
            
        ]
        if let pm = paymentMethod, !pm.isEmpty {
            params["paymentMethod"] = pm
        }
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
          .responseString { response in
              switch response.result {
              case .success(let stringData):
                  print("Raw server response: \(stringData)")
              case .failure(let error):
                  print("Request failed with error: \(error)")
              }
          }
        
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseDecodable(of: CreatePaymentIntentResponse.self) { response in
                switch response.result {
                case .success(let createPaymentIntentResponse):
                    completion(.success(createPaymentIntentResponse))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
