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
    @Published var submissionName: String = ""
    @Published var navigateToDescription = false
    
    var currentPersonsName = ""
    
    init(submissionsModel: SubmissionsModel, name: String) {
        self.submissionName = name
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
    
    func createDescriptionViewModel() -> SubmissionDescriptionViewModel {
        let subModel = Store.shared.submissionsState?.subs[submissionName]
        
        let wins = subModel?.wins
            .compactMap({ sub -> DescriptionModel? in
                guard let id = UUID(uuidString: sub.id), let description = sub.description, sub.personName == currentPersonsName else {
                    return nil
                }
                return DescriptionModel(id: id, description: description)
            }) ?? []
        
        let losses = subModel?.losses
            .compactMap({ sub -> DescriptionModel? in
                guard let id = UUID(uuidString: sub.id), let description = sub.description, sub.personName == currentPersonsName else {
                    return nil
                }
                return DescriptionModel(id: id, description: description)
            }) ?? []
        
        return SubmissionDescriptionViewModel(title: "\(currentPersonsName)s \(submissionName)s", winDescriptions: wins, lossesDescriptions: losses)
    }
    
    func showDescription(for name: String) {
        self.currentPersonsName = name
        self.navigateToDescription = true
    }
}
