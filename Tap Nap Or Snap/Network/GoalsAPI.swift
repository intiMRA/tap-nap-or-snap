//
//  GoalsAPI.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 18/04/22.
//

import Foundation
import FirebaseFirestore

protocol GoalsAPIProtocol {
    func addNewGoal(goal: GoalModel) async throws
}

class GoalsAPI: GoalsAPIProtocol {
    func addNewGoal(goal: GoalModel) async throws {
        do {
            let fireStore = Firestore.firestore()
            guard let uid = Store.shared.loginState?.id else {
                throw NSError()
            }
            let snapshot = try await fireStore.collection(Keys.users.rawValue).document(uid).getDocument()
            
            guard snapshot.exists == true,
                  var snapshot = snapshot.data()
            else {
                throw NSError()
            }
            
            guard
                  var goalsList = snapshot[Keys.goals.rawValue] as? [[String: String]]
            else {
                var uploadDict = [Keys.title.rawValue: goal.title]
                uploadDict[Keys.id.rawValue] = goal.id.uuidString
                uploadDict[Keys.timeStamp.rawValue] = goal.timeStamp.asString()
                uploadDict[Keys.description.rawValue] = goal.description
                snapshot[Keys.goals.rawValue] = [uploadDict]
                try await fireStore.collection(Keys.users.rawValue).document(uid).setData(uploadDict)
                var storedGoals = Store.shared.goalsState?.goals ?? []
                storedGoals.append(goal)
                await Store.shared.changeState(newState: GoalsState(goals: storedGoals))
                return
            }
            
            var uploadDict = [Keys.title.rawValue: goal.title]
            uploadDict[Keys.id.rawValue] = goal.id.uuidString
            uploadDict[Keys.timeStamp.rawValue] = goal.timeStamp.asString()
            uploadDict[Keys.description.rawValue] = goal.description
            goalsList.append(uploadDict)
            snapshot[Keys.goals.rawValue] = goalsList
            try await fireStore.collection(Keys.users.rawValue).document(uid).setData(uploadDict)
            var storedGoals = Store.shared.goalsState?.goals ?? []
            storedGoals.append(goal)
            await Store.shared.changeState(newState: GoalsState(goals: storedGoals))
        } catch {
            throw NSError()
        }
    }
}
