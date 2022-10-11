//
//  LogInViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 16/03/22.
//

import Foundation
import Combine

@MainActor
class LogInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var showAlert = false
    var error: CustomError?
    var cancellable = Set<AnyCancellable>()
    let api: LogInAPIProtocol
    init(api: LogInAPIProtocol = LogInAPI()) {
        self.api = api
    }
    
    func login() async -> Bool {
        do {
            try await api.login(email: email, password: password)
            try await api.getData()
            return true
        } catch {
            if let error = error as? CustomError {
                self.error = error
                self.showAlert = true
            } else {
                print(error)
            }
            return false
        }
    }
    
    func signup() async -> Bool {
        do {
            try await api.signUp(email: email, password: password)
            return true
        } catch {
            if let error = error as? CustomError {
                self.error = error
                self.showAlert = true
            } else {
                print(error)
            }
            return false
        }
    }
    
    func logInUserAlreadySignedIn() async -> Bool {
        do {
            try await api.logInUserAlreadySignedIn()
            try await api.getData()
            return true
        } catch {
            //no error handling
            print(error)
            return false
        }
    }
    
    func clearDetails() async {
        self.email = ""
        self.password = ""
    }
}
