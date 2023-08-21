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

public struct GetFavoriteGameLocaleDataSource: LocaleDataSource {
    
    public typealias Request = Int
    public typealias Response = GameModuleEntity
    private let realm: Realm
    
    public init(realm: Realm) {
        self.realm = realm
    }
    
    public func list(request: Request?) -> AnyPublisher<[GameModuleEntity], Error> {
        return Future<[GameModuleEntity], Error> { completion in
            let gameEntities = self.realm.objects(GameModuleEntity.self).where { $0.favorite }
            completion(.success(gameEntities.toArray(ofType: GameModuleEntity.self)))
        }.eraseToAnyPublisher()
    }
    
    // MARK: Use for update favorite state
    public func get(id: Int) -> AnyPublisher<GameModuleEntity, Error> {
        return Future<GameModuleEntity, Error> { completion in
            if let gameEntity = self.realm.object(ofType: GameModuleEntity.self, forPrimaryKey: id) {
                do {
                    try self.realm.write {
                        gameEntity.setValue(!gameEntity.favorite, forKey: "favorite")
                    }
                    completion(.success(gameEntity))
                } catch {
                    completion(.failure(DatabaseError.requestFailed))
                }
            } else {
                completion(.failure(DatabaseError.invalidInstance))
            }
        }.eraseToAnyPublisher()
    }
    
    public func add(entities: [GameModuleEntity]) -> AnyPublisher<Bool, Error> {
        fatalError()
    }
    
    public func update(id: Int, entity: GameModuleEntity) -> AnyPublisher<Bool, Error> {
        fatalError()
    }
}
