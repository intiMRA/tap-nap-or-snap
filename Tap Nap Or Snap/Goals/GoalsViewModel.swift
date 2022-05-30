//
//  GoalsViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 8/04/22.
//
import Foundation
import SwiftUI

struct GoalModel: Identifiable {
    let id: String
    let title: String
    let description: String
    let timeStamp: Date
    let isComplete: Bool
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
        
        self.init(id: id, title: title, description: description, timeStamp: timeStamp, isComplete: isComplete)
            
    }
}

@MainActor
class GoalsViewModel: ObservableObject {
    @Published var navigateToAddGoal = false
    @Published var goalModels = [GoalModel]()
    @Published var navigateToEditGoal = false
    var currentGoal: GoalModel?
    let goalsApi = GoalsAPI()
    
    init() {
        reloadState()
    }
    
    func showAddGoal() {
        self.navigateToAddGoal = true
    }
    
    func showEditGoal(currentGoal: GoalModel) {
        Task {
            self.currentGoal = currentGoal
            await MainActor.run {
                self.navigateToEditGoal = true
            }
        }
    }
    
    func reloadState() {
        withAnimation {
            self.goalModels = Store.shared.goalsState?.goals ?? []
        }
    }
    
    func createEditViewModel() -> EditGoalDetailsViewModel {
        EditGoalDetailsViewModel(currentGoal: self.currentGoal)
    }
    
    func deleteGoal(with id: String) {
        Task {
            try? await self.goalsApi.deleteGoal(with: id)
            self.reloadState()
        }
    }
    
    func completeGoal(with id: String, status: Bool) {
        Task {
            try? await self.goalsApi.goalCompletion(status: status, id: id)
            self.reloadState()
        }
    }
}
