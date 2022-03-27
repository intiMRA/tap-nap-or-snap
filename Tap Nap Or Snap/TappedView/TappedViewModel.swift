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
    @Published var refresh = false
    @Published var peopleTapped = [String: [Submission]]()
    let api = SubmissionsAPI()
    init() {
        loadPeopleTapped()
        $refresh
            .sink { refresh in
                if refresh {
                    self.loadPeopleTapped()
                }
            }
            .store(in: &cancellable)
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
                var dict = [String: [Submission]]()
                subs.forEach { sub in
                    if dict[sub.subName] != nil {
                        dict[sub.subName]?.append(sub)
                    } else {
                        dict[sub.subName] = [sub]
                    }
                }
                self.peopleTapped = dict
            }
            .store(in: &cancellable)
    }
}
