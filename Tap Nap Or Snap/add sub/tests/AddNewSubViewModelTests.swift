//
//  AddNewSubViewModelTests.swift
//  Tap Nap Or SnapTests
//
//  Created by Inti Albuquerque on 19/07/22.
//

import Foundation
import XCTest
@testable import Tap_Nap_Or_Snap
class AddNewSubViewModelTests: XCTestCase {
    func testChosenSub() async {
        let vm = await AddNewSubViewModel()
        await vm.setChosenSub("test")
        let set = await vm.chosenSub
        let subNameState = await vm.fieldsToHighlight.subName
        let nameState = await vm.fieldsToHighlight.name
        XCTAssertFalse(subNameState)
        XCTAssertFalse(nameState)
        XCTAssertEqual(set, "test")
    }
    
    func testChosenSubHighlight() async {
        let vm = await AddNewSubViewModel()
        await vm.setChosenSub("")
        let set = await vm.chosenSub
        let subNameState = await vm.fieldsToHighlight.subName
        let nameState = await vm.fieldsToHighlight.name
        XCTAssertTrue(subNameState)
        XCTAssertFalse(nameState)
        XCTAssertEqual(set, nil)
    }
    
    func testSaveSub() async {
        let api = MockSubmissionsApi()
        let center = MockNotificationCenter()
        center.expectation = self.expectation(description: "wait for sub to be saved")
        await Store.shared.setNotificationCenter(notificationCenter: center)
        let vm = await AddNewSubViewModel(api: api)
        await MainActor.run {
            vm.chosenSub = "armbar"
            vm.name = "testName"
            vm.description = "description"
            vm.newSubName = "armbar"
        }
        await vm.saveWholeSub()
        await waitForExpectations(timeout: 10)
        let subs = await Store.shared.submissionsState?.subs["Armbar"]
        let names = await Store.shared.submissionNamesState?.subs[0]
        XCTAssertEqual(names, "Armbar")
        XCTAssertEqual(subs![0].subName, "Armbar")
        XCTAssertEqual(subs![0].personName, "testName")
        XCTAssertEqual(subs![0].winDescription, "description")
    }
    
    func testDeleteSub() async {
        let api = MockSubmissionsApi()
        let center = MockNotificationCenter()
        center.expectation = self.expectation(description: "wait for sub to be deleted")
        await Store.shared.setNotificationCenter(notificationCenter: center)
        await Store.shared.changeState(newState: SubmissionNamesState(subs: ["Armbar"]))
        let vm = await AddNewSubViewModel(api: api)
        await vm.deleteSubFromList(with: 0)
        await waitForExpectations(timeout: 10)
        let names = await Store.shared.submissionNamesState?.subs
        XCTAssertEqual(names, [])
    }
}

class MockSubmissionsApi: SubmissionsAPIProtocol {
    func addNewSubToList(submissionName: String) async throws {
        var list = await Store.shared.submissionNamesState?.subs ?? []
        list.append(submissionName)
        await Store.shared.changeState(newState: SubmissionNamesState(subs: list))
    }
    
    func saveWin(submission: SubmissionUploadModel) async throws {
        try await addNewSubToList(submissionName: submission.subName)
        var list = await Store.shared.submissionsState?.subs[submission.subName] ?? []
        let sub = Submission(personName: submission.personName,
                              subName: submission.subName,
                              wins: 1,
                              losses: 0,
                              winDescription: submission.description,
                              lossesDescription: submission.description)
        list.append(sub)
        await Store.shared.changeState(newState: SubmissionsState(subs: [submission.subName : list]))
    }
    
    func saveLoss(submission: SubmissionUploadModel) async throws {
        try await addNewSubToList(submissionName: submission.subName)
        var list = await Store.shared.submissionsState?.subs[submission.subName] ?? []
        let sub = Submission(personName: submission.personName,
                              subName: submission.subName,
                              wins: 0,
                              losses: 1,
                              winDescription: submission.description,
                              lossesDescription: submission.description)
        list.append(sub)
        await Store.shared.changeState(newState: SubmissionsState(subs: [submission.subName : list]))
    }
    
    func deleteSubFromList(with submissionName: String) async throws {
        var list = await Store.shared.submissionNamesState?.subs ?? []
        list.removeAll(where: { $0 == submissionName })
        await Store.shared.changeState(newState: SubmissionNamesState(subs: list))
    }
    
    func saveSubmissionDescriptions(submissionName: String, personName: String, winDescription: String?, lossDescription: String?) async throws {
        var list = await Store.shared.submissionsState?.subs[submissionName] ?? []
        let sub = list.first(where: { $0.personName == personName })
        let newSub = Submission(personName: personName,
                                subName: submissionName,
                                wins: sub?.wins ?? 0,
                                losses: sub?.losses ?? 0,
                                winDescription: winDescription ?? "",
                                lossesDescription: lossDescription ?? "")
        list.append(newSub)
        await Store.shared.changeState(newState: SubmissionsState(subs: [submissionName : list]))
    }
    
    
}
