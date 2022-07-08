//
//  AddSubsTest.swift
//  Tap Nap Or SnapTests
//
//  Created by Inti Albuquerque on 8/07/22.
//

import Foundation
import XCTest
@testable import Tap_Nap_Or_Snap

class AddSubsTest: XCTestCase {
    func testSaveSub() {
        Task {
            let store = MockStore()
            let api = MockSubmissionsApi()
            api.store = store
            
            let vm = await AddNewSubViewModel(api: api, store: store)
            await MainActor.run {
                vm.description = "test"
                vm.isWin = true
                vm.name = "test"
                vm.newSubName = "text"
                vm.chosenSub = "Armbar"
            }
            
            await vm.saveWholeSub()
            
            let name = await store.submissionNamesState?.subs[0]
            XCTAssertEqual(name, "Armbar")
            
            let sub = await store.submissionsState?.subs["Armbar"]?[0]
            XCTAssertEqual(sub?.subName, "Armbar")
            XCTAssertEqual(sub?.personName, "test")
        }
    }
}

class MockSubmissionsApi: SubmissionsAPIProtocol {
    var store: MockStore?
    
    func addNewSubToList(submissionName: String) async throws {
        var subList = await store?.submissionNamesState?.subs ?? []
        subList.append(submissionName)
        let subState = SubmissionNamesState(subs: subList)
        await store?.changeState(newState: subState)
    }
    
    func saveWin(submission: SubmissionUploadModel) async throws {
        var currentSubs = await store?.submissionsState?.subs[submission.subName] ?? []
        currentSubs.append(Submission(from: submission, isWin: true))
        let subs = SubmissionsState(subs: [submission.subName: currentSubs])
        await store?.changeState(newState: subs)
    }
    
    func saveLoss(submission: SubmissionUploadModel) async throws {
        var currentSubs = await store?.submissionsState?.subs[submission.subName] ?? []
        currentSubs.append(Submission(from: submission, isWin: false))
        let subs = SubmissionsState(subs: [submission.subName: currentSubs])
        await store?.changeState(newState: subs)
    }
    
    func deleteSubFromList(with submissionName: String) async throws {
        var subList = await store?.submissionNamesState?.subs ?? []
        subList.removeAll(where: { $0 == submissionName })
        let subState = SubmissionNamesState(subs: subList)
        await store?.changeState(newState: subState)

    }
    
    func saveSubmissionDescriptions(submissionName: String, personName: String, winDescription: String?, lossDescription: String?) async throws {
        guard var currentSubs = await store?.submissionsState?.subs[submissionName] else {
            return
        }
        currentSubs.removeAll(where: { $0.personName == personName })
        let sub = Submission(personName: personName,
                             subName: submissionName,
                             wins: 1,
                             losses: 0,
                             winDescription: winDescription ?? "",
                             lossesDescription: lossDescription ?? "")
        currentSubs.append(sub)
        let subs = SubmissionsState(subs: [submissionName: currentSubs])
        await store?.changeState(newState: subs)
    }

}

extension Submission {
    init(from model: SubmissionUploadModel, isWin: Bool) {
        self.init(personName: model.personName,
                  subName: model.subName,
                  wins: isWin ? 1 : 0,
                  losses: isWin ? 0 : 1,
                  winDescription: isWin ? model.description : "",
                  lossesDescription: isWin ? "" : model.description)
    }
}
