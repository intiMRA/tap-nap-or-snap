//
//  LoginAPI.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 16/03/22.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

protocol LogInAPIProtocol: AnyObject {
    func login(email: String, password: String) -> AnyPublisher<LogInModel, LogInError>
    func logInUserAlreadySignedIn() -> AnyPublisher<LogInModel, LogInError>
    func signUp(email: String, password: String) -> AnyPublisher<LogInModel, LogInError>
}

struct LogInModel: StoreState {
    let id: String
}

struct LogInError: Error {
    static let unkownError = LogInError(title: "UnkownErrorTtitle".localized, message: "UnkownErrorMessage".localized)
    let title: String
    let message: String
}


class LogInAPI: LogInAPIProtocol {
    lazy var fireStore = Firestore.firestore()
    
    static func logInError(from errorCode: AuthErrorCode) -> LogInError {
        switch errorCode {
        case .invalidCredential:
            return LogInError(title: "WrongCredentialsErrorTitle".localized, message: "WrongCredentialsErrorMessage".localized)
        case .emailAlreadyInUse:
            return LogInError(title: "InvalidEmail".localized, message: "CredentialAlreadyInUse".localized)
        case .invalidEmail:
            return LogInError(title: "InvalidEmail".localized, message: "InvalidEmailError".localized)
        case .wrongPassword:
            return LogInError(title: "InvalidPassword".localized, message: "InvalidPasswordError".localized)
        case .userNotFound:
            return LogInError(title: "InvalidEmail".localized, message: "NoSuchEmailError".localized)
        case .accountExistsWithDifferentCredential:
            return LogInError(title: "InvalidCredentials".localized, message: "AccountExistsWithDifferentCredential".localized)
        case .networkError:
            return LogInError(title: "NetworkErrorTitle".localized, message: "NetworkErrorMessage".localized)
        case .credentialAlreadyInUse:
            return LogInError(title: "InvalidCredentials".localized, message: "CredentialAlreadyInUse".localized)
        case .weakPassword:
            return LogInError(title: "InvalidPassword".localized, message: "WeakPassword".localized)
        case .webNetworkRequestFailed:
            return LogInError(title: "NetworkErrorTitle".localized, message: "NetworkErrorMessage".localized)
        default:
            return LogInError.unkownError
        }
    }
    
    func login(email: String, password: String) -> AnyPublisher<LogInModel, LogInError> {
        Deferred {
            Future { [weak self] promise in
                let splitEmail = email.split(separator: "@")
                guard let self = self,
                      splitEmail[safe: 0] != nil,
                      splitEmail[safe: 1] != nil
                else {
                    promise(.failure(LogInError.unkownError))
                    return
                }
                
                Task.init {
                    
                    do {
                        let result = try await Auth.auth().signIn(withEmail: email, password: password)
                        
                        let snapshot = try await self.fireStore.collection("users").document(result.user.uid).getDocument()
                        
                        guard snapshot.exists == true,
                              let snapshot = snapshot.data(),
                              ((snapshot["email"] as? String) != nil)
                        else {
                            promise(.failure(LogInError.unkownError))
                            return
                        }
                        
                        let model = LogInModel(id: result.user.uid)
                        
                        await Store.shared.changeState(newState: model, stateType: .login)
                        promise(.success(model))
                    } catch {
                        if let errorCode = AuthErrorCode(rawValue: error._code) {
                            promise(.failure(LogInAPI.logInError(from: errorCode)))
                        } else {
                            promise(.failure(LogInError.unkownError))
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func reloadUser() async throws {
        try await Auth.auth().currentUser?.reload()
    }
    
    func logInUserAlreadySignedIn() -> AnyPublisher<LogInModel, LogInError> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self, let currentUser = Auth.auth().currentUser else {
                    promise(.failure(LogInError.unkownError))
                    return
                }
                
                Task.init {
                    do {
                        try await self.reloadUser()
                        
                        guard Store.shared.loginModel == nil else {
                            promise(.success(LogInModel(id: currentUser.uid)))
                            return
                        }
                        
                        let snapshot = try await self.fireStore.collection("users").document(currentUser.uid).getDocument()
                        guard snapshot.exists == true,
                              let snapshot = snapshot.data(),
                              ((snapshot["email"] as? String) != nil)
                        else {
                            promise(.failure(LogInError.unkownError))
                            return
                        }
                        
                        let model = LogInModel(id: currentUser.uid)
                        
                        if Store.shared.loginModel == nil  {
                            await Store.shared.changeState(newState: model, stateType: .login)
                        }
                        promise(.success(model))
                        
                    } catch {
                        try Auth.auth().signOut()
                        promise(.failure(LogInError.unkownError))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func signUp(email: String, password: String) -> AnyPublisher<LogInModel, LogInError> {
        Deferred {
            Future {  [weak self] promise in
                
                let splitEmail = email.split(separator: "@")
                guard let self = self,
                      splitEmail[safe: 0] != nil,
                      splitEmail[safe: 1] != nil
                else {
                    promise(.failure(LogInError.unkownError))
                    return
                }
                
                Task.init {
                    
                    do {
                        let result = try await Auth.auth().createUser(withEmail: email, password: password)
                        
                        let dic: [String : Any] = [
                            "email": email
                        ]
                        
                        try await self.fireStore.collection("users").document(result.user.uid).setData(dic)
                        let model = LogInModel(id: result.user.uid)
                        await Store.shared.changeState(newState: model, stateType: .login)
                        promise(.success(model))
                    } catch {
                        if let errorCode = AuthErrorCode(rawValue: error._code) {
                            promise(.failure(LogInAPI.logInError(from: errorCode)))
                        } else {
                            promise(.failure(LogInError.unkownError))
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

