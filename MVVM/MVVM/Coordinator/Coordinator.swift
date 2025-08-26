//
//  Coordinator.swift
//  MVVM
//
//  Created by LCH on 8/26/25.
//

import UIKit

protocol CoordinatorProtocol {
    var navigationController: UINavigationController { get }
    func start()
}

final class Coordinator: NSObject, CoordinatorProtocol {
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        navigationController.delegate = self
    }

    func start() {
        showList()
    }
    
    private func showList() {
        let listDependencies = DIContainer.shared.makeListDependencies()
        
        let listVM = ListViewModel(dependencies: listDependencies) { [weak self] id in
            self?.showDetail(id: id)
        }
        
        let listVC = ListViewController(viewModel: listVM)
        navigationController.setViewControllers([listVC], animated: false)
    }

    private func showDetail(id: Int) {
        let detailDependencies = DIContainer.shared.makeDetailDependencies()
        let detailVM = DetailViewModel(detailDependencies: detailDependencies, id: id)
        let detailVC = DetailViewController(viewModel: detailVM)
        navigationController.pushViewController(detailVC, animated: true)
    }
}

extension Coordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if navigationController.viewControllers.first !== viewController {
            viewController.navigationItem.backButtonTitle = ""
            
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -4, bottom: 0, trailing: 0)
            config.baseForegroundColor = .ColorSet.dark
            config.image = UIImage(systemName: "chevron.left",
                                   withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular))
            config.title = "뒤로가기"
            
            let backButton = UIButton(configuration: config)
            backButton.addAction(.init { [weak self] _ in
                self?.navigationController.popViewController(animated: true)
            }, for: .touchUpInside)
            
            let barButton = UIBarButtonItem(customView: backButton)
            viewController.navigationItem.leftBarButtonItem = barButton
        }
        
        let isNavBarHidden = viewController is ListViewController
        navigationController.setNavigationBarHidden(isNavBarHidden, animated: animated)
    }
}
