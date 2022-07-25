//
//  StoreTests.swift
//  Tap Nap Or SnapTests
//
//  Created by Inti Albuquerque on 25/07/22.
//

import Foundation
import XCTest
@testable import Tap_Nap_Or_Snap

class StoreTests: XCTestCase {
    func testNoRaceConditionsOccur() async {
        let totalCount = 1000
        let group = DispatchGroup()
        let expectation = self.expectation(description: "wait for notify")
        
        // Call `addCount()` asynchronously 1000 times
        for i in 0..<totalCount {
            DispatchQueue.global().async(group: group) {
                Task {
                    let newState = SubmissionNamesState(subs: ["sub\(i)"])
                    await Store.shared.changeState(newState: newState)
                    let sub = await Store.shared.submissionNamesState?.subs[0]
                    if sub != "sub\(i)" {
                        XCTFail()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            // Dispatch group completed execution
            // Show `count` value on label
            expectation.fulfill()
        }
        await waitForExpectations(timeout: 10)
    }
}
