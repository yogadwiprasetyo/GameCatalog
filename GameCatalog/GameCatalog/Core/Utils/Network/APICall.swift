//
//  APICall.swift
//  GameCatalog
//
//  Created by Yoga Prasetyo on 15/08/23.
//

import Foundation

struct API {
    static var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else { return "" }
        
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
          return ""
        }
        
        return value
    }
    
    static let baseUrl = "https://api.rawg.io/api/games"
}

protocol Endpoint {
    var url: String { get }
}

enum Endpoints {
    enum Gets: Endpoint {
        case games, game
        
        public var url: String {
            switch self {
            case .games: return "\(API.baseUrl)"
            case .game: return "\(API.baseUrl)/"
            }
        }
    }
}
