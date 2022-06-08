//
//  SubmissionDescriptionViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 6/05/22.
//

import Foundation
import Combine
import SwiftUI

enum SubmissionDescriptionViewFocusField: Hashable {
    case wins, losses
}

@MainActor
class SubmissionDescriptionViewModel: ObservableObject {
    let title: String
    let subName: String
    let personName: String
    let winsTitle = "Win Descriptions:"
    let lossesTitle = "Loss Descriptions:"
    @Published var winDescription = ""
    @Published var lossesDescription = ""
    @Published var winPlaceholder = "No description"
    @Published var lossesPlaceholder = "No description"
    @Published var shouldDismiss = false
    let originalPH = "No description"
    var cancellable = Set<AnyCancellable>()
    let api: SubmissionsAPIProtocol
    
    init(title: String, subName: String, personName: String, submission: Submission, api: SubmissionsAPIProtocol = SubmissionsAPI()) {
        self.title = title
        self.api = api
        self.subName = subName
        self.personName = personName
        
        self.winDescription = submission.winDescription
        self.lossesDescription = submission.lossesDescription

        
        $winPlaceholder
            .dropFirst()
            .sink { value in
                if !value.isEmpty, value != self.originalPH, let lastCharacter = value.last {
                    withAnimation {
                        self.winDescription = String(lastCharacter)
                    }
                }
                
            }
            .store(in: &cancellable)
        
        $winDescription
            .dropFirst()
            .sink { description in
                if description.isEmpty {
                    withAnimation {
                        self.winPlaceholder = self.originalPH
                    }
                }
            }
            .store(in: &cancellable)
        
        $lossesPlaceholder
            .dropFirst()
            .sink { value in
                if !value.isEmpty, value != self.originalPH, let lastCharacter = value.last {
                    withAnimation {
                        self.lossesDescription = String(lastCharacter)
                    }
                }
                
            }
            .store(in: &cancellable)
        
        $lossesDescription
            .dropFirst()
            .sink { description in
                if description.isEmpty {
                    withAnimation {
                        self.lossesPlaceholder = self.originalPH
                    }
                }
            }
            .store(in: &cancellable)
        
    }
    
    func isFocused(_ field: SubmissionDescriptionViewFocusField) {
        DispatchQueue.main.async {
            withAnimation {
                switch field {
                case .wins:
                    self.winPlaceholder = ""
                    self.lossesPlaceholder = self.originalPH
                case .losses:
                    self.lossesPlaceholder = ""
                    self.winPlaceholder = self.originalPH
                }
            }
        }
    }
    
    func saveDescriptions() {
        Task {
            withAnimation {
                self.shouldDismiss = true
            }
            
            try? await api.saveSubmissionDescriptions(submissionName: subName, personName: personName, winDescription: winDescription, lossDescription: lossesDescription)
        }
    }
}
