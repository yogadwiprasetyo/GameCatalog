//
//  SwinjectInstantiatioin.swift
//  GameCatalog
//
//  Created by Yoga Prasetyo on 17/08/23.
//

import Foundation
import RealmSwift
import SwinjectStoryboard
import Games
import Core

extension SwinjectStoryboard {
    
    @objc class func setup() {
        let realm = try? Realm()
        
        defaultContainer.register(GetListPresenter.self) { _ in
            let locale = GetGameLocaleDataSource(realm: realm!)
            let remote = GetGamesRemoteDataSource(
                endpoint: Endpoints.Gets.games.url,
                apiKey: API.apiKey
            )
            let gameMapper = GameTransformer()
            let mapper = GamesTransformer(gameMapper: gameMapper)
            let repository = GetGamesRepository(
                localeDataSource: locale,
                remoteDataSource: remote,
                mapper: mapper
            )
            
            let interactor = Interactor(repository: repository)
            return GetListPresenter(useCase: interactor)
        }
                
        defaultContainer.register(GamePresenter.self) { _ in
            let gameLocale = GetGameLocaleDataSource(realm: realm!)
            let gameRemote = GetGameRemoteDataSource(
                endpoint: Endpoints.Gets.game.url,
                apiKey: API.apiKey
            )
            let gameMapper = GameTransformer()
            let gameRepository = GetGameRepository(
                locale: gameLocale,
                remote: gameRemote,
                mapper: gameMapper
            )
            
            let favLocale = GetFavoriteGameLocaleDataSource(realm: realm!)
            let favMapper = GameTransformer()
            let favRepository = UpdateFavoriteGameRepository(
                locale: favLocale,
                mapper: favMapper
            )
            
            let gameUseCase: Interactor<
                Int,
                GameDomainModel,
                GetGameRepository<
                    GetGameLocaleDataSource,
                    GetGameRemoteDataSource,
                    GameTransformer
                >
            > = Interactor(repository: gameRepository)
            
            let favoriteUseCase: Interactor<
                Int,
                GameDomainModel,
                UpdateFavoriteGameRepository<
                    GetFavoriteGameLocaleDataSource,
                    GameTransformer
                >
            > = Interactor(repository: favRepository)
            
            return GamePresenter(
                gameUseCase: gameUseCase,
                favoriteUseCase: favoriteUseCase
            )
        }
        
        defaultContainer.register(FavoriteGamePresenter.self) { _ in
            let locale = GetFavoriteGameLocaleDataSource(realm: realm!)
            
            let gameMapper = GameTransformer()
            let favoriteMapper = GamesTransformer(gameMapper: gameMapper)
            let favoriteRepository = GetFavoriteGameRepository(
                locale: locale,
                mapper: favoriteMapper
            )
            
            let updateMapper = GameTransformer()
            let updateRepository = UpdateFavoriteGameRepository(
                locale: locale,
                mapper: updateMapper
            )
            
            let favoriteUseCase: Interactor<
                Int,
                [GameDomainModel],
                GetFavoriteGameRepository<
                    GetFavoriteGameLocaleDataSource,
                    GamesTransformer<GameTransformer>
                >
            > = Interactor(repository: favoriteRepository)
            
            let updateUseCase: Interactor<
                Int,
                GameDomainModel,
                UpdateFavoriteGameRepository<
                    GetFavoriteGameLocaleDataSource,
                    GameTransformer
                >
            > = Interactor(repository: updateRepository)
            
            return FavoriteGamePresenter(
                favoriteUseCase: favoriteUseCase,
                updateFavoriteUseCase: updateUseCase
            )
        }
        
        defaultContainer.storyboardInitCompleted(HomeViewController.self) { resolver, controller in
            controller.presenter = resolver.resolve(GetListPresenter.self)!
        }

        defaultContainer.storyboardInitCompleted(FavoriteViewController.self) { resolver, controller in
            controller.presenter = resolver.resolve(FavoriteGamePresenter.self)!
        }

        defaultContainer.storyboardInitCompleted(DetailViewController.self) { resolver, controller in
            controller.presenter = resolver.resolve(GamePresenter.self)!
        }
    }
}
