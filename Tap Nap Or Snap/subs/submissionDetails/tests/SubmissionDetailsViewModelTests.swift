//
//  SubmissionDetailsViewModelTests.swift
//  Tap Nap Or SnapTests
//
//  Created by Inti Albuquerque on 22/07/22.
//

import Foundation
import XCTest
@testable import Tap_Nap_Or_Snap

class SubmissionDetailsViewModelTests: XCTestCase {
    func testPluralWorks() async {
        let subs = [
        Submission(personName: "john",
                   subName: "Armbar",
                   wins: 2,
                   losses: 1,
                   winDescription: "won twice",
                   lossesDescription: "rip")
        ]
        let vm = await SubmissionDetailsViewModel(submissionsList: subs, submissionName: "Armbar")
        let wins = await vm.getWinsCountCopy(for: subs[0])
        let losses = await vm.getLossesCountCopy(for: subs[0])
        await vm.showDescription(for: "john")
        let personName = await vm.currentPersonsName
        let nav = await vm.navigateToDescription
        XCTAssertEqual("2 Times", wins)
        XCTAssertEqual("1 Time", losses)
        XCTAssertEqual(personName, "john")
        XCTAssertTrue(nav)
        let descriptionVm = await vm.createDescriptionViewModel()
        let descriptionPersonName = await descriptionVm.personName
        let descriptionSubName = await descriptionVm.subName
        let winDescription = await descriptionVm.winDescription
        let lossDescription = await descriptionVm.lossesDescription
        XCTAssertEqual(descriptionPersonName, "john")
        XCTAssertEqual(descriptionSubName, "Armbar")
        XCTAssertEqual(winDescription, "won twice")
        XCTAssertEqual(lossDescription, "rip")
    }
}
