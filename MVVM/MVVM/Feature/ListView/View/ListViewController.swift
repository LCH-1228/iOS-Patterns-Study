//
//  ListViewController.swift
//  MVVM
//
//  Created by LCH on 8/23/25.
//

import UIKit

final class ListViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    private let viewModel: ListViewModel
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout.pokemonList)
    private var dataSource: UICollectionViewDiffableDataSource<Section, ListData>!
    private let scrollThreshold: CGFloat = 5
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .pokemonBall)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    init(viewModel: ListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        setupUI()
        fetchData()
    }
    
    private func setupUI() {
        view.backgroundColor = .ColorSet.primary
        
        view.addSubview(imageView)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureCollectionView() {
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: String(describing: ListCell.self))
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .ColorSet.secondary
        collectionView.delegate = self
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self else { return UICollectionViewCell() }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ListCell.self), for: indexPath) as? ListCell else {
                return UICollectionViewCell()
            }
            
            guard let id = itemIdentifier.id else { return cell }
            
            cell.configure(with: itemIdentifier)
            cell.startLoading()
            
            Task {
                do {
                    let imageData = try await self.viewModel.fetchImage(id: id)
                    guard cell.currentData == itemIdentifier else { return }
                    cell.setImage(imageData: imageData)
                } catch {
                    self.handleError(error)
                }
            }
            return cell
        })
    }
    
    private func fetchData() {
        Task {
            do {
                try await viewModel.fetchCellData()
                updateSnapshot()
            } catch {
                handleError(error)
            }
        }
    }
    
    @MainActor
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ListData>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.listData, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func handleError(_ error: Error) {
        switch error {
        case is URLError:
            return
            
        case let apiError as APIErrorProtocol:
            showToast(message: apiError.message, opacity: 0.7)
            
        default:
            debugPrint("Error:", error.localizedDescription)
        }
    }
}

extension ListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.listData[indexPath.row]
        // TODO: DetailView 구현후 관련 로직 추가 필요
        debugPrint(item)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let scrollPosition = scrollView.contentOffset.y + scrollView.frame.size.height
        
        guard scrollPosition >= contentHeight + scrollThreshold else { return }
        
        guard !viewModel.isEnd else {
            showToast(message: "페이지의 끝입니다.", opacity: 0.7)
            return
        }
        
        fetchData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath), let id = item.id else { return }
        viewModel.cancelImageFetch(id: id)
    }
}

private extension UICollectionViewCompositionalLayout {
    static var pokemonList: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1/3)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        section.interGroupSpacing = 8
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
