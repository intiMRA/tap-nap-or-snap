//
//  GoalsViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 8/04/22.
//

struct GoalModel: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

import Foundation
class GoalsViewModel: ObservableObject {
    @Published var navigateToAddGoal = false
    @Published var goalModels = [
        GoalModel(title: "goal 1", description: "description 1"),
        GoalModel(title: "goal 2", description: "description 2"),
        GoalModel(title: "goal 3", description: "description that is \nlonger\nthan you thought"),
    ]
    
    func showAddGoal() {
        self.navigateToAddGoal = true
    }
}
