//
//  TappedViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 17/03/22.
//

import Foundation
import Combine

class TappedViewModel: ObservableObject {
    private var cancellable = Set<AnyCancellable>()
    @Published var navigateToNewSub = false
    @Published var peopleTapped = [Submission]()
    let api = SubmissionsAPI()
    init() {
        loadPeopleTapped()
    }
    func showNewSub() {
        self.navigateToNewSub = true
    }
    
    func loadPeopleTapped() {
        
        api.getPeopleTapped()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                default:
                    break
                }
            } receiveValue: { subs in
                self.peopleTapped = subs
            }
            .store(in: &cancellable)
    }
}
