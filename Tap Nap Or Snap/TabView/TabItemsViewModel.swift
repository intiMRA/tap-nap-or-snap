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
    @Published var title = "Wins".localized
    @Published var shouldDismiss = false
    
    let logInApi: LogInAPIProtocol
    init(logInApi: LogInAPIProtocol = LogInAPI()) {
        self.logInApi = logInApi
        $selection
            .sink { selection in
                switch selection {
                case .submissions:
                    self.title = "Submissions".localized
                case .goals:
                    self.title = "Goals".localized
                }
            }
            .store(in: &cancellables)
    }
    
    func logOut() {
        Task {
            do {
                try await logInApi.signOut()
                await MainActor.run {
                    self.shouldDismiss = true
                }
            } catch {
                //TODO: Error handling
            }
        }
    }
}
