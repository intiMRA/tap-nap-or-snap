//
//  GoalsTests.swift
//  Tap Nap Or SnapTests
//
//  Created by Inti Albuquerque on 4/07/22.
//

import Foundation
import XCTest
@testable import Tap_Nap_Or_Snap

class GoalsTests: XCTestCase {
    
    func testReload() {
        Task {
            let store = MockStore()
            await store.changeState(newState: GoalsState(goals: [GoalModel(id: "test", title: "test", description: "test", timeStamp: "01/02/1999".asDate()!, isComplete: true, isMultiline: true)]))
            let api = MockGoalsApi()
            api.store = store
            
            let vm = await GoalsViewModel(goalsApi: api, store: store)
            
            await vm.reloadState()
            let vmGoals = await vm.goalModels
            
            XCTAssertEqual([GoalModel(id: "test", title: "test", description: "test", timeStamp: "01/02/1999".asDate()!, isComplete: true, isMultiline: true)], vmGoals)
        }
    }
    
    func testDeleteGoal() {
        Task {
            let store = MockStore()
            let goal = GoalModel(id: "test", title: "test", description: "test", timeStamp: "01/02/1999".asDate()!, isComplete: true, isMultiline: true)
            
            await store.changeState(newState: GoalsState(goals: [goal]))
            let api = MockGoalsApi()
            api.store = store
            
            let vm = await GoalsViewModel(goalsApi: api, store: store)
            
            await vm.deleteGoal(with: "test")
            
            let vmGoals = await vm.goalModels
            
            XCTAssertEqual([], vmGoals)
        }
    }
    
    func testCompleteGoal() {
        Task {
            let store = MockStore()
            let goal = GoalModel(id: "test", title: "test", description: "test", timeStamp: "01/02/1999".asDate()!, isComplete: true, isMultiline: true)
            
            await store.changeState(newState: GoalsState(goals: [goal]))
            let api = MockGoalsApi()
            api.store = store
            
            let vm = await GoalsViewModel(goalsApi: api, store: store)
            
            await vm.completeGoal(with: "test", status: false)
            
            let vmGoals = await vm.goalModels
            
            XCTAssertFalse(vmGoals[0].isComplete)
        }
    }

    
    func testShowAddGoal() {
        Task {
            let store = MockStore()
            let api = MockGoalsApi()
            api.store = store
            
            let vm = await GoalsViewModel(goalsApi: api, store: store)
            
            await vm.showAddGoal()
            
            let showAddGoal = await vm.navigateToEditGoal
            
            XCTAssertTrue(showAddGoal)
        }
    }
    
    func testShowEdit() {
        Task {
            let store = MockStore()
            let goal = GoalModel(id: "test", title: "test", description: "test", timeStamp: "01/02/1999".asDate()!, isComplete: true, isMultiline: true)
            let api = MockGoalsApi()
            api.store = store
            
            let vm = await GoalsViewModel(goalsApi: api, store: store)
            
            await vm.showEditGoal(currentGoal: goal)
            let current = await vm.currentGoal
            
            XCTAssertEqual(goal, current)
        }
    }
}

class MockGoalsApi: GoalsAPIProtocol {
    var store: MockStore?
    func addNewGoal(goal: GoalModel) async throws {
        await store?.changeState(newState: GoalsState(goals: [goal]))
    }
    
    func deleteGoal(with id: String) async throws {
        var list = await store?.goalsState?.goals
        list?.removeAll(where: { $0.id == id })
        await store?.changeState(newState: GoalsState(goals: list ?? []))
    }
    
    func goalCompletion(status: Bool, id: String) async throws {
        let list = await store?.goalsState?.goals
        await store?.changeState(newState: GoalsState(goals: list?.map { GoalModel(from: $0, isComplete: $0.id == id ? status : $0.isComplete) } ?? []))
    }
    
    func editGoalDescription(with id: String, description: String) async throws {
        let list = await store?.goalsState?.goals
        await store?.changeState(newState: GoalsState(goals: list?.map { GoalModel(from: $0, description: $0.id == id ? description : $0.description) } ?? []))
    }
}

extension GoalModel {
    init(from model: GoalModel, isComplete: Bool? = nil, description: String? = nil) {
        self.init(id: model.id,
                  title: model.title,
                  description: description ?? model.description,
                  timeStamp: model.timeStamp,
                  isComplete: isComplete ?? model.isComplete,
                  isMultiline: model.isMultiline)
    }
}
