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
    
    init(api: LogInAPIProtocol = LogInAPI()) {
        self.api = api
        logInUserAlreadySignedIn()
    }
    
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
            } receiveValue: { [weak self] _ in
                self?.navigateToTabView = true
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
            } receiveValue: { [weak self] _ in
                self?.navigateToTabView = true
            }
            .store(in: &cancellable)
    }
    
    func logInUserAlreadySignedIn() {
        api.logInUserAlreadySignedIn()
            .receive(on: DispatchQueue.main)
            .sink (receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case _:
                    break
                }
                
            }, receiveValue: { [weak self] model in
                self?.navigateToTabView = true
            })
            .store(in: &cancellable)
    }
}
