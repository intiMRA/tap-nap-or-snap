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

struct CustomError: Error {
    static let unkownError = CustomError(title: "Unkown.Error.Title".localized, message: "Unkown.Error.Message".localized)
    let title: String
    let message: String
    
    static func error(from errorCode: AuthErrorCode) -> CustomError {
        switch errorCode {
        case .invalidCredential:
            return CustomError(title: "Wrong.Credentials.Error.Title".localized, message: "Wrong.Credentials.Error.Message".localized)
        case .emailAlreadyInUse:
            return CustomError(title: "Invalid.Email".localized, message: "Credential.Already.In.Use".localized)
        case .invalidEmail:
            return CustomError(title: "Invalid.Email".localized, message: "Invalid.Email.Error".localized)
        case .wrongPassword:
            return CustomError(title: "Invalid.Password".localized, message: "Invalid.Password.Error".localized)
        case .userNotFound:
            return CustomError(title: "Invalid.Email".localized, message: "No.Such.Email.Error".localized)
        case .accountExistsWithDifferentCredential:
            return CustomError(title: "Invalid.Credentials".localized, message: "Account.Exists.With.Different.Credential".localized)
        case .networkError:
            return CustomError(title: "Network.Error.Title".localized, message: "Network.Error.Message".localized)
        case .credentialAlreadyInUse:
            return CustomError(title: "Invalid.Credentials".localized, message: "Credential.Already.In.Use".localized)
        case .weakPassword:
            return CustomError(title: "Invalid.Password".localized, message: "Weak.Password".localized)
        case .webNetworkRequestFailed:
            return CustomError(title: "Network.Error.Title".localized, message: "Network.Error.Message".localized)
        default:
            return CustomError.unkownError
        }
    }
}


class LogInAPI: LogInAPIProtocol {
    lazy var fireStore = Firestore.firestore()
    
    func login(email: String, password: String) async throws {
        
        let splitEmail = email.split(separator: "@")
        guard
            splitEmail[safe: 0] != nil,
            splitEmail[safe: 1] != nil
        else {
            throw CustomError.unkownError
        }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            
            let snapshot = try await self.fireStore.collection("users").document(result.user.uid).getDocument()
            
            guard snapshot.exists == true else {
                throw CustomError.unkownError
            }
            
            let model = LogInState(id: result.user.uid)
            
            await Store.shared.changeState(newState: model)
        } catch {
            if let errorCode = AuthErrorCode(rawValue: error._code) {
                throw CustomError.error(from: errorCode)
            } else {
                throw CustomError.unkownError
            }
        }
        
    }
    
    func reloadUser() async throws {
        try await Auth.auth().currentUser?.reload()
    }
    
    func logInUserAlreadySignedIn() async {
        
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        try? await self.reloadUser()
        
        guard Store.shared.loginState == nil else {
            try? Auth.auth().signOut()
            return
        }
        
        let snapshot = try? await self.fireStore.collection("users").document(currentUser.uid).getDocument()
        guard snapshot?.exists == true else {
            try? Auth.auth().signOut()
            return
        }
        
        let model = LogInState(id: currentUser.uid)
        
        await Store.shared.changeState(newState: model)
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
            throw CustomError.unkownError
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
                throw CustomError.error(from: errorCode)
            } else {
                throw CustomError.unkownError
            }
        }
    }
    
    func getData() async throws {
        do {
            let fireStore = Firestore.firestore()
            guard let uid = Store.shared.loginState?.id else {
                throw CustomError.unkownError
            }
            let snapshot = try await fireStore.collection(Keys.users.rawValue).document(uid).getDocument()
            
            guard snapshot.exists == true,
                  let snapshot = snapshot.data()
            else {
                throw CustomError.unkownError
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
            if let errorCode = AuthErrorCode(rawValue: error._code) {
                throw CustomError.error(from: errorCode)
            } else {
                throw CustomError.unkownError
            }
        }
    }
}

