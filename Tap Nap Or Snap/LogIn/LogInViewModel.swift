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
    var cancellable = Set<AnyCancellable>()
    let api: LogInAPIProtocol
    let subApi: SubmissionsAPIProtocol
    init(api: LogInAPIProtocol = LogInAPI(), subApi: SubmissionsAPIProtocol = SubmissionsAPI()) {
        self.api = api
        self.subApi = subApi
        logInUserAlreadySignedIn()
    }
    
    func login() {
        Task {
            do {
                try await api.login(email: email, password: password)
                try await subApi.getData()
                dispatchOnMain {
                    self.navigateToTabView = true
                }
            } catch {
                print(error)
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
                print(error)
            }
        }
    }
    
    func logInUserAlreadySignedIn() {
        Task {
            do {
                try await api.logInUserAlreadySignedIn()
                try await subApi.getData()
                dispatchOnMain {
                    self.navigateToTabView = true
                }
            } catch {
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
