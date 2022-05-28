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
    func login(email: String, password: String) async throws
    func logInUserAlreadySignedIn() async throws
    func signUp(email: String, password: String) async throws
    func getData() async throws
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
    
    func login(email: String, password: String) async throws {
        
        let splitEmail = email.split(separator: "@")
        guard
            splitEmail[safe: 0] != nil,
            splitEmail[safe: 1] != nil
        else {
            throw LogInError.unkownError
        }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            
            let snapshot = try await self.fireStore.collection("users").document(result.user.uid).getDocument()
            
            guard snapshot.exists == true else {
                throw LogInError.unkownError
            }
            
            let model = LogInState(id: result.user.uid)
            
            await Store.shared.changeState(newState: model)
        } catch {
            if let errorCode = AuthErrorCode(rawValue: error._code) {
                throw LogInAPI.logInError(from: errorCode)
            } else {
                throw LogInError.unkownError
            }
        }
        
    }
    
    func reloadUser() async throws {
        try await Auth.auth().currentUser?.reload()
    }
    
    func logInUserAlreadySignedIn() async throws {
        
        guard let currentUser = Auth.auth().currentUser else {
            throw LogInError.unkownError
        }
        
        do {
            try await self.reloadUser()
            
            guard Store.shared.loginState == nil else {
                try Auth.auth().signOut()
                throw LogInError.unkownError
            }
            
            let snapshot = try await self.fireStore.collection("users").document(currentUser.uid).getDocument()
            guard snapshot.exists == true else {
                try Auth.auth().signOut()
                throw LogInError.unkownError
            }
            
            let model = LogInState(id: currentUser.uid)
            
            await Store.shared.changeState(newState: model)
            
        } catch {
            try Auth.auth().signOut()
            throw LogInError.unkownError
        }
    }
    
    func signUp(email: String, password: String) async throws {
        
        let splitEmail = email.split(separator: "@")
        guard
            splitEmail[safe: 0] != nil,
            splitEmail[safe: 1] != nil
        else {
            throw LogInError.unkownError
        }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            let dic: [String : Any] = [
                "email": email
            ]
            
            try await self.fireStore.collection("users").document(result.user.uid).setData(dic)
            let model = LogInState(id: result.user.uid)
            await Store.shared.changeState(newState: model)
        } catch {
            if let errorCode = AuthErrorCode(rawValue: error._code) {
                throw LogInAPI.logInError(from: errorCode)
            } else {
                throw LogInError.unkownError
            }
        }
    }
    
    func getData() async throws {
        do {
            let fireStore = Firestore.firestore()
            guard let uid = Store.shared.loginState?.id else {
                throw NSError()
            }
            let snapshot = try await fireStore.collection(Keys.users.rawValue).document(uid).getDocument()
            
            guard snapshot.exists == true,
                  let snapshot = snapshot.data()
            else {
                throw NSError()
            }
            let submissionList = snapshot[Keys.subMissionList.rawValue] as? [String] ?? []
            let submissions = snapshot[Keys.submissions.rawValue] as? [String: [String: [[String: String]]]] ?? [:]
            let goalsList = snapshot[Keys.goals.rawValue] as? [[String: String]] ?? []
            
            let submissionNamesState = SubmissionNamesState(subs: submissionList.map { $0 })
            
            let submissionsStateDict = submissions.keys.reduce([String: SubmissionsModel]()) { partialResult, nextItemName in
                var currentResult = partialResult
                let currentSubmission = submissions[nextItemName]
                let wins = currentSubmission?[SubmissionKeys.wins.rawValue]?.map { Submission(
                    id: $0[Keys.id.rawValue] ?? "",
                    subName: $0[Keys.subName.rawValue] ?? "",
                    personName: $0[Keys.person.rawValue],
                    description: $0[Keys.description.rawValue]
                )}
                
                let losses = currentSubmission?[SubmissionKeys.losses.rawValue]?.map { Submission(
                    id: $0[Keys.id.rawValue] ?? "",
                    subName: $0[Keys.subName.rawValue] ?? "",
                    personName: $0[Keys.person.rawValue],
                    description: $0[Keys.description.rawValue]
                )}
                
                currentResult[nextItemName] = SubmissionsModel(
                    wins: wins ?? [],
                    losses: losses ?? [])
                
                return currentResult
            }
            
            let submissionsState = SubmissionsState(subs: submissionsStateDict)
            
            let goalsState =  GoalsState(goals: goalsList.map {
                GoalModel(
                    id: $0[Keys.id.rawValue] ?? "",
                    title: $0[Keys.title.rawValue] ?? "",
                    description: $0[Keys.description.rawValue] ?? "",
                    timeStamp: $0[Keys.timeStamp.rawValue]?.asDate() ?? Date()
                )
            })
            
            await Store.shared.changeStates(states: [
                submissionNamesState,
                submissionsState,
                goalsState
            ])
            
        } catch {
            throw NSError()
        }
    }
}

