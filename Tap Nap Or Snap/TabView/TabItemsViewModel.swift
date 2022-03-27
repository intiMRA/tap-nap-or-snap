//
//  TabItemsViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 17/03/22.
//

import Foundation
import Combine

enum ViewSelection: Int {
    case tapped, gotTapped, people
}

class TabItemsViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    @Published var selection: ViewSelection = .tapped
    @Published var title = "Tapped"
    init() {
        $selection
            .sink { selection in
                switch selection {
                case .tapped:
                    self.title = "Tapped"
                case .gotTapped:
                    self.title = "gotTapped"
                case .people:
                    self.title = "people"
                }
            }
            .store(in: &cancellables)
    }
}
