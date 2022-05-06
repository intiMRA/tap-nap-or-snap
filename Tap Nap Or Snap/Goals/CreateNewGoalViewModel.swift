//
//  CreateNewGoalViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 8/04/22.
//

import Foundation
import Combine
import SwiftUI
enum GoalsViewFocusField: Hashable {
  case title, description
}

enum TimeToCompleteGoal: String {
    case weeks, months, years
}

class CreateNewGoalViewModel: ObservableObject {
    @Published var title = ""
    @Published var placeholder = "placeholder"
    @Published var shouldDismiss = false
    let originalPH = "placeholder"
    let api = GoalsAPI()
    @Published var description = ""
    @Published var numberOfDays = ""
    @Published var timeToComplete: TimeToCompleteGoal = .weeks
    private var cancelable = Set<AnyCancellable>()
    init() {
        $placeholder
            .dropFirst()
            .sink { value in
                if !value.isEmpty, value != self.originalPH, let lastCharacter = value.last {
                    withAnimation {
                        self.description = String(lastCharacter)
                    }
                }

            }
            .store(in: &cancelable)
        $description
            .dropFirst()
            .sink { description in
                if description.isEmpty {
                    withAnimation {
                        self.placeholder = self.originalPH
                    }
                }
            }
            .store(in: &cancelable)
    }
    
    func isFocused(_ field: GoalsViewFocusField) {
        DispatchQueue.main.async {
            withAnimation {
                switch field {
                case .title:
                    self.placeholder = self.originalPH
                case .description:
                    self.placeholder = ""
                }
            }
        }
    }
    
    func saveGoal() {
        Task {
            do {
                var date = Date()
                switch self.timeToComplete {
                case .weeks:
                    date = Calendar.current.date(byAdding: .weekOfYear, value: Int(numberOfDays)!, to: date)!
                case .months:
                    date = Calendar.current.date(byAdding: .month, value: Int(numberOfDays)!, to: date)!
                case .years:
                    date = Calendar.current.date(byAdding: .year, value: Int(numberOfDays)!, to: date)!
                }
                try await api.addNewGoal(goal: GoalModel(title: self.title, description: self.description, timeStamp: date))
                DispatchQueue.main.async {
                    self.shouldDismiss = true
                }
            } catch {
                print(error)
            }
        }
    }
    
    func setTimeToComplete(timeToComplete: TimeToCompleteGoal) {
        self.timeToComplete = timeToComplete
    }
}
