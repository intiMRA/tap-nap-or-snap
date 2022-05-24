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
