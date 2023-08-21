//
//  File.swift
//  
//
//  Created by Yoga Prasetyo on 19/08/23.
//

import Foundation
import Combine
import Core

public class FavoriteGamePresenter<
    FavoriteUseCase: UseCase,
    UpdateFavoriteUseCase: UseCase
> where
    FavoriteUseCase.Request == Int,
    FavoriteUseCase.Response == [GameDomainModel],
    UpdateFavoriteUseCase.Request == Int,
    UpdateFavoriteUseCase.Response == GameDomainModel
{
    
    private var cancellables: Set<AnyCancellable> = []
    private let favoriteUseCase: FavoriteUseCase
    private let updateFavoriteUseCase: UpdateFavoriteUseCase
    
    @Published public var list: [GameDomainModel] = []
    @Published public var errorMessage: String = ""
    @Published public var isLoading: Bool = false
    @Published public var isError: Bool = false
    
    public init(
        favoriteUseCase: FavoriteUseCase,
        updateFavoriteUseCase: UpdateFavoriteUseCase
    ) {
        self.favoriteUseCase = favoriteUseCase
        self.updateFavoriteUseCase = updateFavoriteUseCase
    }
    
    public func getList(request: FavoriteUseCase.Request?) {
        isLoading = true
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
                receiveValue: { list in
                    self.list = list
                }
            ).store(in: &cancellables)
    }
    
    public func updateFavoriteGame(request: UpdateFavoriteUseCase.Request?) {
        self.updateFavoriteUseCase.execute(request: request)
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
                    let index = self.list.firstIndex(where: { $0.id == item.id })
                    self.list.remove(at: index!)
                }
            ).store(in: &cancellables)
    }
}
