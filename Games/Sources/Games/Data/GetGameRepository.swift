//
//  File.swift
//  
//
//  Created by Yoga Prasetyo on 19/08/23.
//

import Core
import Combine

public struct GetGameRepository<
    GameLocaleDataSource: LocaleDataSource,
    RemoteDataSource: DataSource,
    Transformer: Mapper
>: Repository where
    GameLocaleDataSource.Request == Any,
    GameLocaleDataSource.Response == GameModuleEntity,
    RemoteDataSource.Request == Int,
    RemoteDataSource.Response == GameResponse,
    Transformer.Response == GameResponse,
    Transformer.Entity == GameModuleEntity,
    Transformer.Domain == GameDomainModel
{
    
    public typealias Request = Int
    public typealias Response = GameDomainModel
    
    private let locale: GameLocaleDataSource
    private let remote: RemoteDataSource
    private let mapper: Transformer
    
    public init(
        locale: GameLocaleDataSource,
        remote: RemoteDataSource,
        mapper: Transformer
    ) {
        self.locale = locale
        self.remote = remote
        self.mapper = mapper
    }
    
    public func execute(request: Int?) -> AnyPublisher<GameDomainModel, Error> {
        guard let request = request else { fatalError("Request cannot be empty") }
        
        return self.locale.get(id: request)
            .flatMap { result -> AnyPublisher<GameDomainModel, Error> in
                if result.desc.isEmpty {
                    return self.remote.execute(request: request)
                        .map { self.mapper.transformResponseToEntity(response: $0) }
                        .catch { _ in self.locale.get(id: request) }
                        .flatMap { self.locale.update(id: request, entity: $0) }
                        .filter { $0 }
                        .flatMap { _ in self.locale.get(id: request)
                                .map { self.mapper.transformEntityToDomain(entity: $0) }
                        }.eraseToAnyPublisher()
                } else {
                    return self.locale.get(id: request)
                        .map { self.mapper.transformEntityToDomain(entity: $0) }
                        .eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
    }
}
