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
    let api = LogInAPI()
    
    func login() {
        api.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    //TODO: handle
                    print(error)
                    break
                }
            } receiveValue: { _ in
                self.navigateToTabView = true
            }
            .store(in: &cancellable)
    }
    
    func signup() {
        api.signUp(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    //TODO: handle
                    print(error)
                    break
                }
            } receiveValue: { _ in
                self.navigateToTabView = true
            }
            .store(in: &cancellable)
    }
}
