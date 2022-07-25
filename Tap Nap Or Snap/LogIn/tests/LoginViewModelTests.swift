//
//  LoginViewModelTests.swift
//  Tap Nap Or SnapTests
//
//  Created by Inti Albuquerque on 25/07/22.
//

import Foundation
import XCTest
@testable import Tap_Nap_Or_Snap

class LoginViewModelTests: XCTestCase {
    func testLogin() async {
        let center = MockNotificationCenter()
        center.expectation = self.expectation(description: "wait for login")
        await Store.shared.setNotificationCenter(notificationCenter: center)
        let api = MockLoginAPI()
        let vm = await LogInViewModel(api: api)
        await MainActor.run {
            vm.email = "a@a.a"
            vm.password = "aaaaaaaaaa"
        }
        await vm.login()
        await waitForExpectations(timeout: 10)
        let loginId = await Store.shared.loginState?.id
        XCTAssertEqual(loginId, "id")
        let sub = await Store.shared.submissionNamesState?.subs[0]
        XCTAssertEqual(sub, "trig")
        
    }
    
    func testSignup() async {
        let center = MockNotificationCenter()
        center.expectation = self.expectation(description: "wait for login")
        await Store.shared.setNotificationCenter(notificationCenter: center)
        let api = MockLoginAPI()
        let vm = await LogInViewModel(api: api)
        await MainActor.run {
            vm.email = "a@a.a"
            vm.password = "aaaaaaaaaa"
        }
        await vm.signup()
        await waitForExpectations(timeout: 10)
        let loginId = await Store.shared.loginState?.id
        XCTAssertEqual(loginId, "id")
    }

}

class MockLoginAPI: LogInAPIProtocol {
    func login(email: String, password: String) async throws {
        let logInState = LogInState(id: "id")
        await Store.shared.changeState(newState: logInState)
    }
    
    func logInUserAlreadySignedIn() async throws {
        
        let logInState = LogInState(id: "id")
        await Store.shared.changeState(newState: logInState)
    }
    
    func signUp(email: String, password: String) async throws {
        let logInState = LogInState(id: "id")
        await Store.shared.changeState(newState: logInState)
    }
    
    func getData() async throws {
        await Store.shared.changeState(newState: SubmissionNamesState(subs: ["trig"]))
    }
    
    func signOut() async throws {
        
    }
}
