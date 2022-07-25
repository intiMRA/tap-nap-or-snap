//
//  GoalsViewModelTests.swift
//  Tap Nap Or SnapTests
//
//  Created by Inti Albuquerque on 14/07/22.
//

import Foundation
import XCTest
@testable import Tap_Nap_Or_Snap

class GoalsViewModelTests: XCTestCase {
    func testDeleteGoal() async {
        let api = MockGoalsAPI()
        let goals = [
            GoalModel(id: "id",
                      title: "title",
                      description: "description",
                      timeStamp: "20/11/1996".asDate()!,
                      isComplete: false,
                      isMultiline: true),
            GoalModel(id: "id2",
                      title: "title2",
                      description: "description2",
                      timeStamp: "20/11/1996".asDate()!,
                      isComplete: false,
                      isMultiline: true)
        ]
        let center = MockNotificationCenter()
        center.expectedCount = 2
        center.expectation = self.expectation(description: "wait for goal to be deleted")
        await Store.shared.changeState(newState: GoalsState(goals: goals))
        await Store.shared.setNotificationCenter(notificationCenter: center)
        let vm = await GoalsViewModel(goalsApi: api)
        await vm.deleteGoal(with: "id")
        await waitForExpectations(timeout: 10)
        let vmGoals = await vm.goalModels
        XCTAssertEqual([GoalModel(id: "id2",
                                  title: "title2",
                                  description: "description2",
                                  timeStamp: "20/11/1996".asDate()!,
                                  isComplete: false,
                                  isMultiline: true)], vmGoals)
    }
    
    func testCompleteGoal() async {
        let api = MockGoalsAPI()
        let goals = [
            GoalModel(id: "id",
                      title: "title",
                      description: "description",
                      timeStamp: "20/11/1996".asDate()!,
                      isComplete: false,
                      isMultiline: true),
            GoalModel(id: "id2",
                      title: "title2",
                      description: "description2",
                      timeStamp: "20/11/1996".asDate()!,
                      isComplete: false,
                      isMultiline: true)
        ]
        let center = MockNotificationCenter()
        center.expectation = self.expectation(description: "wait for goal to be complete")
        await Store.shared.changeState(newState: GoalsState(goals: goals))
        await Store.shared.setNotificationCenter(notificationCenter: center)
        let vm = await GoalsViewModel(goalsApi: api)
        await vm.completeGoal(with: "id", status: true)
        await waitForExpectations(timeout: 10)
        let vmGoals = await vm.goalModels
        XCTAssertEqual([
            GoalModel(id: "id2",
                      title: "title2",
                      description: "description2",
                      timeStamp: "20/11/1996".asDate()!,
                      isComplete: false,
                      isMultiline: true),
            GoalModel(id: "id",
                      title: "title",
                      description: "description",
                      timeStamp: "20/11/1996".asDate()!,
                      isComplete: true,
                      isMultiline: true)], vmGoals)
    }
}
