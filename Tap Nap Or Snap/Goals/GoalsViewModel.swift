//
//  GoalsViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 8/04/22.
//
import Foundation

struct GoalModel: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let timeStamp: Date
}

class GoalsViewModel: ObservableObject {
    @Published var navigateToAddGoal = false
    @Published var goalModels = [GoalModel]()
    init() {
        reloadState()
    }
    func showAddGoal() {
        self.navigateToAddGoal = true
    }
    
    func reloadState() {
        self.goalModels = Store.shared.goalsState?.goals ?? []
    }
}
