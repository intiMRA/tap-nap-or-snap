//
//  SubmissionDescriptionViewModelTests.swift
//  Tap Nap Or SnapTests
//
//  Created by Inti Albuquerque on 22/07/22.
//

import Foundation
import XCTest
@testable import Tap_Nap_Or_Snap

class SubmissionDescriptionViewModelTests: XCTestCase {
    func testSaveDescription() async {
        let sub = Submission(personName: "john",
                             subName: "Armbar",
                             wins: 2,
                             losses: 1,
                             winDescription: "won twice",
                             lossesDescription: "rip")
        await Store.shared.changeState(newState: SubmissionsState(subs: ["Armbar": [sub]]))
        let center = MockNotificationCenter()
        center.expectation = self.expectation(description: "wait for subupdate")
        await Store.shared.setNotificationCenter(notificationCenter: center)
        let api = MockSubmissionsApi()
        let vm = await SubmissionDescriptionViewModel(title: "john",
                                                      subName: "Armbar",
                                                      personName: "john",
                                                      submission:  sub,
                                                      api: api)
        await MainActor.run {
            vm.winDescription = "well we won"
            vm.lossesDescription = "lies"
        }
        
        await vm.saveDescriptions()
        await waitForExpectations(timeout: 10)
        let savedSub = await Store.shared.submissionsState?.subs["Armbar"]?[0]
        XCTAssertEqual(savedSub?.personName, sub.personName)
        
        XCTAssertEqual(savedSub?.winDescription, "well we won")
        XCTAssertEqual(savedSub?.lossesDescription, "lies")
    }
}
