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
    @Published var placeholder = "Goals.Placeholder".localized
    @Published var shouldDismiss = false
    let originalPH = "Goals.Placeholder".localized
    let api = GoalsAPI()
    @Published var description = ""
    @Published var numberOfDays = "1"
    @Published var timeToComplete: TimeToCompleteGoal = .weeks
    private var cancellable = Set<AnyCancellable>()
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
            .store(in: &cancellable)
        $description
            .dropFirst()
            .sink { description in
                if description.isEmpty {
                    withAnimation {
                        self.placeholder = self.originalPH
                    }
                }
            }
            .store(in: &cancellable)
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
        //TODO: proper error
        let numberOfDays = Int(numberOfDays) ?? 1
        Task {
            do {
                var date: Date?
                switch self.timeToComplete {
                case .weeks:
                    date = Calendar.current.date(byAdding: .weekOfYear, value: numberOfDays, to: Date())
                case .months:
                    date = Calendar.current.date(byAdding: .month, value: numberOfDays, to: Date())
                case .years:
                    date = Calendar.current.date(byAdding: .year, value: numberOfDays, to: Date())
                }
                
                guard let date = date else {
                    return
                }
                
                try await api.addNewGoal(goal: GoalModel(id: UUID().uuidString, title: self.title, description: self.description, timeStamp: date, isComplete: false))
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
