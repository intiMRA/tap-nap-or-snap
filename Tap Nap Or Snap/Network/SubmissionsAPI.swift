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
    
}

class SubmissionsAPI: SubmissionsAPIProtocol {
    lazy var fireStore = Firestore.firestore()
    
    func addNewSubToList(submissionName: String) async throws {
        guard let uid = Store.shared.loginModel?.id else {
            return
        }
        let snapshot = try await self.fireStore.collection("users").document(uid).getDocument()
        
        guard snapshot.exists == true,
              let snapshot = snapshot.data()
        else {
            return
        }
        var newList = [String]()
        
        if let list = snapshot["subMissionList"] as? [String] {
            newList.append(contentsOf: list)
        }
        
        newList.append(submissionName)
        
        try await self.fireStore.collection("users").document(uid).setData(["subMissionList": newList], merge: true)
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
                        let snapshot = try await fireStore.collection("users").document(uid).getDocument()
                        
                        guard snapshot.exists == true,
                              let snapshot = snapshot.data(),
                              let list = snapshot["subMissionList"] as? [String]
                        else {
                            promise(.failure(NSError()))
                            return
                        }
               
                        promise(.success(list))
                    } catch {
                        promise(.failure(NSError()))
                    }
                }
                
            }
        }
        .eraseToAnyPublisher()
    }
    
}
