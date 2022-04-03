//
//  Store.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 16/03/22.
//

import Foundation

protocol StoreState {
    var stateType: StateType { get }
}

enum StateType: String {
    case wins, people, losses, login, subs
}

struct LogInState: StoreState {
    var stateType: StateType = .login
    let id: String
}

struct SubmissionsListState: StoreState {
    var stateType: StateType = .subs
    let subs: [String]
}

struct WinsState: StoreState {
    var stateType: StateType = .wins
    let subs: [Submission]
}

struct LossesState: StoreState {
    var stateType: StateType = .losses
    let subs: [Submission]
}

actor Store {
    private(set) static var shared = Store()
    
    let loginState: LogInState?
    let submissionsListState: SubmissionsListState?
    let winsState: WinsState?
    let lossesState: LossesState?
    
    private init(
        loginState: LogInState? = nil,
        submissionsListState: SubmissionsListState? = nil,
        winsState: WinsState? = nil,
        lossesState: LossesState? = nil
    ) {
        self.loginState = loginState
        self.submissionsListState = submissionsListState
        self.winsState = winsState
        self.lossesState = lossesState
    }
    
    func changeState(newState: StoreState) {
        switch newState.stateType {
        case .wins:
            guard let wins = validateWinsState(state: newState) else {
                return
            }
            Store.shared = Store(
                loginState: self.loginState,
                submissionsListState: self.submissionsListState,
                winsState: wins,
                lossesState: self.lossesState)
            
        case .people:
            break
        case .losses:
            guard let losses = validateLossesState(state: newState) else {
                return
            }
            Store.shared = Store(
                loginState: self.loginState,
                submissionsListState: self.submissionsListState,
                winsState: self.winsState,
                lossesState: losses)
            
        case .login:
            guard let loginState = validateLoginState(state: newState) else {
                return
            }
            Store.shared = Store(
                loginState: loginState,
                submissionsListState: self.submissionsListState,
                winsState: self.winsState,
                lossesState: self.lossesState)
            
        case .subs:
            guard let subsList = validateSubsListState(state: newState) else {
                return
            }
            Store.shared = Store(
                loginState: self.loginState,
                submissionsListState: subsList,
                winsState: self.winsState,
                lossesState: self.lossesState)
            
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(Notification(name: NSNotification.reloadNotification))
        }
    }
    
    private func validateLoginState(state: StoreState) -> LogInState? {
        guard let state = state as? LogInState, !state.id.isEmpty else {
            return nil
        }
        return state
    }
    
    private func validateSubsListState(state: StoreState) -> SubmissionsListState? {
        guard let state = state as? SubmissionsListState else {
            return nil
        }
        return state
    }
    
    private func validateWinsState(state: StoreState) -> WinsState? {
        guard let state = state as? WinsState else {
            return nil
        }
        return state
    }
    
    private func validateLossesState(state: StoreState) -> LossesState? {
        guard let state = state as? LossesState else {
            return nil
        }
        return state
    }
    
}

extension NSNotification {
    static let reloadNotification = Notification.Name.init("Reload Data")
    static let publisher = NotificationCenter.default.publisher(for: NSNotification.reloadNotification)
}
