//
//  SubmissionsAPI.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 21/03/22.
//

import Foundation
import Combine
import FirebaseFirestore

protocol SubmissionsAPIProtocol {
    func addNewSubToList(submissionName: String) async throws
    func getSubsList() -> AnyPublisher<[String], Error>
}

class SubmissionsAPI: SubmissionsAPIProtocol {
    enum Keys: String {
        case subMissionList, users, peopleTapped
    }
    
    lazy var fireStore = Firestore.firestore()
    
    func addNewSubToList(submissionName: String) async throws {
        guard let uid = Store.shared.loginModel?.id else {
            return
        }
        let snapshot = try await self.fireStore.collection(Keys.users.rawValue).document(uid).getDocument()
        
        guard snapshot.exists == true,
              let snapshot = snapshot.data()
        else {
            return
        }
        var newList = [String]()
        
        if let list = snapshot[Keys.subMissionList.rawValue] as? [String] {
            newList.append(contentsOf: list)
        }
        
        let peopleTapped = (snapshot[Keys.peopleTapped.rawValue] as? [[String: String]]) ?? [[String: String]]()
        
        newList.append(submissionName)
        
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData([Keys.subMissionList.rawValue: newList, Keys.peopleTapped.rawValue: peopleTapped], merge: true)
    }
    
    func saveWholeSub(submission: Submission) async throws {
        guard let uid = Store.shared.loginModel?.id else {
            return
        }
        let snapshot = try await self.fireStore.collection(Keys.users.rawValue).document(uid).getDocument()
        
        guard snapshot.exists == true,
              let snapshot = snapshot.data()
        else {
            return
        }
        
        var peopleTapped = [[String: String]]()
        
        if let subsList = snapshot[Keys.peopleTapped.rawValue] as? [[String: String]] {
            peopleTapped.append(contentsOf: subsList)
        }
        
        let subsList = (snapshot[Keys.subMissionList.rawValue] as? [String]) ?? []
        
        peopleTapped.append(["id": submission.id, "subName": submission.subName, "person": submission.personName ?? ""])
        
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData([Keys.subMissionList.rawValue: subsList, Keys.peopleTapped.rawValue: peopleTapped], merge: true)
    }
    
    func getSubsList() -> AnyPublisher<[String], Error> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        let fireStore = Firestore.firestore()
                        guard let uid = Store.shared.loginModel?.id else {
                            promise(.failure(NSError()))
                            return
                        }
                        let snapshot = try await fireStore.collection(Keys.users.rawValue).document(uid).getDocument()
                        
                        guard snapshot.exists == true,
                              let snapshot = snapshot.data(),
                              let list = snapshot[Keys.subMissionList.rawValue] as? [String]
                        else {
                            promise(.failure(NSError()))
                            return
                        }
               
                        promise(.success(list.map { $0 }))
                    } catch {
                        promise(.failure(NSError()))
                    }
                }
                
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getPeopleTapped() -> AnyPublisher<[Submission], Error> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        let fireStore = Firestore.firestore()
                        guard let uid = Store.shared.loginModel?.id else {
                            promise(.failure(NSError()))
                            return
                        }
                        let snapshot = try await fireStore.collection(Keys.users.rawValue).document(uid).getDocument()
                        
                        guard snapshot.exists == true,
                              let snapshot = snapshot.data(),
                              let list = snapshot[Keys.peopleTapped.rawValue] as? [[String: String]]
                        else {
                            promise(.failure(NSError()))
                            return
                        }
               
                        promise(.success(list.map { Submission(id: $0["id"] ?? "", subName: $0["subName"] ?? "", personName: $0["person"]) }))
                    } catch {
                        promise(.failure(NSError()))
                    }
                }
                
            }
        }
        .eraseToAnyPublisher()
    }
    
}
