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

@MainActor
class SubmissionsViewModel: ObservableObject {
    private var cancellable = Set<AnyCancellable>()
    @Published var navigateToNewSub = false
    @Published var navigateToSubmissionDetails = false
    @Published var submissionsDict = [String: submissionCountsModel]()
    var currentSubName = ""
    
    let api = SubmissionsAPI()
    init() {
        reloadState()
    }
    
    func showNewSub() {
        self.navigateToNewSub = true
    }
    
    func showSubmissionDetails(for submissionName: String) {
        self.currentSubName = submissionName
        self.navigateToSubmissionDetails = true
    }
    
    func reloadState() {
        dispatchOnMain {
            Store.shared.submissionsState?.subs.forEach({ key, value in
                let wins = value.reduce(0, { partialResult, sub in
                    partialResult + sub.wins
                })
                
                let losses = value.reduce(0, { partialResult, sub in
                    partialResult + sub.losses
                })
                self.submissionsDict[key] = submissionCountsModel(wins: wins, losses: losses, total: wins + losses)
            })
        }
    }
    
    func createSubmissionDetailsViewModel() -> SubmissionDetailsViewModel {
        guard let sub = Store.shared.submissionsState?.subs[currentSubName] else {
            return SubmissionDetailsViewModel(submissionsList: [], submissionName: "")
        }
        return SubmissionDetailsViewModel(submissionsList: sub, submissionName: currentSubName)
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
