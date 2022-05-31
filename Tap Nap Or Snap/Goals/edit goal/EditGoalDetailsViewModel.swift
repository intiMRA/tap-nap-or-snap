//
//  EditGoalDetailsViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 25/05/22.
//

import Foundation
@MainActor
class EditGoalDetailsViewModel: ObservableObject {
    let currentGoal: GoalModel?
    let api: GoalsAPIProtocol
    @Published var description: String
    @Published var shouldDismiss = false
    
    init(currentGoal: GoalModel?, api: GoalsAPIProtocol = GoalsAPI()) {
        self.description = currentGoal?.description ?? ""
        self.currentGoal = currentGoal
        self.api = api
    }
    
    func saveDescription() {
        Task {
            try? await api.editGoalDescription(with: currentGoal?.id ?? "", description: description)
            self.shouldDismiss = true
        }
    }
}
