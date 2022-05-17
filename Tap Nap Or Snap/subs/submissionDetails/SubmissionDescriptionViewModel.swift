//
//  SubmissionDescriptionViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 6/05/22.
//

import Foundation

struct DescriptionModel: Identifiable {
    let id: UUID
    let description: String
}

@MainActor
class SubmissionDescriptionViewModel: ObservableObject {
    let title: String
    let winDescriptions: [DescriptionModel]
    let lossesDescriptions: [DescriptionModel]
    let winsTitle = "Win Descriptions:"
    let lossesTitle = "Loss Descriptions:"
    
    init(title: String, winDescriptions: [DescriptionModel], lossesDescriptions: [DescriptionModel]) {
        self.title = title
        self.winDescriptions = winDescriptions
        self.lossesDescriptions = lossesDescriptions
    }
    
    func text(for submissions: [DescriptionModel]) -> String {
        var count = 1
        var subsString = ""
        submissions.forEach { sub in
            if !sub.description.isEmpty {
                subsString += "\(count). \(sub.description)\n"
                count += 1
            }
        }
        return subsString
    }
}
