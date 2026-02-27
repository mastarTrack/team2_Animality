//
//  Untitled.swift
//  Animality
//
//  Created by t2025-m0143 on 2/27/26.
//

protocol ViewModelProtocol {
    associatedtype Action
    associatedtype State
    
    var state: State { get }
    
    func action(_ action: Action) -> Void
}
