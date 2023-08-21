//
//  File.swift
//  
//
//  Created by Yoga Prasetyo on 19/08/23.
//

import Core

public struct GamesTransformer<
    GameMapper: Mapper
>: Mapper where
    GameMapper.Response == GameResponse,
    GameMapper.Entity == GameModuleEntity,
    GameMapper.Domain == GameDomainModel
{
    public typealias Response = [GameResponse]
    public typealias Entity = [GameModuleEntity]
    public typealias Domain = [GameDomainModel]
    
    private let gameMapper: GameMapper
    
    public init(gameMapper: GameMapper) {
        self.gameMapper = gameMapper
    }
    
    public func transformResponseToEntity(response: [GameResponse]) -> [GameModuleEntity] {
        return response.map { result in
            self.gameMapper.transformResponseToEntity(response: result)
        }
    }
    
    public func transformEntityToDomain(entity: [GameModuleEntity]) -> [GameDomainModel] {
        return entity.map { result in
            self.gameMapper.transformEntityToDomain(entity: result)
        }
    }
}
