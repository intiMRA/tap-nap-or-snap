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
}
