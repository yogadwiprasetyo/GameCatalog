//
//  File.swift
//  
//
//  Created by Yoga Prasetyo on 19/08/23.
//

import Foundation

public struct GameDomainModel: Equatable, Identifiable {
    public let id: Int
    public let name: String
    public let imagePath: String
    public let released: String
    public let rating: Double
    public var website: String = ""
    public var description: String = ""
    public var playtime: Int = 0
    public var platforms: [String] = []
    public var genres: [String] = []
    public var favorite: Bool = false
}
