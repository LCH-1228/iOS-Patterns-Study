//
//  DetailViewController.swift
//  MVVM
//
//  Created by LCH on 8/26/25.
//

import UIKit

final class DetailViewController: UIViewController {
    private let viewModel: DetailViewModel
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private let contentsBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .ColorSet.secondary
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let idAndNameLabel: UILabel = {
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
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .ColorSet.light
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let heightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .ColorSet.light
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let weightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .ColorSet.light
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .ColorSet.primary
        loadingIndicator.color = .ColorSet.light
        view.addSubview(contentsBackgroundView)
        view.addSubview(loadingIndicator)
        
        contentsBackgroundView.addSubview(imageView)
        contentsBackgroundView.addSubview(idAndNameLabel)
        contentsBackgroundView.addSubview(typeLabel)
        contentsBackgroundView.addSubview(heightLabel)
        contentsBackgroundView.addSubview(weightLabel)
        
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentsBackgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            contentsBackgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            contentsBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
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
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadData() {
        startLoading()
        
        Task {
            async let detailData = viewModel.fetchDetail()
            async let imageData = viewModel.fetchImage()
            
            do {
                let detail = try await detailData
                let image = try await imageData
                Task { @MainActor in
                    configure(with: detail)
                    setImage(imageData: image)
                }
            } catch {
                Task{ @MainActor in
                    stopLoading()
                    handleError(error)
                }
            }
        }
    }
    
    private func startLoading() {
        loadingIndicator.startAnimating()
    }
    
    private func stopLoading() {
        loadingIndicator.stopAnimating()
        contentsBackgroundView.isHidden = false
    }
    
    private func configure(with data: DetailData) {
        let originalText = data.idAndName
        let formattedText = originalText.replacingOccurrences(of: " (", with: "\n(")
        idAndNameLabel.text = formattedText
        typeLabel.text = data.type
        heightLabel.text = data.height
        weightLabel.text = data.weight
    }
    
    private func setImage(imageData: Data?) {
        if let imageData {
            imageView.image = UIImage(data: imageData)
        } else {
            imageView.image = UIImage(resource: .default)
        }
        stopLoading()
    }
    
    private func handleError(_ error: Error) {
        switch error {
        case let apiError as APIErrorProtocol:
            showToast(message: apiError.message, opacity: 0.7)
            
        default:
            debugPrint("Error:", error.localizedDescription)
        }
    }
}
