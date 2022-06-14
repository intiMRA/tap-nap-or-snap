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
    func signOut() async throws
}

struct LogInError: Error {
    static let unkownError = LogInError(title: "Unkown.Error.Title", message: "Unkown.Error.Message")
    let title: String
    let message: String
}


class LogInAPI: LogInAPIProtocol {
    lazy var fireStore = Firestore.firestore()
    
    static func logInError(from errorCode: AuthErrorCode) -> LogInError {
        switch errorCode {
        case .invalidCredential:
            return LogInError(title: "Wrong.Credentials.Error.Title", message: "Wrong.Credentials.Error.Message")
        case .emailAlreadyInUse:
            return LogInError(title: "Invalid.Email", message: "Credential.Already.In.Use")
        case .invalidEmail:
            return LogInError(title: "Invalid.Email", message: "Invalid.Email.Error")
        case .wrongPassword:
            return LogInError(title: "Invalid.Password", message: "Invalid.Password.Error")
        case .userNotFound:
            return LogInError(title: "Invalid.Email", message: "No.Such.Email.Error")
        case .accountExistsWithDifferentCredential:
            return LogInError(title: "Invalid.Credentials", message: "Account.Exists.With.Different.Credential")
        case .networkError:
            return LogInError(title: "Network.Error.Title", message: "Network.Error.Message")
        case .credentialAlreadyInUse:
            return LogInError(title: "Invalid.Credentials", message: "Credential.Already.In.Use")
        case .weakPassword:
            return LogInError(title: "Invalid.Password", message: "Weak.Password")
        case .webNetworkRequestFailed:
            return LogInError(title: "Network.Error.Title", message: "Network.Error.Message")
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
    
    func signOut() async throws {
        try Auth.auth().signOut()
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
            let submissions = snapshot[Keys.submissions.rawValue] as? [String: [String:[String: Any]]] ?? [:]
            let goalsList = snapshot[Keys.goals.rawValue] as? [[String: String]] ?? []
            
            let submissionNamesState = SubmissionNamesState(subs: submissionList.map { $0 })
            
            let submissionsStateDict = submissions.keys.reduce([String: [Submission]]()) { partialResult, nextSubName in
                var currentResult = partialResult
                let currentSubmissionByname = submissions[nextSubName]
                let subs = currentSubmissionByname?.reduce([Submission](), { partialResult, personDictionary in
                    var current = partialResult
                    let sub = Submission(from: personDictionary.value, subName: nextSubName, personName: personDictionary.key)
                    current.append(sub)
                    return current
                })
                
                currentResult[nextSubName] = subs
                
                return currentResult
            }
            
            let submissionsState = SubmissionsState(subs: submissionsStateDict)
            
            let goalsState =  GoalsState(goals: goalsList.map {
                GoalModel(
                    id: $0[Keys.id.rawValue] ?? "",
                    title: $0[Keys.title.rawValue] ?? "",
                    description: $0[Keys.description.rawValue] ?? "",
                    timeStamp: $0[Keys.timeStamp.rawValue]?.asDate() ?? Date(),
                    isComplete: Bool($0[GoalKeys.isComplete.rawValue] ?? "false") ?? false
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

