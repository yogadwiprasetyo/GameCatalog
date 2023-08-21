//
//  File.swift
//  
//
//  Created by Yoga Prasetyo on 19/08/23.
//

import Core

public struct GameTransformer: Mapper {
    
    public typealias Response = GameResponse
    public typealias Entity = GameModuleEntity
    public typealias Domain = GameDomainModel
    
    public init() {}
    
    public func transformResponseToEntity(response: GameResponse) -> GameModuleEntity {
        let platforms = response.platforms?.map { $0.platform.name }
        let genres = response.genres?.map { $0.name }
        
        let gameEntity = GameModuleEntity()
        gameEntity.id = response.id ?? 0
        gameEntity.playtime = response.playtime ?? 0
        gameEntity.rating = response.rating ?? 0.0
        gameEntity.name = response.name ?? ""
        gameEntity.desc = response.description ?? ""
        gameEntity.released = response.released ?? ""
        gameEntity.imagePath = response.imagePath ?? ""
        gameEntity.website = response.website ?? ""
        gameEntity.platforms.append(objectsIn: platforms ?? [])
        gameEntity.genres.append(objectsIn: genres ?? [])
        
        return gameEntity
    }
    
    public func transformEntityToDomain(entity: GameModuleEntity) -> GameDomainModel {
        return GameDomainModel(
            id: entity.id,
            name: entity.name,
            imagePath: entity.imagePath,
            released: entity.released,
            rating: entity.rating,
            website: entity.website,
            description: entity.desc,
            playtime: entity.playtime,
            platforms: Array(entity.platforms),
            genres: Array(entity.genres),
            favorite: entity.favorite
        )
    }
}
