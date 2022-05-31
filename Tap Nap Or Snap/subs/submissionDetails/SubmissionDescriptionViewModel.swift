//
//  SubmissionDescriptionViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 6/05/22.
//

import Foundation
import Combine
import SwiftUI

struct DescriptionModel: Identifiable {
    let id: String
    let description: String
}

enum SubmissionDescriptionViewFocusField: Hashable {
  case wins, losses
}

@MainActor
class SubmissionDescriptionViewModel: ObservableObject {
    let title: String
    let winsTitle = "Win Descriptions:"
    let lossesTitle = "Loss Descriptions:"
    @Published var winDescription = ""
    @Published var lossesDescription = ""
    @Published var winPlaceholder = "No description"
    @Published var lossesPlaceholder = "No description"
    @Published var shouldDismiss = false
    let originalPH = "No description"
    var cancellable = Set<AnyCancellable>()
    
    init(title: String, winDescriptions: [DescriptionModel], lossesDescriptions: [DescriptionModel]) {
        self.title = title
        self.winDescription = text(for: winDescriptions)
        self.lossesDescription = text(for: lossesDescriptions)
        
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
    
    private func text(for submissions: [DescriptionModel]) -> String {
        var count = 1
        var subsString = ""
        submissions.forEach { sub in
            if !sub.description.isEmpty {
                subsString += "\(count). \(sub.description)\n"
                count += 1
            }
        }
        return subsString
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
        withAnimation {
            self.shouldDismiss = true
        }
    }
}
