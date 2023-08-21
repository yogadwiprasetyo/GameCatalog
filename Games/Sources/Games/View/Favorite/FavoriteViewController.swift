//
//  File.swift
//  
//
//  Created by Yoga Prasetyo on 21/08/23.
//

import UIKit
import Kingfisher
import Combine
import Core

public class FavoriteViewController: UIViewController {
    @IBOutlet weak var favoriteTableView: UITableView!
    @IBOutlet weak var indicatorLoading: UIActivityIndicatorView!
    @IBOutlet weak var emptyView: UIStackView!
    @IBOutlet weak var emptyImage: UIImageView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    public var presenter: FavoriteGamePresenter<FavoriteInteractor, UpdateFavoriteInteractor>?
    
    private var cancellables: Set<AnyCancellable> = []
    fileprivate var games: [GameDomainModel] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        observeStatePresenter()
    }
    
    fileprivate func setupView() {
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        favoriteTableView.register(UINib(nibName: "GameTableViewCell", bundle: Bundle.module), forCellReuseIdentifier: "GameCell")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.getList(request: nil)
    }
}

extension FavoriteViewController {
    public typealias FavoriteInteractor = Interactor<
        Int,
        [GameDomainModel],
        GetFavoriteGameRepository<
            GetFavoriteGameLocaleDataSource,
            GamesTransformer<GameTransformer>
        >
    >
    
    public typealias UpdateFavoriteInteractor = Interactor<
        Int,
        GameDomainModel,
        UpdateFavoriteGameRepository<
            GetFavoriteGameLocaleDataSource,
            GameTransformer
        >
    >
    
    fileprivate func observeStatePresenter() {
        if let presenter {
            presenter.$isLoading.sink { [weak self] isWaiting in
                if isWaiting {
                    self?.indicatorLoading.startAnimating()
                } else {
                    self?.indicatorLoading.stopAnimating()
                }
            }.store(in: &cancellables)

            presenter.$isError.sink { [weak self] error in
                self?.showErrorView(status: error)
            }.store(in: &cancellables)

            presenter.$list.sink { [weak self] result in
                let isResultEmpty = result.isEmpty
                if isResultEmpty {
                    self?.showEmptyView(status: isResultEmpty)
                } else {
                    self?.showEmptyView(status: isResultEmpty)
                    self?.showErrorView(status: isResultEmpty)
                }
                
                self?.games = result
                self?.favoriteTableView.reloadData()
            }.store(in: &cancellables)
        }
    }

    fileprivate func showEmptyView(status: Bool) {
        emptyImage.image = UIImage(named: "emptyFavorite")
        emptyLabel.text = "Hmmm! Looks like you are haven't favorite games"
        emptyView.isHidden = !status
    }
    
    fileprivate func showErrorView(status: Bool) {
        emptyImage.image = UIImage(named: "error")
        emptyLabel.text = "Oops! Something wrong"
        emptyView.isHidden = !status
    }
}

extension FavoriteViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "GameCell",
            for: indexPath
        ) as? GameTableViewCell else {
            return UITableViewCell()
        }
        
        let game = games[indexPath.row]
        let sourceImage = URL(string: game.imagePath)
        
        cell.gameName.text = game.name
        cell.gameReleaseDate.text = game.released
        cell.gameRating.text = String(game.rating)
        cell.gameImage.kf.indicatorType = .activity
        cell.gameImage.kf.setImage(with: sourceImage)
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension FavoriteViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gameId = games[indexPath.row].id
        performSegue(withIdentifier: "moveToDetail", sender: gameId)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToDetail" {
            if let viewController = segue.destination as? DetailViewController {
                viewController.gameId = sender as? Int
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Unfavorite") { _, _, _ in
            let gameId = self.games[indexPath.row].id
            self.presenter?.updateFavoriteGame(request: gameId)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
