//
//  EditGoalViewModelTests.swift
//  Tap Nap Or SnapTests
//
//  Created by Inti Albuquerque on 13/07/22.
//

import Foundation
import XCTest
@testable import Tap_Nap_Or_Snap

class EditGoalViewModelTests: XCTestCase {
    func testSaveDescription() async {
        let goal = GoalModel(id: "id",
                             title: "title",
                             description: "description",
                             timeStamp: "20/11/1196".asDate()!,
                             isComplete: false,
                             isMultiline: false)
        await Store.shared.changeState(newState: GoalsState(goals: [goal]))
        let center = MockNotificationCenter()
        center.expectation = self.expectation(description: "wait for notification")
        await Store.shared.setNotificationCenter(notificationCenter: center)
        let api = MockGoalsAPI()

        let vm = await EditGoalDetailsViewModel(currentGoal: goal, api: api)
        await MainActor.run {
            vm.description = "new description"
        }
        await vm.saveDescription()
        
        await waitForExpectations(timeout: 10)
    }
}

class MockGoalsAPI: GoalsAPIProtocol {
    func addNewGoal(goal: GoalModel) async throws {
        var goals = await Store.shared.goalsState?.goals ?? []
        goals.append(goal)
        await Store.shared.changeState(newState: GoalsState(goals: goals))
    }
    
    func deleteGoal(with id: String) async throws {
        var goals = await Store.shared.goalsState?.goals ?? []
        goals.removeAll(where: { $0.id == id })
        await Store.shared.changeState(newState: GoalsState(goals: goals))
    }
    
    func goalCompletion(status: Bool, id: String) async throws {
        var goals = await Store.shared.goalsState?.goals ?? []
        let goal = goals.first(where: { $0.id == id })!
        goals.removeAll(where: { $0.id == id })
        goals.append(GoalModel(id: id,
                               title: goal.title,
                               description: goal.description,
                               timeStamp: goal.timeStamp,
                               isComplete: status,
                               isMultiline: goal.isMultiline))
        await Store.shared.changeState(newState: GoalsState(goals: goals))
    }
    
    func editGoalDescription(with id: String, description: String) async throws {
        var goals = await Store.shared.goalsState?.goals ?? []
        let goal = goals.first(where: { $0.id == id })!
        goals.removeAll(where: { $0.id == id })
        goals.append(GoalModel(id: id,
                               title: goal.title,
                               description: description,
                               timeStamp: goal.timeStamp,
                               isComplete: goal.isComplete,
                               isMultiline: goal.isMultiline))
        await Store.shared.changeState(newState: GoalsState(goals: goals))
    }
}

class MockNotificationCenter: NotificationCenter {
    var expectation: XCTestExpectation?
    var expectedCount = 1
    private var count = 1
    override func post(_ notification: Notification) {
        if count >= expectedCount {
            expectation?.fulfill()
            expectation = nil
        }
        count += 1
    }
}
