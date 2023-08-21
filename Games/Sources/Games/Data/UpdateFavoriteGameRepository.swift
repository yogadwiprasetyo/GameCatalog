//
//  File.swift
//  
//
//  Created by Yoga Prasetyo on 19/08/23.
//

import Core
import Combine

public struct UpdateFavoriteGameRepository<
    GameLocaleDataSource: LocaleDataSource,
    Transformer: Mapper
>: Repository where
    GameLocaleDataSource.Request == Int,
    GameLocaleDataSource.Response == GameModuleEntity,
    Transformer.Response == GameResponse,
    Transformer.Entity == GameModuleEntity,
    Transformer.Domain == GameDomainModel
{
    
    public typealias Request = Int
    public typealias Response = GameDomainModel
    
    private let locale: GameLocaleDataSource
    private let mapper: Transformer
    
    public init(locale: GameLocaleDataSource, mapper: Transformer) {
        self.locale = locale
        self.mapper = mapper
    }
    
    public func execute(request: Int?) -> AnyPublisher<GameDomainModel, Error> {
        return self.locale.get(id: request ?? 0)
            .map { self.mapper.transformEntityToDomain(entity: $0) }
            .eraseToAnyPublisher()
    }
}
