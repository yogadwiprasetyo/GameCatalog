//
//  File.swift
//  
//
//  Created by Yoga Prasetyo on 19/08/23.
//

import Foundation
import Combine
import Alamofire
import Core

public struct GetGameRemoteDataSource: DataSource {
    
    public typealias Request = Int
    public typealias Response = GameResponse
    
    private let endpoint: String
    private let apiKey: String
    
    public init(endpoint: String, apiKey: String) {
        self.endpoint = endpoint
        self.apiKey = apiKey
    }
    
    public func execute(request: Int?) -> AnyPublisher<GameResponse, Error> {
        let apiKeyParam = ["key": apiKey]
        return Future<GameResponse, Error> { completion in
            if let url = URL(string: self.endpoint + String(request!)) {
                AF.request(url, parameters: apiKeyParam)
                    .validate()
                    .responseDecodable(of: GameResponse.self) { response in
                        switch response.result {
                        case .success(let value):
                            completion(.success(value))
                        case .failure:
                            completion(.failure(URLError.invalidResponse))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
}
