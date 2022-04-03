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
    func getData() async throws
    func saveWin(submission: Submission) async throws
    func saveLoss(submission: Submission) async throws
}

class SubmissionsAPI: SubmissionsAPIProtocol {
    enum Keys: String {
        case subMissionList, users, wins, losses, numberOfTimes, id, subName, person
    }
    
    lazy var fireStore = Firestore.firestore()
    
    func addNewSubToList(submissionName: String) async throws {
        guard let uid = Store.shared.loginState?.id else {
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
        await Store.shared.changeState(newState: SubmissionsListState(subs: newList))
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(createUploadDict(snapshot: snapshot, subsList: newList), merge: false)
    }
    
    func saveWin(submission: Submission) async throws {
        guard let uid = Store.shared.loginState?.id else {
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
        
        var winStored = Store.shared.winsState?.subs ?? []
        winStored.append(submission)
        
        await Store.shared.changeState(newState: WinsState(subs: winStored))
        
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(createUploadDict(snapshot: snapshot, winsDict: winsDict), merge: false)
    }
    
    func saveLoss(submission: Submission) async throws {
        guard let uid = Store.shared.loginState?.id else {
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
        
        var lossStored = Store.shared.lossesState?.subs ?? []
        lossStored.append(submission)
        
        await Store.shared.changeState(newState: LossesState(subs: lossStored))
        
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(createUploadDict(snapshot: snapshot, lossesDict: lossesDict), merge: false)
    }
    
    func getData() async throws {
        do {
            let fireStore = Firestore.firestore()
            guard let uid = Store.shared.loginState?.id else {
                throw NSError()
            }
            let snapshot = try await fireStore.collection(Keys.users.rawValue).document(uid).getDocument()
            
            guard snapshot.exists == true,
                  let snapshot = snapshot.data(),
                  let submissionList = snapshot[Keys.subMissionList.rawValue] as? [String],
                  let winsList = snapshot[Keys.wins.rawValue] as? [[String: String]],
                  let lossesList = snapshot[Keys.losses.rawValue] as? [[String: String]]
            else {
                throw NSError()
            }
            await Store.shared.changeState(newState: SubmissionsListState(subs: submissionList.map { $0 }))

            await Store.shared.changeState(newState: WinsState(subs: winsList.map {
                Submission(id: $0[Keys.id.rawValue] ?? "", subName: $0[Keys.subName.rawValue] ?? "", personName: $0[Keys.person.rawValue], numberOfTimes: Int($0[Keys.numberOfTimes.rawValue] ?? "1") ?? 1)
            }))
            
            await Store.shared.changeState(newState: LossesState(subs:lossesList.map {
                Submission(id: $0[Keys.id.rawValue] ?? "", subName: $0[Keys.subName.rawValue] ?? "", personName: $0[Keys.person.rawValue], numberOfTimes: Int($0[Keys.numberOfTimes.rawValue] ?? "1") ?? 1)
            }))
            
        } catch {
            throw NSError()
        }
    }
    
    private func createUploadDict(snapshot: [String : Any], subsList: [String]? = nil, winsDict: [[String: String]]? = nil, lossesDict: [[String: String]]? = nil) -> [String: Any] {
        let oldSubsList = snapshot[Keys.subMissionList.rawValue] as? [String]
        let oldWinsDict = snapshot[Keys.wins.rawValue] as? [[String: String]]
        let oldLossesDict = snapshot[Keys.losses.rawValue] as? [[String: String]]
        
        return [Keys.subMissionList.rawValue: (subsList ?? oldSubsList) ?? [String](), Keys.wins.rawValue: (winsDict ?? oldWinsDict) ?? [[String: String]](), Keys.losses.rawValue: (lossesDict ?? oldLossesDict) ?? [[String: String]]()]
    }
    
}
