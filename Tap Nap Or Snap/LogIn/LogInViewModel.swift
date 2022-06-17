//
//  LogInViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 16/03/22.
//

import Foundation
import Combine

class LogInViewModel: ObservableObject {
    @Published var navigateToTabView = false
    @Published var email = ""
    @Published var password = ""
    @Published var showAlert = false
    var error: LogInError?
    var cancellable = Set<AnyCancellable>()
    let api: LogInAPIProtocol
    init(api: LogInAPIProtocol = LogInAPI()) {
        self.api = api
        logInUserAlreadySignedIn()
    }
    
    func login() {
        Task {
            do {
                try await api.login(email: email, password: password)
                try await api.getData()
                dispatchOnMain {
                    self.navigateToTabView = true
                }
            } catch {
                if let error = error as? LogInError {
                    self.error = error
                    await MainActor.run {
                        self.showAlert = true
                    }
                } else {
                    print(error)
                }
                
            }
        }
    }
    
    func signup() {
        Task {
            do {
                try await api.signUp(email: email, password: password)
                dispatchOnMain {
                    self.navigateToTabView = true
                }
            } catch {
                if let error = error as? LogInError {
                    self.error = error
                    await MainActor.run {
                        self.showAlert = true
                    }
                } else {
                    print(error)
                }
            }
        }
    }
    
    func logInUserAlreadySignedIn() {
        Task {
            do {
                try await api.logInUserAlreadySignedIn()
                try await api.getData()
                dispatchOnMain {
                    self.navigateToTabView = true
                }
            } catch {
                //no error handling
                print(error)
            }
        }
    }
    
    private func dispatchOnMain(_ action: @escaping () -> Void) {
        DispatchQueue.main.async {
            action()
        }
    }
}
