//
//  ToastView.swift
//  MVC
//
//  Created by LCH on 8/20/25.
//

import UIKit

final class ToastView: UIStackView {
    
    private let message: String
    private let opcity: CGFloat
    
    private let imageView: UIImageView = {
        typealias SFconfig = UIImage.SymbolConfiguration
        let configuration = SFconfig.preferringMonochrome()
            .applying(SFconfig(pointSize: 16))
        let image = UIImage(systemName: "exclamationmark.circle", withConfiguration: configuration)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .ColorSet.light
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textColor = .ColorSet.light
        label.textAlignment = .center
        return label
    }()
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(message: String, opcity: CGFloat) {
        self.message = message
        self.opcity = opcity
        
        super.init(frame: .null)
        
        setup()
        [
            imageView, label
        ].forEach { addArrangedSubview($0) }
    }
    
    private func setup() {
        label.text = message
        backgroundColor = .ColorSet.dark.withAlphaComponent(opcity)
        spacing = 8
        alignment = .center
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        layer.cornerRadius = 12
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func show(duration: TimeInterval = 2.0) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: { _ in
            
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                self.alpha = 0.0
            }, completion: { _ in
                self.removeFromSuperview()
            })
        })
    }
}
