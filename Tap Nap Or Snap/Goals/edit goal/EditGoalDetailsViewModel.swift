//
//  EditGoalDetailsViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 25/05/22.
//

import Foundation
class EditGoalDetailsViewModel: ObservableObject {
    let currentGoal: GoalModel?
    let api: GoalsAPIProtocol
    var error: CustomError?
    @Published var description: String
    @Published var shouldDismiss = false
    @Published var showAlert = false
    
    init(currentGoal: GoalModel?, api: GoalsAPIProtocol = GoalsAPI()) {
        self.description = currentGoal?.description ?? ""
        self.currentGoal = currentGoal
        self.api = api
    }
    
    func saveDescription() {
        Task {
            do {
                try await api.editGoalDescription(with: currentGoal?.id ?? "", description: description)
               await  MainActor.run {
                    self.shouldDismiss = true
                }
            } catch {
                self.error = CustomError(title: "Edit.Goal.Error.Title".localized, message: "Edit.Goal.Error.Message".localized)
                await  MainActor.run {
                    self.showAlert = true
                 }
            }
        }
    }
}
