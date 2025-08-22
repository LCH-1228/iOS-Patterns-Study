//
//  PokemonListCell.swift
//  MVC
//
//  Created by LCH on 8/18/25.
//

import UIKit

final class PokemonListCell: UICollectionViewCell {
    
    private(set) var currentData: PokemonListData?
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .ColorSet.imageBackgroundLight
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        currentData = nil
        loadingIndicator.stopAnimating()
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .ColorSet.secondary
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            loadingIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: contentView.topAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func startLoading() {
        imageView.image = nil
        loadingIndicator.startAnimating()
    }
    
    func stopLoading() {
        loadingIndicator.stopAnimating()
    }
    
    func configure(with data: PokemonListData) {
        currentData = data
    }
    
    func setImage(imageData: Data) {
        imageView.image = UIImage(data: imageData)
        stopLoading()
    }
    
    func setDefaultImage() {
        imageView.image = UIImage(resource: .default)
        stopLoading()
    }
}
