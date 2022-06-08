//
//  Submission.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 19/03/22.
//

import Foundation

struct SubmissionUploadModel {
    let subName : String
    let personName: String
    let description: String
    init(subName: String, personName: String, description: String = "") {
        self.subName = subName
        self.personName = personName
        self.description = description
    }
}

struct Submission {
    let personName: String
    let subName: String
    let wins: Int
    let losses: Int
    let winDescription: String
    let lossesDescription: String
    
    init(
        personName: String = "",
        subName: String = "",
        wins: Int = 0,
        losses: Int = 0,
        winDescription: String = "",
        lossesDescription: String = ""
    ) {
        self.personName = personName
        self.subName = subName
        self.wins = wins
        self.losses = losses
        self.winDescription = winDescription
        self.lossesDescription = lossesDescription
    }
}

extension Submission {
    init(from dictionary: [String: Any], subName: String, personName: String) {
        let wins = dictionary[SubmissionKeys.wins.rawValue] as? Int ?? 0
        let losses = dictionary[SubmissionKeys.losses.rawValue] as? Int ?? 0
        let winDescription = dictionary[SubmissionKeys.winsDescription.rawValue] as? String ?? ""
        let lossesDescription = dictionary[SubmissionKeys.lossesDescription.rawValue] as? String ?? ""
        self.init(personName: personName, subName: subName, wins: wins, losses: losses, winDescription: winDescription, lossesDescription: lossesDescription)
    }
}
