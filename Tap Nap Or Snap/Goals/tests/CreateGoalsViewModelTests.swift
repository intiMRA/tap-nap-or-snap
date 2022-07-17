//
//  CreateGoalsViewModelTests.swift
//  Tap Nap Or SnapTests
//
//  Created by Inti Albuquerque on 15/07/22.
//

import Foundation
import XCTest
@testable import Tap_Nap_Or_Snap
class CreateGoalsViewModelTests: XCTestCase {
    func testSaveGoal() async {
        let api = MockGoalsAPI()
        let center = MockNotificationCenter()
        center.expectation = self.expectation(description: "wait for goal to be saved")
        await Store.shared.setNotificationCenter(notificationCenter: center)
        let vm = await CreateNewGoalViewModel(api: api)
        await MainActor.run {
            vm.description = "description"
            vm.numberOfDays = "2"
            vm.title = "test"
            vm.timeToComplete = .years
        }
        
        await vm.saveGoal()
        
        await waitForExpectations(timeout: 10)
        
        let goal = await Store.shared.goalsState?.goals[0]
        XCTAssertEqual(goal?.description, "description")
        XCTAssertEqual(goal?.title, "test")
        XCTAssertEqual(goal?.isComplete, false)
    }
}
