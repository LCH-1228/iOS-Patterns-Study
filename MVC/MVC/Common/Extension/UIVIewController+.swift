//
//  UIVIewController+.swift
//  MVC
//
//  Created by LCH on 8/20/25.
//

import UIKit

extension UIViewController {
    
    func showToast(message: String,
                   opcity: CGFloat,
                   duration: TimeInterval = 2.0,
                   setConstraints: (_ toast: UIStackView) -> [NSLayoutConstraint] = { toast in
        guard let superview = toast.superview else { return [] }
        return [
            toast.widthAnchor.constraint(lessThanOrEqualTo: superview.widthAnchor, constant: -100),
            toast.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ]
    }) {
        let toastView = ToastView(message: message, opcity: opcity)
        toastView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(toastView)
        NSLayoutConstraint.activate(setConstraints(toastView))
        toastView.show(duration: duration)
    }
}
