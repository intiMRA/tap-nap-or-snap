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
    @Published var navigateToTabView = false
    @Published var email = ""
    @Published var password = ""
    @Published var showAlert = false
    var error: CustomError?
    var cancellable = Set<AnyCancellable>()
    let api: LogInAPIProtocol
    init(api: LogInAPIProtocol = LogInAPI()) {
        self.api = api
        Task {
            await logInUserAlreadySignedIn()
        }
    }
    
    func login() async {
        do {
            try await api.login(email: email, password: password)
            try await api.getData()
            self.navigateToTabView = true
        } catch {
            if let error = error as? CustomError {
                self.error = error
                self.showAlert = true
            } else {
                print(error)
            }
            
        }
    }
    
    func signup() async {
        do {
            try await api.signUp(email: email, password: password)
            self.navigateToTabView = true
        } catch {
            if let error = error as? CustomError {
                self.error = error
                self.showAlert = true
            } else {
                print(error)
            }
        }
    }
    
    func logInUserAlreadySignedIn() async {
        do {
            try await api.logInUserAlreadySignedIn()
            try await api.getData()
            self.navigateToTabView = true
        } catch {
            //no error handling
            print(error)
        }
    }
    
    func clearDetails() async {
        self.email = ""
        self.password = ""
    }
}
