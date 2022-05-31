//
//  Submission.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 19/03/22.
//

import Foundation

struct Submission: Identifiable {
    let id: String
    let subName : String
    let personName: String?
    let description: String?
    init(id: String, subName: String, personName: String?, description: String?) {
        self.id = id
        self.subName = subName
        self.personName = personName
        self.description = description ?? ""
    }
}

extension Submission {
    init?(from dictionary: [String: String]) {
        guard
            let id = dictionary[Keys.id.rawValue],
            let submName = dictionary[Keys.subName.rawValue],
            let personName = dictionary[Keys.person.rawValue],
            let description = dictionary[Keys.description.rawValue]
        else {
            return nil
        }
        self.init(id: id, subName: submName, personName: personName, description: description)
    }
}
