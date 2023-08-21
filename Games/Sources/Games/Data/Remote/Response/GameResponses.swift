//
//  File.swift
//  
//
//  Created by Yoga Prasetyo on 19/08/23.
//

import Foundation

public struct GamesResponse: Codable {
    let results: [GameResponse]
}

public struct GameResponse: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case id, name, released, website, rating, playtime, genres
        case imagePath = "background_image"
        case platforms = "parent_platforms"
        case description = "description_raw"
    }
    
    let id: Int?
    let name: String?
    let description: String?
    let released: String?
    let imagePath: String?
    let website: String?
    let rating: Double?
    let playtime: Int?
    let platforms: [ParentPlatform]?
    let genres: [Genre]?
    
}

public struct Genre: Codable {
    let name: String
}

public struct ParentPlatform: Codable {
    let platform: Platform
}

public struct Platform: Codable {
    let name: String
}
