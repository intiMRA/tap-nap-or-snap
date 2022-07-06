//
//  MockStore.swift
//  Tap Nap Or SnapTests
//
//  Created by Inti Albuquerque on 6/07/22.
//

import Foundation
@testable import Tap_Nap_Or_Snap

actor MockStore: StoreProtocol {
    var loginState: LogInState?
    
    var submissionNamesState: SubmissionNamesState?
    
    var submissionsState: SubmissionsState?
    
    var goalsState: GoalsState?
    
    func changeState(newState: StoreState) {
        switch newState.stateType {
        case .goals:
            goalsState = newState as? GoalsState
        case .submissions:
            submissionsState = newState as? SubmissionsState
        case .login:
            loginState = newState as? LogInState
        case .submissionNames:
            submissionsState = newState as? SubmissionsState
        }
    }
    
    func changeStates(states: [StoreState]) {
        states.forEach { s in
            changeState(newState: s)
        }
    }
    
    
}
