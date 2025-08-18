//
//  PokemonListViewController.swift
//  MVC
//
//  Created by LCH on 8/17/25.
//

import UIKit

final class PokemonListViewController: BaseViewController {
    
    enum Section {
        case main
    }
    
    private let rootView: PokemonListView
    private let networkManager = NetworkManager.shared
    private var dataSource: UICollectionViewDiffableDataSource<Section, PokemonListData>!
    
    private var pokemonList = [PokemonListData]()
    private var offset = 0
    private var isFetching = false
    private var scrollThreshold: CGFloat = 5.0
    private var fetchLimit = 20
    
    init(rootView: PokemonListView) {
        self.rootView = rootView
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureDataSource()
        fetchData()
    }
    
    private func setupUI() {
        navigationBarHidden = true
        rootView.setDelegate(self)
        
        view.addSubview(rootView)
        rootView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootView.topAnchor.constraint(equalTo: view.topAnchor),
            rootView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureDataSource() {
        let collectionView = rootView.getCollectionView()
        dataSource = UICollectionViewDiffableDataSource<Section, PokemonListData>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PokemonListCell.self), for: indexPath) as? PokemonListCell else {
                return UICollectionViewCell()
            }
            
            guard let id = itemIdentifier.id else { return cell }
            
            cell.configure(with: itemIdentifier)
            
            self.networkManager.fetchImage(id: id) { [weak cell] response in
                
                guard cell?.currentData == itemIdentifier else {
                    return
                }
                
                switch response {
                case .success(let data):
                    DispatchQueue.main.async {
                        if let data {
                            cell?.setImage(imageData: data)
                        } else {
                            cell?.setDefaultImage()
                        }
                    }
                case .failure(let error):
                    let networkError = error as? NetworkError
                    networkError?.message
                }
            }
            
            return cell
        })
    }
    
    private func fetchData() {
        guard !isFetching else { return }
        isFetching = true
        
        networkManager.fetchPokemonList(offset: offset) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let result):
                self.pokemonList.append(contentsOf: result.results)
                self.updateSnapshot()
            case .failure(let error):
                let networkError = error as? NetworkError
                print(networkError?.message)
            }
            
            self.isFetching = false
        }
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PokemonListData>()
        snapshot.appendSections([.main])
        snapshot.appendItems(pokemonList, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension PokemonListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = pokemonList[indexPath.row].id else { return }
        let pokemonDetailView = PokemonDetailView()
        let pokemonDetailViewController = PokemonDetailViewController(rootView: pokemonDetailView, id: id)
        navigationController?.pushViewController(pokemonDetailViewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let scrollPosition = scrollView.contentOffset.y + scrollView.frame.size.height
        
        guard scrollPosition >= contentHeight + scrollThreshold else { return }
        
        guard !isFetching else { return }
        
        offset += fetchLimit
        fetchData()
    }
}
