//
//  AddNewSubViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 19/03/22.
//

import Foundation
import UIKit
import Combine

class AddNewSubViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    @Published var name = ""
    @Published var newSubName = ""
    @Published var sub: Submission?
    @Published var showSubsList = false
    @Published var showCreateSubView = false
    @Published var showImagePicker = false
    @Published var dismissView = false
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
    
    func dismissViews() {
        self.showSubsList = false
        self.showCreateSubView = false
        self.showImagePicker = false
        self.dismissView = true
    }
    
    func saveSubmission() async {
        do {
            try await api.addNewSubToList(submissionName: newSubName)
            DispatchQueue.main.async {
                self.dismissViews()
            }
        } catch {
            print(error)
        }
    }
}
