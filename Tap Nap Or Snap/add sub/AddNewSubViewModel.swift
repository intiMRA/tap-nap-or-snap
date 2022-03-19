//
//  AddNewSubViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 19/03/22.
//

import Foundation

class AddNewSubViewModel: ObservableObject {
    @Published var name = ""
    @Published var sub: Submission?
    @Published var showSubsList = false
    @Published var showCreateSubView = false
    
    func presentSubsList() {
        self.showSubsList = true
    }
    
    func presentCreateSubView() {
        self.showCreateSubView = true
    }
}
