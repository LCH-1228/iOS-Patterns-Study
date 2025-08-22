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
    private let imageCacheManager = ImageCacheManager.shared
    private var dataSource: UICollectionViewDiffableDataSource<Section, PokemonListData>!
    
    private var pokemonList = [PokemonListData]()
    private var offset = 0
    private var isFetching = false
    private var scrollThreshold: CGFloat = 5.0
    private var fetchLimit = 20
    private var isEndData = false
    
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
        dataSource = UICollectionViewDiffableDataSource<Section, PokemonListData>(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            
            guard let self else { return UICollectionViewCell() }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PokemonListCell.self), for: indexPath) as? PokemonListCell else {
                return UICollectionViewCell()
            }
            
            guard let id = itemIdentifier.id else { return cell }
            
            cell.configure(with: itemIdentifier)
            cell.startLoading()
            if let cachedData = self.imageCacheManager.getImage(forKey: id) {
                cell.setImage(imageData: cachedData)
            } else {
                Task { @MainActor in
                    do {
                        let data = try await self.networkManager.fetchImage(id: id)
                        
                        guard cell.currentData == itemIdentifier else { return }
                        
                        if let imageData = data {
                            cell.setImage(imageData: imageData)
                            self.imageCacheManager.setImage(imageData, forKey: id)
                        } else {
                            cell.setDefaultImage()
                        }
                    } catch {
                        self.showError(error: error)
                    }
                }
            }
            return cell
        })
    }
    
    private func fetchData() {
        guard !isFetching else { return }
        isFetching = true
        
        Task { @MainActor in
            do {
                let result = try await networkManager.fetchPokemonList(offset: offset)
                pokemonList.append(contentsOf: result.results)
                updateSnapshot()
                isEndData = result.next == nil ? true : false
                
                Task.detached { [weak self] in
                    guard let self else { return }
                    await self.prefetchImages(for: result.results)
                }
            } catch {
                showError(error: error)
            }
            isFetching = false
        }
    }
    
    // MARK: - Prefetch Images
    // UX 개선을 위해 fetchPokemonList직 후 이미지를 imageCacheManager에 저장
    // 셀 에서 이미지 로딩 로직이 있으므로 예외처리 생략
    private func prefetchImages(for items: [PokemonListData]) async {
        for item in items {
            guard let id = item.id else { continue }
            
            if imageCacheManager.getImage(forKey: id) != nil { continue }
            
            do {
                if let data = try await networkManager.fetchImage(id: id) {
                    imageCacheManager.setImage(data, forKey: id)
                }
            } catch {
                
            }
        }
    }
    
    @MainActor
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PokemonListData>()
        snapshot.appendSections([.main])
        snapshot.appendItems(pokemonList, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @MainActor
    private func showError(error: Error) {
        let message: String
        if let networkError = error as? NetworkError {
            message = networkError.message
        } else {
            message = error.localizedDescription
        }
        showToast(message: message, opcity: 0.7)
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
        
        guard !isEndData else {
            showToast(message: "페이지의 끝입니다.", opcity: 0.7)
            return
        }
        
        offset += fetchLimit
        fetchData()
    }
}
