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

@MainActor
class CreateNewGoalViewModel: ObservableObject {
    @Published var title = ""
    @Published var placeholder = "Goals.Placeholder".localized
    @Published var shouldDismiss = false
    let originalPH = "Goals.Placeholder".localized
    let api: GoalsAPIProtocol
    @Published var description = ""
    @Published var numberOfDays = "1"
    @Published var timeToComplete: TimeToCompleteGoal = .weeks
    @Published var highlightField = false
    @Published var showAlert = false
    var error: CustomError?
    private var cancellable = Set<AnyCancellable>()
    init(api: GoalsAPIProtocol = GoalsAPI()) {
        self.api = api
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
        
        $title
            .dropFirst()
            .sink { title in
                if !title.isEmpty, self.highlightField {
                    withAnimation {
                        self.highlightField = false
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
    
    func saveGoal() async {
        let numberOfDays = Int(numberOfDays) ?? 1
        guard !title.isEmpty else {
            withAnimation {
                self.highlightField = true
            }
            return
        }
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
            
            try await api.addNewGoal(goal: GoalModel(id: UUID().uuidString, title: self.title, description: self.description, timeStamp: date, isComplete: false, isMultiline: self.description.filter( { $0 == "\n" }).count > 1))
            self.shouldDismiss = true
        } catch {
            if let error = error as? CustomError {
                self.error = error
                self.showAlert = true
            } else {
                print(error)
            }
        }
    }
    
    func setTimeToComplete(timeToComplete: TimeToCompleteGoal) {
        self.timeToComplete = timeToComplete
    }
}
