//
//  PokemonDetailView.swift
//  MVC
//
//  Created by LCH on 8/18/25.
//

import UIKit

class PokemonDetailView: UIView {
    
    let contentsBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .ColorSet.secondary
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let idAndNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .ColorSet.light
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .ColorSet.light
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let heightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .ColorSet.light
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let weightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .ColorSet.light
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .ColorSet.primary
        addSubview(contentsBackgroundView)
        contentsBackgroundView.addSubview(imageView)
        contentsBackgroundView.addSubview(idAndNameLabel)
        contentsBackgroundView.addSubview(typeLabel)
        contentsBackgroundView.addSubview(heightLabel)
        contentsBackgroundView.addSubview(weightLabel)
        
        NSLayoutConstraint.activate([
            contentsBackgroundView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 32),
            contentsBackgroundView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -32),
            contentsBackgroundView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            contentsBackgroundView.bottomAnchor.constraint(equalTo: weightLabel.bottomAnchor, constant: 20),
            
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentsBackgroundView.leadingAnchor,constant: 72),
            imageView.trailingAnchor.constraint(equalTo: contentsBackgroundView.trailingAnchor, constant: -72),
            imageView.topAnchor.constraint(equalTo: contentsBackgroundView.topAnchor, constant: 10),
            
            idAndNameLabel.leadingAnchor.constraint(equalTo: contentsBackgroundView.leadingAnchor, constant: 10),
            idAndNameLabel.trailingAnchor.constraint(equalTo: contentsBackgroundView.trailingAnchor, constant: -10),
            idAndNameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            
            typeLabel.leadingAnchor.constraint(equalTo: contentsBackgroundView.leadingAnchor),
            typeLabel.trailingAnchor.constraint(equalTo: contentsBackgroundView.trailingAnchor),
            typeLabel.topAnchor.constraint(equalTo: idAndNameLabel.bottomAnchor, constant: 10),
            
            heightLabel.leadingAnchor.constraint(equalTo: contentsBackgroundView.leadingAnchor),
            heightLabel.trailingAnchor.constraint(equalTo: contentsBackgroundView.trailingAnchor),
            heightLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 10),
            
            weightLabel.leadingAnchor.constraint(equalTo: contentsBackgroundView.leadingAnchor),
            weightLabel.trailingAnchor.constraint(equalTo: contentsBackgroundView.trailingAnchor),
            weightLabel.topAnchor.constraint(equalTo: heightLabel.bottomAnchor, constant: 10),
        ])
    }
    
    func configure(with data: PokemonDetailData) {
        let originalText = data.idAndName
        let formattedText = originalText.replacingOccurrences(of: " (", with: "\n(")
        idAndNameLabel.text = formattedText
        typeLabel.text = data.type
        heightLabel.text = data.height
        weightLabel.text = data.weight
    }
    
    func setImage(imageData: Data) {
        imageView.image = UIImage(data: imageData)
    }
    
    func setDefaultImage() {
        imageView.image = UIImage(resource: .default)
    }
}
