//
//  TabItemsViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 17/03/22.
//

import Foundation
import Combine

enum ViewSelection: Int {
    case submissions, goals
}

class TabItemsViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    @Published var selection: ViewSelection = .submissions
    @Published var title = "Wins"
    init() {
        $selection
            .sink { selection in
                switch selection {
                case .submissions:
                    self.title = "Submissions"
                case .goals:
                    self.title = "Goals"
                }
            }
            .store(in: &cancellables)
    }
}
