//
//  File.swift
//  
//
//  Created by Yoga Prasetyo on 19/08/23.
//

import Core
import Combine

public struct GetGamesRepository<
    GameLocaleDataSource: LocaleDataSource,
    RemoteDataSource: DataSource,
    Transformer: Mapper
>: Repository where
    GameLocaleDataSource.Response == GameModuleEntity,
    RemoteDataSource.Response == [GameResponse],
    Transformer.Response == [GameResponse],
    Transformer.Entity == [GameModuleEntity],
    Transformer.Domain == [GameDomainModel]
{
    public typealias Request = Any
    public typealias Response = [GameDomainModel]
    
    private let localeDataSource: GameLocaleDataSource
    private let remoteDataSource: RemoteDataSource
    private let mapper: Transformer
    
    public init(
        localeDataSource: GameLocaleDataSource,
        remoteDataSource: RemoteDataSource,
        mapper: Transformer
    ) {
        self.localeDataSource = localeDataSource
        self.remoteDataSource = remoteDataSource
        self.mapper = mapper
    }
    
    public func execute(request: Request?) -> AnyPublisher<[GameDomainModel], Error> {
        return self.localeDataSource.list(request: nil)
            .flatMap { result -> AnyPublisher<[GameDomainModel], Error> in
                if result.isEmpty {
                    return self.remoteDataSource.execute(request: nil)
                        .map { self.mapper.transformResponseToEntity(response: $0) }
                        .catch { _ in self.localeDataSource.list(request: nil) }
                        .flatMap { self.localeDataSource.add(entities: $0) }
                        .filter { $0 }
                        .flatMap { _ in self.localeDataSource.list(request: nil)
                                .map { self.mapper.transformEntityToDomain(entity: $0) }
                        }.eraseToAnyPublisher()
                } else {
                    return self.localeDataSource.list(request: nil)
                        .map { self.mapper.transformEntityToDomain(entity: $0) }
                        .eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
    }
}
