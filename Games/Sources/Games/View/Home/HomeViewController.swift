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

public class HomeViewController: UIViewController {
    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var indicatorLoading: UIActivityIndicatorView!
    @IBOutlet weak var infoView: UIStackView!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    public var presenter: GetListPresenter<Any, GameDomainModel, GameInteractor>?
    
    private var cancellables: Set<AnyCancellable> = []
    fileprivate var games: [GameDomainModel] = []
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        observeStatePresenter()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.getList(request: nil)
    }
    
    fileprivate func setupView() {
        gameTableView.dataSource = self
        gameTableView.delegate = self
        
        gameTableView.register(UINib(nibName: "GameTableViewCell", bundle: Bundle.module), forCellReuseIdentifier: "GameCell")
    }
}

extension HomeViewController {
    public typealias GameInteractor = Interactor<
        Any,
        [GameDomainModel],
        GetGamesRepository<
            GetGameLocaleDataSource,
            GetGamesRemoteDataSource,
            GamesTransformer<GameTransformer>
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
                self?.gameTableView.reloadData()
            }.store(in: &cancellables)
        }
    }
    
    fileprivate func showEmptyView(status: Bool) {
        infoImageView.image = UIImage(named: "empty")
        infoLabel.text = "Sorry, no games is provided"
        infoView.isHidden = !status
    }
    
    fileprivate func showErrorView(status: Bool) {
        infoImageView.image = UIImage(named: "error")
        infoLabel.text = "Oops! Something wrong"
        infoView.isHidden = !status
    }
}

extension HomeViewController: UITableViewDataSource {
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
        cell.gameImage.kf.setImage(with: sourceImage)
        cell.gameImage.kf.indicatorType = .activity
        
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gameId = games[indexPath.row].id
        performSegue(withIdentifier: "moveToDetail", sender: gameId)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "moveToDetail" else { return }
        
        if let detailViewController = segue.destination as? DetailViewController {
            detailViewController.gameId = sender as? Int
        }
    }
}
