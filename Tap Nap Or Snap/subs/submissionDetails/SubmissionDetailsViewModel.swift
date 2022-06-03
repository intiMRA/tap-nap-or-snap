//
//  SubmissionDetailsViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 3/05/22.
//

import Foundation

@MainActor
class SubmissionDetailsViewModel: ObservableObject {
    @Published var submissionsList: [Submission]
    @Published var submissionName: String = ""
    @Published var navigateToDescription = false
    
    var currentPersonsName = ""
    
    init(submissionsList: [Submission], submissionName: String) {
        self.submissionName = submissionName
        self.submissionsList = submissionsList
    }
    
    func createDescriptionViewModel() -> SubmissionDescriptionViewModel {
        guard let sub = submissionsList.first(where: { $0.personName == currentPersonsName }) else {
            return SubmissionDescriptionViewModel(title: "\(currentPersonsName)s \(submissionName)s", subName: submissionName, personName: currentPersonsName, submission: Submission())
        }
        return SubmissionDescriptionViewModel(title: "\(currentPersonsName)s \(submissionName)s", subName: submissionName, personName: currentPersonsName, submission: sub)
    }
    
    func showDescription(for name: String) {
        self.currentPersonsName = name
        self.navigateToDescription = true
    }
    
    func getWinsCountCopy(for sub: Submission) -> String {
        "\(sub.wins) \(sub.wins == 1 ? "time" : "times")"
    }
    
    func getLossesCountCopy(for sub: Submission) -> String {
        "\(sub.losses) \(sub.losses == 1 ? "time" : "times")"
    }
}
