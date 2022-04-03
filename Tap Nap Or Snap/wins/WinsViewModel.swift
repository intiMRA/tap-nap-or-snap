//
//  TappedViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 17/03/22.
//

import Foundation
import Combine

class WinsViewModel: ObservableObject {
    private var cancellable = Set<AnyCancellable>()
    @Published var navigateToNewSub = false
    @Published var winsDict = [String: [Submission]]()
    let api = SubmissionsAPI()
    init() {
        reloadState()
    }
    func showNewSub() {
        self.navigateToNewSub = true
    }
    
    func reloadState() {
        dispatchOnMain {
            let wins = Store.shared.winsState?.subs ?? []
            var dict = [String: [Submission]]()
            wins.forEach { win in
                if dict[win.subName] != nil {
                    dict[win.subName]?.append(win)
                } else {
                    dict[win.subName] = [win]
                }
            }
            self.winsDict = dict
        }
    }
    
    private func dispatchOnMain(_ action: @escaping () -> Void) {
        DispatchQueue.main.async {
            action()
        }
    }
    
    func createAddViewModel() -> AddNewSubViewModel {
        AddNewSubViewModel(isWin: true)
    }
    
    func getCountCopy(for sub: Submission) -> String {
        if sub.numberOfTimes > 1 {
            return "\(sub.numberOfTimes) times"
        } else {
            return "\(sub.numberOfTimes) time"
        }
    }
}
