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
    func getWins() -> AnyPublisher<[Submission], Error>
    func getLosses() -> AnyPublisher<[Submission], Error>
    func saveWin(submission: Submission) async throws
    func saveLoss(submission: Submission) async throws
}

class SubmissionsAPI: SubmissionsAPIProtocol {
    enum Keys: String {
        case subMissionList, users, wins, losses, numberOfTimes, id, subName, person
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
        
        newList.append(submissionName)
        
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(createUploadDict(snapshot: snapshot, subsList: newList), merge: false)
    }
    
    func saveWin(submission: Submission) async throws {
        guard let uid = Store.shared.loginModel?.id else {
            return
        }
        let snapshot = try await self.fireStore.collection(Keys.users.rawValue).document(uid).getDocument()
        
        guard snapshot.exists == true,
              let snapshot = snapshot.data()
        else {
            return
        }
        
        var winsDict = [[String: String]]()
        
        if let subsList = snapshot[Keys.wins.rawValue] as? [[String: String]] {
            winsDict.append(contentsOf: subsList)
        }
        
        if winsDict.first(where: { $0[Keys.person.rawValue] == submission.personName &&  $0[Keys.subName.rawValue] == submission.subName }) != nil {
            winsDict = winsDict.map({ dict in
                if dict[Keys.person.rawValue] == submission.personName, dict[Keys.subName.rawValue] == submission.subName {
                    let numberOfTimes = Int(dict[Keys.numberOfTimes.rawValue] ?? "0")
                    return [Keys.id.rawValue: submission.id, Keys.subName.rawValue: submission.subName, Keys.person.rawValue: submission.personName ?? "", Keys.numberOfTimes.rawValue: "\(submission.numberOfTimes + (numberOfTimes ?? 0))"]
                } else {
                    return dict
                }
            })
        } else {
            winsDict.append([Keys.id.rawValue: submission.id, Keys.subName.rawValue: submission.subName, Keys.person.rawValue: submission.personName ?? "", Keys.numberOfTimes.rawValue: "\(submission.numberOfTimes)"])
        }
        
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(createUploadDict(snapshot: snapshot, winsDict: winsDict), merge: false)
    }
    
    func saveLoss(submission: Submission) async throws {
        guard let uid = Store.shared.loginModel?.id else {
            return
        }
        let snapshot = try await self.fireStore.collection(Keys.users.rawValue).document(uid).getDocument()
        
        guard snapshot.exists == true,
              let snapshot = snapshot.data()
        else {
            return
        }
        
        var lossesDict = [[String: String]]()
        
        if let subsList = snapshot[Keys.losses.rawValue] as? [[String: String]] {
            lossesDict.append(contentsOf: subsList)
        }
        
        if lossesDict.first(where: { $0[Keys.person.rawValue] == submission.personName &&  $0[Keys.subName.rawValue] == submission.subName }) != nil {
            lossesDict = lossesDict.map({ dict in
                if dict[Keys.person.rawValue] == submission.personName, dict[Keys.subName.rawValue] == submission.subName {
                    let numberOfTimes = Int(dict[Keys.numberOfTimes.rawValue] ?? "0")
                    return [Keys.id.rawValue: submission.id, Keys.subName.rawValue: submission.subName, Keys.person.rawValue: submission.personName ?? "", Keys.numberOfTimes.rawValue: "\(submission.numberOfTimes + (numberOfTimes ?? 0))"]
                } else {
                    return dict
                }
            })
        } else {
            lossesDict.append([Keys.id.rawValue: submission.id, Keys.subName.rawValue: submission.subName, Keys.person.rawValue: submission.personName ?? "", Keys.numberOfTimes.rawValue: "\(submission.numberOfTimes)"])
        }
        
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(createUploadDict(snapshot: snapshot, lossesDict: lossesDict), merge: false)
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
    
    func getWins() -> AnyPublisher<[Submission], Error> {
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
                              let list = snapshot[Keys.wins.rawValue] as? [[String: String]]
                        else {
                            promise(.failure(NSError()))
                            return
                        }
               
                        promise(.success(list.map { Submission(id: $0[Keys.id.rawValue] ?? "", subName: $0[Keys.subName.rawValue] ?? "", personName: $0[Keys.person.rawValue], numberOfTimes: Int($0[Keys.numberOfTimes.rawValue] ?? "1") ?? 1) }))
                    } catch {
                        promise(.failure(NSError()))
                    }
                }
                
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getLosses() -> AnyPublisher<[Submission], Error> {
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
                              let list = snapshot[Keys.losses.rawValue] as? [[String: String]]
                        else {
                            promise(.failure(NSError()))
                            return
                        }
               
                        promise(.success(list.map { Submission(id: $0[Keys.id.rawValue] ?? "", subName: $0[Keys.subName.rawValue] ?? "", personName: $0[Keys.person.rawValue], numberOfTimes: Int($0[Keys.numberOfTimes.rawValue] ?? "1") ?? 1) }))
                    } catch {
                        promise(.failure(NSError()))
                    }
                }
                
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func createUploadDict(snapshot: [String : Any], subsList: [String]? = nil, winsDict: [[String: String]]? = nil, lossesDict: [[String: String]]? = nil) -> [String: Any] {
        let oldSubsList = snapshot[Keys.subMissionList.rawValue] as? [String]
        let oldWinsDict = snapshot[Keys.wins.rawValue] as? [[String: String]]
        let oldLossesDict = snapshot[Keys.losses.rawValue] as? [[String: String]]
        
        return [Keys.subMissionList.rawValue: (subsList ?? oldSubsList) ?? [String](), Keys.wins.rawValue: (winsDict ?? oldWinsDict) ?? [[String: String]](), Keys.losses.rawValue: (lossesDict ?? oldLossesDict) ?? [[String: String]]()]
    }
    
}
