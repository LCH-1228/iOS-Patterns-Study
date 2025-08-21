//
//  PokemonDetailViewController.swift
//  MVC
//
//  Created by LCH on 8/18/25.
//

import UIKit

class PokemonDetailViewController: BaseViewController {
    private let rootView: PokemonDetailView
    private let id: Int
    private let networkManager = NetworkManager.shared
    private let imageCacheManager = ImageCacheManager.shared
    
    init(rootView: PokemonDetailView, id: Int) {
        self.rootView = rootView
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    private func setupUI() {
        view.addSubview(rootView)
        
        rootView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootView.topAnchor.constraint(equalTo: view.topAnchor),
            rootView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchData() {
        Task { @MainActor in
            do {
                let result = try await networkManager.fetchPokemonDetail(id: id)
                let pokemonData = PokemonDataFormatter.detailFormat(response: result)
                rootView.configure(with: pokemonData)
                
                if let cachedData = imageCacheManager.getImage(forKey: id) {
                    rootView.setImage(imageData: cachedData)
                } else {
                    if let imageData = try await networkManager.fetchImage(id: id) {
                        rootView.setImage(imageData: imageData)
                        imageCacheManager.setImage(imageData, forKey: id)
                    } else {
                        rootView.setDefaultImage()
                        showToast(message: "이미지가 없는 포켓몬 입니다.", opcity: 0.7)
                    }
                }
            } catch {
                showError(error: error)
            }
        }
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
