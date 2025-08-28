//
//  ListCell.swift
//  MVVM
//
//  Created by LCH on 8/24/25.
//

import UIKit

final class ListCell: UICollectionViewCell {
    
    private(set) var currentData: Int?
    
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
    
    private func setImage(with data: Data?) {
        if let imageData = data {
            imageView.image = UIImage(data: imageData)
        } else {
            imageView.image = UIImage(resource: .default)
        }
    }
    
    func configure(with listData: ListData) {
        // TODO: loadingIndicator 관련 로직 추가 필요
        // loadingIndicator start, stop 관련 로직 작성 필요
        currentData = listData.id
        
        if currentData == listData.id {
            setImage(with: listData.imageData)
            stopLoading()
        }
    }
}
