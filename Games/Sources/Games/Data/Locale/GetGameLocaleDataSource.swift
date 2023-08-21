//
//  File.swift
//  
//
//  Created by Yoga Prasetyo on 19/08/23.
//

import Foundation
import Combine
import RealmSwift
import Core

public struct GetGameLocaleDataSource: LocaleDataSource {
    
    public typealias Request = Any
    public typealias Response = GameModuleEntity
    
    private let realm: Realm
    
    public init(realm: Realm) {
        self.realm = realm
    }
    
    public func list(request: Request?) -> AnyPublisher<[GameModuleEntity], Error> {
        return Future<[GameModuleEntity], Error> { completion in
            let game: Results<GameModuleEntity> = {
                self.realm.objects(GameModuleEntity.self)
            }()
            completion(.success(game.toArray(ofType: GameModuleEntity.self)))
        }.eraseToAnyPublisher()
    }
    
    public func add(entities: [GameModuleEntity]) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { completion in
            do {
                try self.realm.write {
                    for game in entities {
                        self.realm.add(game, update: .all)
                    }
                    completion(.success(true))
                }
            } catch {
                completion(.failure(DatabaseError.requestFailed))
            }
        }.eraseToAnyPublisher()
    }
    
    public func get(id: Int) -> AnyPublisher<GameModuleEntity, Error> {
        return Future<GameModuleEntity, Error> { completion in
            let game: GameModuleEntity? = self.realm.object(ofType: GameModuleEntity.self, forPrimaryKey: id)
            
            guard let game else {
                completion(.failure(DatabaseError.requestFailed))
                return
            }
            
            completion(.success(game))
        }.eraseToAnyPublisher()
    }
    
    public func update(id: Int, entity: GameModuleEntity) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { completion in
            if let gameEntity = self.realm.object(ofType: GameModuleEntity.self, forPrimaryKey: id) {
                do {
                    try self.realm.write {
                        gameEntity.setValue(entity.desc, forKey: "desc")
                        gameEntity.setValue(entity.website, forKey: "website")
                        gameEntity.setValue(entity.playtime, forKey: "playtime")
                        gameEntity.setValue(entity.platforms, forKey: "platforms")
                        gameEntity.setValue(entity.genres, forKey: "genres")
                        gameEntity.setValue(entity.favorite, forKey: "favorite")
                    }
                    completion(.success(true))
                } catch {
                    completion(.failure(DatabaseError.requestFailed))
                }
            } else {
                completion(.failure(DatabaseError.invalidInstance))
            }
        }.eraseToAnyPublisher()
    }
}
