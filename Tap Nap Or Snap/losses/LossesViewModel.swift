//
//  GotTappedViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 27/03/22.
//

import Foundation
import Combine

class LossesViewModel: ObservableObject {
    private var cancellable = Set<AnyCancellable>()
    @Published var navigateToNewSub = false
    @Published var lossesDict = [String: [Submission]]()
    let api = SubmissionsAPI()
    init() {
        reloadState()
    }
    func showNewSub() {
        self.navigateToNewSub = true
    }
    
    func createAddViewModel() -> AddNewSubViewModel {
        AddNewSubViewModel(isWin: false)
    }
    
    func getCountCopy(for sub: Submission) -> String {
        if sub.numberOfTimes > 1 {
            return "\(sub.numberOfTimes) times"
        } else {
            return "\(sub.numberOfTimes) time"
        }
    }
    
    func reloadState() {
        dispatchOnMain {
            let losses = Store.shared.lossesState?.subs ?? []
            var dict = [String: [Submission]]()
            losses.forEach { loss in
                if dict[loss.subName] != nil {
                    dict[loss.subName]?.append(loss)
                } else {
                    dict[loss.subName] = [loss]
                }
            }
            self.lossesDict = dict
        }
    }
    
    private func dispatchOnMain(_ action: @escaping () -> Void) {
        DispatchQueue.main.async {
            action()
        }
    }
}
