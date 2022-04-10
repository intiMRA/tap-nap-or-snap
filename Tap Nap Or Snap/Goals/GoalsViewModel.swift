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
    @Published var goalModels = [
        GoalModel(title: "goal 1", description: "description 1", timeStamp: "18/04/2022".asDate()!),
        GoalModel(title: "goal 2", description: "description 2", timeStamp: "16/04/2022".asDate()!),
        GoalModel(title: "goal 3", description: "description that is \nlonger\nthan you thought", timeStamp: "15/04/2022".asDate()!),
    ]
    
    func showAddGoal() {
        self.navigateToAddGoal = true
    }
}
