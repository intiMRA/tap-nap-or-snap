//
//  CreateNewGoalViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 8/04/22.
//

import Foundation
import Combine
import SwiftUI
enum FocusField: Hashable {
  case title, description
}

class CreateNewGoalViewModel: ObservableObject {
    @Published var title = ""
    @Published var placeholder = "placeholder"
    let originalPH = "placeholder"
    @Published var description = ""
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
    
    func isFocused(_ field: FocusField) {
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
}
