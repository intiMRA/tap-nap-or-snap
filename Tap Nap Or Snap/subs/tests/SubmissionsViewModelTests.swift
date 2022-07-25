//
//  SubmissionsViewModelTests.swift
//  Tap Nap Or SnapTests
//
//  Created by Inti Albuquerque on 25/07/22.
//

import Foundation
import XCTest
@testable import Tap_Nap_Or_Snap
class SubmissionsViewModelTests: XCTestCase {
    func testCopy() async {
        let subs = [Submission(personName: "personName",
                               subName: "Armbar",
                               wins: 3,
                               losses: 2,
                               winDescription: "winDescription",
                               lossesDescription: "lossesDescription"),
                    Submission(personName: "personName2",
                                           subName: "Armbar",
                                           wins: 0,
                                           losses: 9,
                                           winDescription: "winDescription2",
                                           lossesDescription: "lossesDescription2")]
        
        await Store.shared.changeState(newState: SubmissionsState(subs: ["Armbar": subs]))
        let vm = await SubmissionsViewModel()
        
        let wins = await vm.getWinsCountCopy(for: "Armbar")
        let losses = await vm.getLossesCountCopy(for: "Armbar")
        
        XCTAssertEqual("3 Times", wins)
        XCTAssertEqual("11 Times", losses)
        
    }
}
