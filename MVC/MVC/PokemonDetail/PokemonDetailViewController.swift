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
        networkManager.fetchPokemonDetail(id: id) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let result):
                self.networkManager.fetchImage(id: id) { secondResponse in
                    let pokemonData = PokemonDetailData(
                        idAndName: "No.\(result.id)  \(PokemonName.translate(name: result.name))",
                        type: "타입: \(result.types[0].type.name.translatedType)",
                        height: "키: \(Float(result.height) / 10) m",
                        weight: "몸무게: \(Float(result.weight) / 10) kg")
                    
                    DispatchQueue.main.async {
                        self.rootView.configure(with: pokemonData)
                    }
                    
                    switch secondResponse {
                    case .success(let data):
                        DispatchQueue.main.async {
                            if let data {
                                self.rootView.setImage(imageData: data)
                            } else {
                                self.rootView.setDefaultImage()
                            }
                        }
                    case .failure(let error):
                        let networkError = error as? NetworkError
                        print(networkError)
                    }
                }
                
            case .failure(let error):
                let networkError = error as? NetworkError
                print(networkError)
            }
        }
    }
}
