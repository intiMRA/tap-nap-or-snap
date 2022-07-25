//
//  GoalsViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 8/04/22.
//
import Foundation
import SwiftUI

struct GoalModel: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let timeStamp: Date
    let isComplete: Bool
    let isMultiline: Bool
}

extension GoalModel {
    init?(from dictionary: [String: String]) {
        guard let id = dictionary[Keys.id.rawValue],
              let title = dictionary[Keys.title.rawValue],
              let description = dictionary[Keys.description.rawValue],
              let timeStamp = dictionary[Keys.timeStamp.rawValue]?.asDate(),
              let isComplete = Bool(dictionary[GoalKeys.isComplete.rawValue] ?? "false") else {
            return nil
        }
        
        self.init(id: id, title: title, description: description, timeStamp: timeStamp, isComplete: isComplete, isMultiline: description.filter({ $0 == "\n" }).count > 1)
        
    }
}

@MainActor
class GoalsViewModel: ObservableObject {
    @Published var navigateToAddGoal = false
    @Published var goalModels = [GoalModel]()
    @Published var goalCollapsed = [String: Bool]()
    @Published var navigateToEditGoal = false
    var currentGoal: GoalModel?
    private let goalsApi: GoalsAPIProtocol
    
    init(goalsApi: GoalsAPIProtocol = GoalsAPI()) {
        self.goalsApi = goalsApi
        reloadState()
    }
    
    func showAddGoal() {
        self.navigateToAddGoal = true
    }
    
    func showEditGoal(currentGoal: GoalModel) {
        self.currentGoal = currentGoal
        self.navigateToEditGoal = true
    }
    
    func reloadState() {
        withAnimation {
            self.goalModels = Store.shared.goalsState?.goals ?? []
        }
    }
    
    func createEditViewModel() -> EditGoalDetailsViewModel {
        EditGoalDetailsViewModel(currentGoal: self.currentGoal)
    }
    
    func deleteGoal(with id: String) async {
        try? await self.goalsApi.deleteGoal(with: id)
        self.reloadState()
    }
    
    func completeGoal(with id: String, status: Bool) async {
        try? await self.goalsApi.goalCompletion(status: status, id: id)
        self.reloadState()
    }
    
    func collapseGoal(with id: String) {
        self.goalCollapsed[id] = !(self.goalCollapsed[id] ?? true)
    }
}
