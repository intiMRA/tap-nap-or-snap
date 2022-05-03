//
//  AddNewSubViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 19/03/22.
//

import Foundation
import UIKit
import Combine

enum DismissState {
    case sheets, screen
}

class AddNewSubViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    @Published var name = ""
    @Published var newSubName = ""
    @Published var chosenSub: String?
    @Published var showSubsList = false
    @Published var showCreateSubView = false
    @Published var showImagePicker = false
    @Published var dismissState: DismissState?
    @Published var inputImage: UIImage?
    @Published var listOfSubs = [String]()
    @Published var isWin: Bool = true
    let api = SubmissionsAPI()
    
    init() {
        reloadState()
    }
    
    func reloadState() {
        dispatchOnMain {
            self.listOfSubs = Store.shared.submissionNamesState?.subs ?? []
        }
    }
    
    func presentSubsList() {
        self.showSubsList = true
    }
    
    func presentCreateSubView() {
        self.showCreateSubView = true
    }
    
    func presentCreateImagePickerView() {
        self.showImagePicker = true
    }
    
    func dismissSheets() {
        self.dismissState = .sheets
    }
    
    func dismissScreen() {
        self.dismissState = .screen
    }
    
    func chooseNewSubmission() {
        guard !newSubName.isEmpty else {
            return
        }
        
        setChosenSub(newSubName)
        DispatchQueue.main.async {
            self.dismissSheets()
        }
    }
    
    func setChosenSub(_ submission: String) {
        DispatchQueue.main.async {
            self.chosenSub = submission
            self.showSubsList = false
        }
    }
    
    func selectedWin() {
        self.isWin = true
    }
    
    func selectedLoss() {
        self.isWin = false
    }
    
    func saveWholeSub() {
        Task {
            let sub = Submission(id: UUID().uuidString, subName: chosenSub ?? "", personName: self.name)
            do {
                if isWin {
                    try await self.api.saveWin(submission: sub)
                } else {
                    try await self.api.saveLoss(submission: sub)
                }
                
                DispatchQueue.main.async {
                    self.dismissState = .screen
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func dispatchOnMain(_ action: @escaping () -> Void) {
        DispatchQueue.main.async {
            action()
        }
    }
}
