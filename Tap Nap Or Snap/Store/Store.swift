//
//  Store.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 16/03/22.
//

import Foundation

protocol StoreState { }

enum StateType: String {
    case tapped, people, gotTapped, login
}

actor Store {
    private(set) static var shared = Store()
    
    let loginModel: LogInModel?
    private init(loginModel: LogInModel? = nil) {
        self.loginModel = loginModel
    }
    
    func changeState(newState: StoreState, stateType: StateType) {
        switch stateType {
        case .tapped:
            break
        case .people:
            break
        case .gotTapped:
            break
        case .login:
            guard let loginState = validateLoginState(state: newState) else {
                return
            }
            Store.shared = Store(loginModel: loginState)
        }
    }
    
    private func validateLoginState(state: StoreState) -> LogInModel? {
        guard let state = state as? LogInModel, !state.id.isEmpty else {
            return nil
        }
        return state
    }
    
}
