//
//  File.swift
//  
//
//  Created by Yoga Prasetyo on 19/08/23.
//

import Foundation
import Combine
import Core

public class GamePresenter<
    GameUseCase: UseCase,
    FavoriteUseCase: UseCase
> where
    GameUseCase.Request == Int,
    GameUseCase.Response == GameDomainModel,
    FavoriteUseCase.Request == Int,
    FavoriteUseCase.Response == GameDomainModel
{
    
    private var cancellables: Set<AnyCancellable> = []
    private let gameUseCase: GameUseCase
    private let favoriteUseCase: FavoriteUseCase
    
    @Published public var item: GameDomainModel?
    @Published public var errorMessage: String = ""
    @Published public var isLoading: Bool = false
    @Published public var isError: Bool = false
    
    public init(gameUseCase: GameUseCase, favoriteUseCase: FavoriteUseCase) {
        self.gameUseCase = gameUseCase
        self.favoriteUseCase = favoriteUseCase
    }
    
    public func getGame(request: GameUseCase.Request) {
        isLoading = true
        self.gameUseCase.execute(request: request)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.isError = true
                        self.isLoading = false
                    case .finished:
                        self.isLoading = false
                    }
                },
                receiveValue: { item in
                    self.item = item
                }
            ).store(in: &cancellables)
    }
    
    public func updateFavoriteGame(request: FavoriteUseCase.Request) {
        self.favoriteUseCase.execute(request: request)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.isError = true
                        self.isLoading = false
                    case .finished:
                        self.isLoading = false
                    }
                },
                receiveValue: { item in
                    self.item = item
                }
            ).store(in: &cancellables)
    }
}
