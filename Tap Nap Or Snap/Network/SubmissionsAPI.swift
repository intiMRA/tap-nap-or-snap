//
//  SubmissionsAPI.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 21/03/22.
//

import Foundation
import FirebaseFirestore

protocol SubmissionsAPIProtocol {
    func addNewSubToList(submissionName: String) async throws
    func saveWin(submission: Submission) async throws
    func saveLoss(submission: Submission) async throws
}

enum Keys: String {
    case subMissionList,
         users,
         wins,
         losses,
         numberOfTimes,
         id,
         subName,
         person,
         goals,
         title,
         timeStamp,
         description
}

class SubmissionsAPI: SubmissionsAPIProtocol {
    
    lazy var fireStore = Firestore.firestore()
    
    func addNewSubToList(submissionName: String) async throws {
        guard let uid = Store.shared.loginState?.id else {
            return
        }
        let snapshot = try await self.fireStore.collection(Keys.users.rawValue).document(uid).getDocument()
        
        guard snapshot.exists == true,
              var snapshot = snapshot.data()
        else {
            return
        }
        
        guard var list = snapshot[Keys.subMissionList.rawValue] as? [String] else {
            snapshot[Keys.subMissionList.rawValue] = [submissionName]
            await Store.shared.changeState(newState: SubmissionsListState(subs: [submissionName]))
            try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
            return
        }
        
        list.append(submissionName)
        await Store.shared.changeState(newState: SubmissionsListState(subs: list))
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
    }
    
    func saveWin(submission: Submission) async throws {
        guard let uid = Store.shared.loginState?.id else {
            return
        }
        let snapshot = try await self.fireStore.collection(Keys.users.rawValue).document(uid).getDocument()
        
        guard snapshot.exists == true,
              var snapshot = snapshot.data()
        else {
            return
        }
        
        guard var wins = snapshot[Keys.wins.rawValue] as? [[String: String]] else {
            let list = [[Keys.id.rawValue: submission.id, Keys.subName.rawValue: submission.subName, Keys.person.rawValue: submission.personName ?? "", Keys.numberOfTimes.rawValue: "\(submission.numberOfTimes)"]]
            snapshot[Keys.wins.rawValue] = list
            
            var winStored = Store.shared.winsState?.subs ?? []
            winStored.append(submission)
            
            await Store.shared.changeState(newState: WinsState(subs: winStored))
            
            try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
            
            return
        }
        
        if wins.first(where: { $0[Keys.person.rawValue] == submission.personName &&  $0[Keys.subName.rawValue] == submission.subName }) != nil {
            wins = wins.map({ dict in
                if dict[Keys.person.rawValue] == submission.personName, dict[Keys.subName.rawValue] == submission.subName {
                    let numberOfTimes = Int(dict[Keys.numberOfTimes.rawValue] ?? "0")
                    return [Keys.id.rawValue: submission.id, Keys.subName.rawValue: submission.subName, Keys.person.rawValue: submission.personName ?? "", Keys.numberOfTimes.rawValue: "\(submission.numberOfTimes + (numberOfTimes ?? 0))"]
                } else {
                    return dict
                }
            })
        } else {
            wins.append([Keys.id.rawValue: submission.id, Keys.subName.rawValue: submission.subName, Keys.person.rawValue: submission.personName ?? "", Keys.numberOfTimes.rawValue: "\(submission.numberOfTimes)"])
        }
        
        var winStored = Store.shared.winsState?.subs ?? []
        winStored.append(submission)
        
        await Store.shared.changeState(newState: WinsState(subs: winStored))
        snapshot[Keys.wins.rawValue] = wins
        
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
    }
    
    func saveLoss(submission: Submission) async throws {
        guard let uid = Store.shared.loginState?.id else {
            return
        }
        let snapshot = try await self.fireStore.collection(Keys.users.rawValue).document(uid).getDocument()
        
        guard snapshot.exists == true,
              var snapshot = snapshot.data()
        else {
            return
        }
        
        guard var losses = snapshot[Keys.losses.rawValue] as? [[String: String]] else {
            let list = [[Keys.id.rawValue: submission.id, Keys.subName.rawValue: submission.subName, Keys.person.rawValue: submission.personName ?? "", Keys.numberOfTimes.rawValue: "\(submission.numberOfTimes)"]]
            snapshot[Keys.losses.rawValue] = list
            
            var lossesStored = Store.shared.lossesState?.subs ?? []
            lossesStored.append(submission)
            
            await Store.shared.changeState(newState: LossesState(subs: lossesStored))
            
            try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
            return
        }
        
        if losses.first(where: { $0[Keys.person.rawValue] == submission.personName &&  $0[Keys.subName.rawValue] == submission.subName }) != nil {
            losses = losses.map({ dict in
                if dict[Keys.person.rawValue] == submission.personName, dict[Keys.subName.rawValue] == submission.subName {
                    let numberOfTimes = Int(dict[Keys.numberOfTimes.rawValue] ?? "0")
                    return [Keys.id.rawValue: submission.id, Keys.subName.rawValue: submission.subName, Keys.person.rawValue: submission.personName ?? "", Keys.numberOfTimes.rawValue: "\(submission.numberOfTimes + (numberOfTimes ?? 0))"]
                } else {
                    return dict
                }
            })
        } else {
            losses.append([Keys.id.rawValue: submission.id, Keys.subName.rawValue: submission.subName, Keys.person.rawValue: submission.personName ?? "", Keys.numberOfTimes.rawValue: "\(submission.numberOfTimes)"])
        }
        
        var lossesStored = Store.shared.lossesState?.subs ?? []
        lossesStored.append(submission)
        
        await Store.shared.changeState(newState: LossesState(subs: lossesStored))
        snapshot[Keys.losses.rawValue] = losses
        
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
    }
}
