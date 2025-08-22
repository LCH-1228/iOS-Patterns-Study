//
//  PokemonListCell.swift
//  MVC
//
//  Created by LCH on 8/18/25.
//

import UIKit

final class PokemonListCell: UICollectionViewCell {
    
    private(set) var currentData: PokemonListData?
    
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
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with data: PokemonListData) {
        currentData = data
    }
    
    func setImage(imageData: Data) {
        imageView.image = UIImage(data: imageData)
    }
    
    func setDefaultImage() {
        imageView.image = UIImage(resource: .default)
    }
}
