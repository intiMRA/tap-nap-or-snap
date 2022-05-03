//
//  SubmissionDetailsViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 3/05/22.
//

import Foundation

struct SubmissionDetailModel {
    let personsName: String
    let numberOfWins: Int
    let numberOfLosses: Int
}

@MainActor
class SubmissionDetailsViewModel: ObservableObject {
    @Published var subsList: [SubmissionDetailModel] = []
    @Published var name: String = ""
    
    init(submissionsModel: SubmissionsModel, name: String) {
        self.name = name
        var countDictionary = [String: SubmissionDetailModel]()
        submissionsModel.wins.forEach { model in
            let name = model.personName ?? "unkown"
                countDictionary[name] = SubmissionDetailModel(
                    personsName: name,
                    numberOfWins: (countDictionary[name]?.numberOfWins ?? 0) + 1, numberOfLosses: 0)
        }
        
        submissionsModel.losses.forEach { model in
            let name = model.personName ?? "unkown"
                countDictionary[name] = SubmissionDetailModel(
                    personsName: name,
                    numberOfWins: countDictionary[name]?.numberOfWins ?? 0, numberOfLosses: (countDictionary[name]?.numberOfLosses ?? 0) + 1)
        }
        
        self.subsList = countDictionary.map(\.value)
    }
}
