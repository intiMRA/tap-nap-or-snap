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
    let api = SubmissionsAPI()
    
    init() {
        fetchSubsList()
    }
    
    func fetchSubsList() {
        api.getSubsList()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                default:
                    break
                }
            } receiveValue: { list in
                self.listOfSubs = list
            }
            .store(in: &cancellables)

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
    
    func saveNewSubmission() async {
        do {
            guard !newSubName.isEmpty else {
                return
            }
            
            try await api.addNewSubToList(submissionName: newSubName)
            setChosenSub(newSubName)
            DispatchQueue.main.async {
                self.dismissSheets()
            }
        } catch {
            print(error)
        }
    }
    
    func setChosenSub(_ submission: String) {
        DispatchQueue.main.async {
            self.chosenSub = submission
            self.showSubsList = false
        }
    }
    
    func saveWholeSub() async {
        let sub = Submission(id: UUID().uuidString, subName: chosenSub ?? "", personName: self.name)
        do {
            try await self.api.saveWholeSub(submission: sub)
            DispatchQueue.main.async {
                self.dismissState = .screen
            }
        } catch {
            print(error)
        }
    }
}
