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

public class DetailViewController: UIViewController {
    @IBOutlet weak var contentScrollView: UIView!
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var gameRating: UILabel!
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var gameReleaseDate: UILabel!
    @IBOutlet weak var gamePlaytime: UILabel!
    @IBOutlet weak var gamePlatforms: UILabel!
    @IBOutlet weak var gameGenre: UILabel!
    @IBOutlet weak var gameAbout: UILabel!
    @IBOutlet weak var indicatorLoading: UIActivityIndicatorView!
    @IBOutlet weak var websiteBarItem: UIBarButtonItem!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var errorView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    public var presenter: GamePresenter<GameUseCase, FavoriteUseCase>?
    public var gameId: Int?
    
    fileprivate var cancellables: Set<AnyCancellable> = []
    fileprivate var game: GameDomainModel?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter?.getGame(request: gameId!)
        observeStatePresenter()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let height = gameAbout.bounds.height / 2
        scrollView.contentSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height+height
        )
    }
    
    @IBAction func goToWebsite(_ sender: Any) {
        if let game = presenter?.item {
            let url = URL(string: game.website)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @IBAction func saveToFavorite(_ sender: UIButton) {
        if let game = presenter?.item {
            if !game.favorite {
                sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                presenter?.updateFavoriteGame(request: game.id)
            } else {
                sender.setImage(UIImage(systemName: "heart"), for: .normal)
                presenter?.updateFavoriteGame(request: game.id)
            }
        }
    }
}

extension DetailViewController {
    public typealias GameUseCase = Interactor<
        Int,
        GameDomainModel,
        GetGameRepository<
            GetGameLocaleDataSource,
            GetGameRemoteDataSource,
            GameTransformer
        >
    >
    
    public typealias FavoriteUseCase = Interactor<
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
                if error {
                    self?.errorView.isHidden = false
                } else {
                    self?.errorView.isHidden = true
                }
            }.store(in: &cancellables)
            
            presenter.$item.sink { [weak self] result in
                guard result != nil else { return }
                
                self?.game = result
                self?.setupView()
            }.store(in: &cancellables)
        }
    }
    
    fileprivate func setupView() {
        if let game {
            let sourceImage = URL(string: game.imagePath)
            let playTime = "\(game.playtime) Hours"
            let iconName = game.favorite ? "heart.fill" : "heart"
            let platforms = game.platforms.joined(separator: ", ")
            let genres = game.genres.joined(separator: ", ")
            
            gameImageView.kf.setImage(with: sourceImage)
            gameImageView.kf.indicatorType = .activity
            gameName.text = game.name
            gameReleaseDate.text = game.released
            gamePlaytime.text = playTime
            gameRating.text = String(game.rating)
            gamePlatforms.text = platforms
            gameGenre.text = genres
            gameAbout.text = game.description
            favoriteButton.setImage(UIImage(systemName: iconName), for: .normal)
        }
    }
}
