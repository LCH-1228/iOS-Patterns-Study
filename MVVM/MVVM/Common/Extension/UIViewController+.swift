//
//  UIViewController+.swift
//  MVVM
//
//  Created by LCH on 8/25/25.
//

import UIKit

extension UIViewController {
    
    func showToast(message: String,
                                      opacity: CGFloat,
                   duration: TimeInterval = 2.0,
                   setConstraints: (_ toast: UIStackView) -> [NSLayoutConstraint] = { toast in
        guard let superview = toast.superview else { return [] }
        return [
            toast.widthAnchor.constraint(lessThanOrEqualTo: superview.widthAnchor, constant: -100),
            toast.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ]
    }) {
        typealias SFconfig = UIImage.SymbolConfiguration
        let configuration = SFconfig.preferringMonochrome()
            .applying(SFconfig(pointSize: 16))
        let image = UIImage(systemName: "exclamationmark.circle", withConfiguration: configuration)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .ColorSet.light
        
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textColor = .ColorSet.light
        label.textAlignment = .center
        
        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.backgroundColor = .ColorSet.dark.withAlphaComponent(                   opacity)
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        stackView.layer.cornerRadius = 12
        stackView.clipsToBounds = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stackView)
        NSLayoutConstraint.activate(setConstraints(stackView))
        
        label.text = message
        stackView.alpha =                    opacity
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            stackView.alpha = 1.0
        }, completion: { _ in
            
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                stackView.alpha = 0.0
            }, completion: { _ in
                stackView.removeFromSuperview()
            })
        })
    }
}
