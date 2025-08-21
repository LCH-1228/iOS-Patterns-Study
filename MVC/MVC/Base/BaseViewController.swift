//
//  BaseViewController.swift
//  MVC
//
//  Created by LCH on 8/18/25.
//

import UIKit

class BaseViewController: UIViewController {
    
    var navigationBarHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = navigationBarHidden
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    private func setupNavigationBar() {
        
        navigationItem.backButtonTitle = ""
        if navigationController?.viewControllers.first !== self {
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -4, bottom: 0, trailing: 0)
            config.baseForegroundColor = .ColorSet.dark
            config.image = UIImage(systemName: "chevron.left",
                                   withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
            )
            config.title = "뒤로가기"
            let backButton = UIButton(configuration: config)
            backButton.addAction(.init { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }, for: .touchUpInside)
            let barButton = UIBarButtonItem(customView: backButton)
            navigationItem.leftBarButtonItem = barButton
        }
    }
}
