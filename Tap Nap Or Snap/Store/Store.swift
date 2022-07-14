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
    case goals, submissions, login, submissionNames
}

struct LogInState: StoreState {
    var stateType: StateType = .login
    let id: String
}

struct SubmissionNamesState: StoreState {
    var stateType: StateType = .submissionNames
    let subs: [String]
}

struct SubmissionsState: StoreState {
    var stateType: StateType = .submissions
    let subs: [String: [Submission]]
}

struct GoalsState: StoreState {
    var stateType: StateType = .goals
    let goals: [GoalModel]
}

actor Store {
    private(set) static var shared = Store()
    
    let loginState: LogInState?
    let submissionNamesState: SubmissionNamesState?
    let submissionsState: SubmissionsState?
    let goalsState: GoalsState?
    private var notificationCenter: NotificationCenter
    
    private init(
        loginState: LogInState? = nil,
        submissionNamesState: SubmissionNamesState? = nil,
        submissionsState: SubmissionsState? = nil,
        goalsState: GoalsState? = nil
    ) {
        self.loginState = loginState
        self.submissionNamesState = submissionNamesState
        self.submissionsState = submissionsState
        self.goalsState = goalsState
        self.notificationCenter = NotificationCenter.default
    }
    
    func changeState(newState: any StoreState) {
        switch newState.stateType {
        case .submissions:
            guard let subs = validateSubmissionsState(state: newState) else {
                return
            }
            Store.shared = Store(
                loginState: self.loginState,
                submissionNamesState: self.submissionNamesState,
                submissionsState: subs,
                goalsState: self.goalsState)
            
        case .goals:
            guard let goals = validateGoalsState(state: newState) else {
                return
            }
            Store.shared = Store(
                loginState: self.loginState,
                submissionNamesState: self.submissionNamesState,
                submissionsState: self.submissionsState,
                goalsState: goals)
        case .login:
            guard let loginState = validateLoginState(state: newState) else {
                return
            }
            Store.shared = Store(
                loginState: loginState,
                submissionNamesState: self.submissionNamesState,
                submissionsState: self.submissionsState,
                goalsState: self.goalsState)
            
        case .submissionNames:
            guard let subsList = validateSubmissionNamesState(state: newState) else {
                return
            }
            Store.shared = Store(
                loginState: self.loginState,
                submissionNamesState: subsList,
                submissionsState: self.submissionsState,
                goalsState: self.goalsState)
            
        }
        let center = self.notificationCenter
        DispatchQueue.main.async {
            center.post(Notification(name: NSNotification.reloadNotification))
        }
    }
    
    func changeStates(states: [StoreState]) {
        var loginState = self.loginState
        var submissionNamesState = self.submissionNamesState
        var submissionsState = self.submissionsState
        var goalsState = self.goalsState
        states.forEach { state in
            switch state.stateType {
            case .submissions:
                submissionsState = validateSubmissionsState(state: state) ?? submissionsState
            case .goals:
                goalsState = validateGoalsState(state: state) ?? goalsState
            case .login:
                loginState = validateLoginState(state: state) ?? loginState
            case .submissionNames:
                submissionNamesState = validateSubmissionNamesState(state: state) ?? submissionNamesState
            }
        }
        Store.shared = Store(
            loginState: loginState,
            submissionNamesState: submissionNamesState,
            submissionsState: submissionsState,
            goalsState: goalsState)
        let center = self.notificationCenter
        DispatchQueue.main.async {
            center.post(Notification(name: NSNotification.reloadNotification))
        }
    }
    
    private func validateLoginState(state: any StoreState) -> LogInState? {
        guard let state = state as? LogInState, !state.id.isEmpty else {
            return nil
        }
        return state
    }
    
    private func validateGoalsState(state: any StoreState) -> GoalsState? {
        guard let state = state as? GoalsState else {
            return nil
        }
        return state
    }
    
    private func validateSubmissionNamesState(state: any StoreState) -> SubmissionNamesState? {
        guard let state = state as? SubmissionNamesState else {
            return nil
        }
        return state
    }
    
    private func validateSubmissionsState(state: any StoreState) -> SubmissionsState? {
        guard let state = state as? SubmissionsState else {
            return nil
        }
        return state
    }
    
    #if DEBUG
        func setNotificationCenter(notificationCenter: NotificationCenter) {
            self.notificationCenter = notificationCenter
        }
    #endif
    
}

extension NSNotification {
    static let reloadNotification = Notification.Name.init("Reload Data")
    static let publisher = NotificationCenter.default.publisher(for: NSNotification.reloadNotification)
}
