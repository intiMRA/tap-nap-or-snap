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
    func saveWin(submission: SubmissionUploadModel) async throws
    func saveLoss(submission: SubmissionUploadModel) async throws
    func deleteSubFromList(with submissionName: String) async throws
    func saveSubmissionDescriptions(submissionName: String, personName: String, winDescription: String?, lossDescription: String?) async throws
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
    case wins, losses, winsDescription, lossesDescription
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
        snapshot[Keys.subMissionList.rawValue] = list
        await Store.shared.changeState(newState: SubmissionNamesState(subs: list))
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
    }
    
    func deleteSubFromList(with submissionName: String) async throws {
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
            return
        }
        
        guard list.contains(where: { $0 == submissionName }) else {
            return
        }
        
        list.removeAll(where: { $0 == submissionName })
        snapshot[Keys.subMissionList.rawValue] = list
        await Store.shared.changeState(newState: SubmissionNamesState(subs: list))
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
    }
    
    private func saveSubmission(key: SubmissionKeys, submission: SubmissionUploadModel) async throws {
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
        
        var submissions = (snapshot[Keys.submissions.rawValue] as? [String: [String: Any]]) ?? [:]
        var currentSubmission = submissions[submission.subName]  ?? [:]
        let currentPerson = currentSubmission[submission.personName] as? [String: Any] ?? [:]
        
        var wins = (currentPerson[SubmissionKeys.wins.rawValue] as? Int) ?? 0
        var losses = (currentPerson[SubmissionKeys.losses.rawValue] as? Int) ?? 0
        var winsDescription = (currentPerson[SubmissionKeys.winsDescription.rawValue] as? String) ?? ""
        var lossesDescription = (currentPerson[SubmissionKeys.lossesDescription.rawValue] as? String) ?? ""
        wins += key == .wins ? 1 : 0
        losses += key == .losses ? 1 : 0
        winsDescription = "\(winsDescription)\(key == .wins ? "\n\(submission.description)" : "")"
        lossesDescription = "\(lossesDescription)\(key == .losses ? "\n\(submission.description)" : "")"
        
        let dict: [String: Any] = [
            SubmissionKeys.wins.rawValue: wins,
            SubmissionKeys.losses.rawValue: losses,
            SubmissionKeys.winsDescription.rawValue: winsDescription,
            SubmissionKeys.lossesDescription.rawValue: lossesDescription
        ]
        
        currentSubmission[submission.personName] = dict
        submissions[submission.subName] = currentSubmission
        snapshot[Keys.submissions.rawValue] = submissions
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
    }
    
    func saveWin(submission: SubmissionUploadModel) async throws {
        try await saveSubmission(key: .wins, submission: submission)
        var submissions = Store.shared.submissionsState?.subs ?? [:]
        var submissionsByName = submissions[submission.subName]
        let currentSubmission = submissionsByName?.first(where: { $0.personName == submission.personName })
        
        submissionsByName?.removeAll(where: { $0.personName == submission.personName })
        let winDescription = currentSubmission?.winDescription != nil ? "\(currentSubmission!.winDescription)\n" : ""
        let lossesDescription = currentSubmission?.lossesDescription != nil ? "\(currentSubmission!.lossesDescription)\n" : ""
        let updatedSub = Submission(
            personName: submission.personName,
            subName: submission.subName,
            wins: (currentSubmission?.wins ?? 0) + 1,
            losses: currentSubmission?.losses ?? 0,
            winDescription: winDescription,
            lossesDescription: lossesDescription)
        
        submissionsByName?.append(updatedSub)
        
        
        submissions[submission.subName] = submissionsByName ?? [updatedSub]
        
        await Store.shared.changeState(newState: SubmissionsState(subs: submissions))
    }
    
    func saveLoss(submission: SubmissionUploadModel) async throws {
        try await saveSubmission(key: .losses, submission: submission)
        var submissions = Store.shared.submissionsState?.subs ?? [:]
        var submissionsByName = submissions[submission.subName]
        let currentSubmission = submissionsByName?.first(where: { $0.personName == submission.personName })
        
        submissionsByName?.removeAll(where: { $0.personName == submission.personName })
        
        let updatedSub = Submission(
            personName: submission.personName,
            subName: submission.subName,
            wins: currentSubmission?.wins ?? 0,
            losses: (currentSubmission?.losses ?? 0) + 1,
            winDescription: currentSubmission?.winDescription ?? "",
            lossesDescription:"\(currentSubmission?.lossesDescription ?? "")\n\(submission.description)")
        
        submissionsByName?.append(updatedSub)
        
        
        submissions[submission.subName] = submissionsByName ?? [updatedSub]
        
        await Store.shared.changeState(newState: SubmissionsState(subs: submissions))
    }
    
    func saveSubmissionDescriptions(submissionName: String, personName: String, winDescription: String?, lossDescription: String?) async throws {
        guard let uid = Store.shared.loginState?.id else {
            return
        }
        
        let snapshot = try await self.fireStore.collection(Keys.users.rawValue).document(uid).getDocument()
        
        guard snapshot.exists == true,
              var snapshot = snapshot.data(),
              var submissions = (snapshot[Keys.submissions.rawValue] as? [String: [String: [String: Any]]]),
              var submissionByName = submissions[submissionName],
              var currentSub = submissionByName[personName],
              var storedSubs = Store.shared.submissionsState?.subs,
              var storedSubByName = storedSubs[submissionName]
        else {
            return
        }
        
        currentSub[SubmissionKeys.winsDescription.rawValue] = winDescription ?? (currentSub[SubmissionKeys.winsDescription.rawValue] ?? "")
        
        currentSub[SubmissionKeys.lossesDescription.rawValue] = lossDescription ?? (currentSub[SubmissionKeys.lossesDescription.rawValue] ?? "")
        
        submissionByName[personName] = currentSub
        
        submissions[submissionName] = submissionByName
        
        snapshot[Keys.submissions.rawValue] = submissions
        
        try await self.fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
        
        storedSubByName.removeAll(where: { $0.personName == personName })
        
        storedSubByName.append(Submission(from: currentSub, subName: submissionName, personName: personName))
        
        storedSubs[submissionName] = storedSubByName
        
        await Store.shared.changeState(newState: SubmissionsState(subs: storedSubs))
    }
    
    private func emptySubDescription(subsDict: [String: String], name: String) -> [String: String] {
        guard name == subsDict[Keys.person.rawValue] else {
            return subsDict
        }
        
        var newDict: [String: String] = [:]
        subsDict.forEach { (key, value) in
            if key == Keys.description.rawValue {
                newDict[key] = ""
            } else {
                newDict[key] = value
            }
        }
        return newDict
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
