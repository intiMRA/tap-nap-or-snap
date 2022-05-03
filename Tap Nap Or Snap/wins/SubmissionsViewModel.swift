//
//  TappedViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 17/03/22.
//

import Foundation
import Combine

struct submissionCountsModel {
    let wins: Int
    let losses: Int
    let total: Int
}
                                    
class SubmissionsViewModel: ObservableObject {
    private var cancellable = Set<AnyCancellable>()
    @Published var navigateToNewSub = false
    @Published var navigateToSubmissionDetails = false
    @Published var submissionsDict = [String: submissionCountsModel]()
    let api = SubmissionsAPI()
    init() {
        reloadState()
    }
    
    func showNewSub() {
        self.navigateToNewSub = true
    }
    
    func showSubmissionDetails() {
        self.navigateToSubmissionDetails = true
    }
    
    func reloadState() {
        dispatchOnMain {
            Store.shared.submissionsState?.subs.forEach({ key, value in
                self.submissionsDict[key] = submissionCountsModel(wins: value.wins.count, losses: value.losses.count, total: value.losses.count + value.wins.count)
            })
        }
    }
    
    private func dispatchOnMain(_ action: @escaping () -> Void) {
        DispatchQueue.main.async {
            action()
        }
    }
    
    func createAddViewModel() -> AddNewSubViewModel {
        AddNewSubViewModel()
    }
    
    func getWinsCountCopy(for subKey: String) -> String {
        if submissionsDict[subKey]?.wins ?? 0 == 1 {
            return "1 time"
        } else {
            return "\(submissionsDict[subKey]?.wins  ?? 0) times"
        }
    }
    
    func getLossesCountCopy(for subKey: String) -> String {
        if submissionsDict[subKey]?.losses ?? 0 == 1 {
            return "1 time"
        } else {
            return "\(submissionsDict[subKey]?.losses ?? 0) times"
        }
    }
}
