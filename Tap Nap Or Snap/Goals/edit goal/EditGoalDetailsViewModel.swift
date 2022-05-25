//
//  EditGoalDetailsViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 25/05/22.
//

import Foundation
class EditGoalDetailsViewModel: ObservableObject {
    let currentGoal: GoalModel?
    
    init(currentGoal: GoalModel?) {
        self.currentGoal = currentGoal
    }
    
}
