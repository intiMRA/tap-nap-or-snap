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
    func deleteGoal(with id: String) async throws
    func goalCompletion(status: Bool, id: String) async throws
    func editGoalDescription(with id: String, description: String) async throws
}

enum GoalKeys: String {
    case isComplete
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
                uploadDict[Keys.id.rawValue] = goal.id
                uploadDict[Keys.timeStamp.rawValue] = goal.timeStamp.asString()
                uploadDict[Keys.description.rawValue] = goal.description
                uploadDict[GoalKeys.isComplete.rawValue] = "\(goal.isComplete)"
                snapshot[Keys.goals.rawValue] = [uploadDict]
                try await fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
                var storedGoals = Store.shared.goalsState?.goals ?? []
                storedGoals.append(goal)
                await Store.shared.changeState(newState: GoalsState(goals: storedGoals))
                return
            }
            
            var uploadDict = [Keys.title.rawValue: goal.title]
            uploadDict[Keys.id.rawValue] = goal.id
            uploadDict[Keys.timeStamp.rawValue] = goal.timeStamp.asString()
            uploadDict[Keys.description.rawValue] = goal.description
            uploadDict[GoalKeys.isComplete.rawValue] = "\(goal.isComplete)"
            goalsList.append(uploadDict)
            snapshot[Keys.goals.rawValue] = goalsList
            try await fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
            var storedGoals = Store.shared.goalsState?.goals ?? []
            storedGoals.append(goal)
            await Store.shared.changeState(newState: GoalsState(goals: storedGoals))
        } catch {
            throw NSError()
        }
    }
    
    func deleteGoal(with id: String) async throws {
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
                await Store.shared.changeState(newState: GoalsState(goals: []))
                return
            }
            
            goalsList.removeAll(where: { $0[Keys.id.rawValue] == id })
            snapshot[Keys.goals.rawValue] = goalsList
            var storedGoals = Store.shared.goalsState?.goals ?? []
            storedGoals.removeAll(where: { $0.id == id })
            await Store.shared.changeState(newState: GoalsState(goals: storedGoals))
            
            try await fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
            
        } catch {
            throw NSError()
        }
    }
    
    func goalCompletion(status: Bool, id: String) async throws {
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
                  var goalsList = snapshot[Keys.goals.rawValue] as? [[String: String]],
                  let goalIndex = goalsList.firstIndex(where: { $0[Keys.id.rawValue] == id })
            else {
                return
            }
            var completedGoal = goalsList[goalIndex]
            completedGoal[GoalKeys.isComplete.rawValue] = "\(status)"
            goalsList[goalIndex] = completedGoal
            
            snapshot[Keys.goals.rawValue] = goalsList
            
            guard let goalModel = GoalModel(from: completedGoal) else {
                return
            }
            
            var storedGoals = Store.shared.goalsState?.goals ?? []
            storedGoals[goalIndex] = goalModel
            await Store.shared.changeState(newState: GoalsState(goals: storedGoals))
            
            try await fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
            
        } catch {
            throw NSError()
        }
    }
    
    func editGoalDescription(with id: String, description: String) async throws {
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
                  var goalsList = snapshot[Keys.goals.rawValue] as? [[String: String]],
                  let goalIndex = goalsList.firstIndex(where: { $0[Keys.id.rawValue] == id })
            else {
                return
            }
            var completedGoal = goalsList[goalIndex]
            completedGoal[Keys.description.rawValue] = description
            goalsList[goalIndex] = completedGoal
            
            snapshot[Keys.goals.rawValue] = goalsList
            
            guard let goalModel = GoalModel(from: completedGoal) else {
                return
            }
            
            var storedGoals = Store.shared.goalsState?.goals ?? []
            storedGoals[goalIndex] = goalModel
            await Store.shared.changeState(newState: GoalsState(goals: storedGoals))
            
            try await fireStore.collection(Keys.users.rawValue).document(uid).setData(snapshot)
            
        } catch {
            throw NSError()
        }
    }
}
