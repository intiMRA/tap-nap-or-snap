//
//  AddNewSubViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 19/03/22.
//

import Foundation
import UIKit
import Combine
import SwiftUI

enum DismissState {
    case sheets, screen
}

enum AddSubsViewFocusField: Hashable {
    case title, description
}

struct FieldsToHighlight {
    let name: Bool
    let subName: Bool
}

@MainActor
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
    @Published var description = ""
    @Published var placeholder = "Add.Sub.Placeholder".localized
    @Published var fieldsToHighlight = FieldsToHighlight(name: false, subName: false)
    @Published var showAlert = false
    var error: CustomError?
    let originalPH = "Add.Sub.Placeholder".localized
    let api = SubmissionsAPI()
    var cancellable = Set<AnyCancellable>()
    init() {
        reloadState()
        $placeholder
            .dropFirst()
            .sink { value in
                if !value.isEmpty, value != self.originalPH, let lastCharacter = value.last {
                    withAnimation {
                        self.description = String(lastCharacter)
                    }
                }
            }
            .store(in: &cancellable)
        $description
            .dropFirst()
            .sink { description in
                if description.isEmpty {
                    withAnimation {
                        self.placeholder = self.originalPH
                    }
                }
            }
            .store(in: &cancellable)
        
        $name
            .dropFirst()
            .sink { name in
                guard !name.isEmpty else {
                    withAnimation {
                        self.fieldsToHighlight = FieldsToHighlight(name: true, subName: self.fieldsToHighlight.subName)
                    }
                    return
                }
                withAnimation {
                    self.fieldsToHighlight = FieldsToHighlight(name: false, subName: self.fieldsToHighlight.subName)
                }
            }
            .store(in: &cancellable)
    }
    
    func reloadState() {
        self.listOfSubs = Store.shared.submissionNamesState?.subs ?? []
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
        guard !submission.isEmpty else {
            self.fieldsToHighlight = FieldsToHighlight(name: self.fieldsToHighlight.name, subName: true)
            return
        }
        self.fieldsToHighlight = FieldsToHighlight(name: self.fieldsToHighlight.name, subName: false)
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
    
    private func checkInfoIsValid() async throws {
        let nameIsEmpty = self.name.isEmpty
        let subIsEmpty = self.chosenSub?.isEmpty ?? true
        await MainActor.run {
            withAnimation {
                self.fieldsToHighlight = FieldsToHighlight(name: nameIsEmpty, subName: subIsEmpty)
            }
        }

        if nameIsEmpty || subIsEmpty {
            throw NSError()
        }
    }
    
    func saveWholeSub() {
        
        Task {
            try await checkInfoIsValid()
            
            let sub = SubmissionUploadModel(subName: chosenSub ?? "", personName: self.name, description: self.description)
            do {
                if isWin {
                    try await self.api.saveWin(submission: sub)
                } else {
                    try await self.api.saveLoss(submission: sub)
                }
                
                await MainActor.run {
                    self.dismissState = .screen
                }
                
            } catch {
                if let error = error as? CustomError {
                    self.error = error
                    await MainActor.run {
                        self.showAlert = true
                    }
                } else {
                    print(error)
                }
            }
        }
    }
    
    func isFocused(_ field: AddSubsViewFocusField) {
        withAnimation {
            switch field {
            case .title:
                self.placeholder = self.originalPH
            case .description:
                self.placeholder = ""
            }
        }
    }
}
