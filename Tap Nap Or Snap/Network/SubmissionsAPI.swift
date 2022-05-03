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
         id,
         subName,
         person,
         goals,
         title,
         timeStamp,
         description,
         submissions
}

enum SubmissionKeys: String {
    case wins, losses
}

struct SubmissionsModel {
    let wins: [Submission]
    let losses: [Submission]
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
            await Store.shared.changeState(newState: SubmissionNamesState(subs: [submissionName]))
            try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
            return
        }
        guard !list.contains(where: { $0 == submissionName}) else {
            return
        }
        
        list.append(submissionName)
        await Store.shared.changeState(newState: SubmissionNamesState(subs: list))
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
    }
    
    private func saveSubmission(key: SubmissionKeys, submission: Submission) async throws {
        guard let uid = Store.shared.loginState?.id else {
            return
        }
        
        try await addNewSubToList(submissionName: submission.subName)
        let snapshot = try await self.fireStore.collection(Keys.users.rawValue).document(uid).getDocument()
        
        guard snapshot.exists == true,
              var snapshot = snapshot.data()
        else {
            return
        }
        
        var submissions = (snapshot[Keys.submissions.rawValue] as? [String: [String: [[String: String]]]]) ?? [:]
        var currentSubmission = submissions[submission.subName] ?? [:]
        
        guard var subsToReplace = currentSubmission[key.rawValue] else {
            let list = [[Keys.id.rawValue: submission.id, Keys.subName.rawValue: submission.subName, Keys.person.rawValue: submission.personName ?? ""]]
            currentSubmission[key.rawValue] = list
            submissions[submission.subName] = currentSubmission
            snapshot[Keys.submissions.rawValue] = submissions
            try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
            
            return
        }
        
        subsToReplace.append([Keys.id.rawValue: submission.id, Keys.subName.rawValue: submission.subName, Keys.person.rawValue: submission.personName ?? ""])
        currentSubmission[key.rawValue] = subsToReplace
        
        submissions[submission.subName] = currentSubmission
        
        snapshot[Keys.submissions.rawValue] = submissions
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
    }
    
    func saveWin(submission: Submission) async throws {
        try await saveSubmission(key: .wins, submission: submission)
        var submissions = Store.shared.submissionsState?.subs ?? [:]
        let currentSubmission = submissions[submission.subName]
        var wins = currentSubmission?.wins ?? []
        wins.append(submission)
        let subModel = SubmissionsModel(wins: wins, losses: currentSubmission?.losses ?? [])
        submissions[submission.subName] = subModel
        
        await Store.shared.changeState(newState: SubmissionsState(subs: submissions))
    }
    
    func saveLoss(submission: Submission) async throws {
        try await saveSubmission(key: .losses, submission: submission)
        var submissions = Store.shared.submissionsState?.subs ?? [:]
        let currentSubmission = submissions[submission.subName]
        var losses = currentSubmission?.losses ?? []
        losses.append(submission)
        let subModel = SubmissionsModel(wins: currentSubmission?.wins ?? [], losses: losses)
        submissions[submission.subName] = subModel
        
        await Store.shared.changeState(newState: SubmissionsState(subs: submissions))
    }
}

extension Dictionary where Value == Array<[String: String]> {
    mutating func append(key: Key, element: [String: String]) {
        if self[key] != nil {
            self[key]?.append(element)
        } else {
            self[key] = [element]
        }
    }
}
