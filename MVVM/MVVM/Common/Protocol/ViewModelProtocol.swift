//
//  ViewModelProtocol.swift
//  MVVM
//
//  Created by LCH on 8/28/25.
//

import Foundation

protocol ViewModelProtocol {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input) -> Output
}
