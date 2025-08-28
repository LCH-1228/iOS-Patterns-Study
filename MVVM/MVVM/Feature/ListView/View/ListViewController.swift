//
//  ListViewController.swift
//  MVVM
//
//  Created by LCH on 8/23/25.
//

import UIKit
import Combine

final class ListViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    private let viewModel: ListViewModel
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout.pokemonList)
    private var dataSource: UICollectionViewDiffableDataSource<Section, ListData>!
    private let scrollThreshold: CGFloat = 5
    private let fetchTriggeredSubject = PassthroughSubject<Void, Never>()
    private let itemSelectedSubject = PassthroughSubject<Int, Never>()
    private let isEndSubject = PassthroughSubject<Bool, Never>()
    private var cancellable = Set<AnyCancellable>()
    
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
        bind()
        fetchTriggeredSubject.send()
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
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ListCell.self), for: indexPath) as? ListCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: itemIdentifier)
            
            return cell
        })
    }
    
    private func bind() {
        let input = ListViewModel.Input(
            fetchTriggered: fetchTriggeredSubject.eraseToAnyPublisher(),
            itemSelected: itemSelectedSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input)
        
        output.listDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] listData in
                // TODO: loadingIndicator 관련 로직 구현 필요
                // ViewModel에서 방출하는 값 업데이트시 hash관련 충돌 발생 가능성 있을 수 있음
                self?.updateSnapshot(with: listData)
            }
            .store(in: &cancellable)
        
        output.isEndPublisher
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnd in
                self?.showToast(message: "끝?", opacity: 0.7)
            }
            .store(in: &cancellable)
        
        output.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &cancellable)
    }
    
    @MainActor
    private func updateSnapshot(with data: [ListData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ListData>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data, toSection: .main)
        
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
        guard let snapshot = dataSource?.snapshot() else { return }
        let listData = snapshot.itemIdentifiers
        guard indexPath.row < listData.count else { return }
        
        let selectedItem = listData[indexPath.row]
        itemSelectedSubject.send(selectedItem.id)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let scrollPosition = scrollView.contentOffset.y + scrollView.frame.size.height
        
        guard scrollPosition >= contentHeight + scrollThreshold else { return }
        
        fetchTriggeredSubject.send()
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
