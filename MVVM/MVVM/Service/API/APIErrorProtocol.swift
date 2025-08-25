//
//  APIErrorProtocol.swift
//  MVVM
//
//  Created by LCH on 8/25/25.
//

import Foundation

protocol APIErrorProtocol: Error {
    var message: String { get }
}
