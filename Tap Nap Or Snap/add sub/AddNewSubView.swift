//
//  AddNewSub.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 19/03/22.
//

import SwiftUI

struct AddNewSubView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = AddNewSubViewModel()
    @Binding var refresh: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            LoginTextField("Who I tapped", text: $viewModel.name)
            Button(action: viewModel.presentSubsList) {
                if let sub = viewModel.chosenSub {
                    Text(sub)
                } else {
                    Text("Add sub")
                }
            }
            
            Button(action: {
                Task {
                    await viewModel.saveWholeSub()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(ColorNames.bar.color())
                        .frame(maxWidth: .infinity, maxHeight: 44)
                    
                    Text("submit")
                        .foregroundColor(.cyan)
                }
            }
        }
        .padding(.horizontal, 16)
        .navigationTitle("New Tap")
        .onReceive(viewModel.$dismissState) { value in
            switch value {
            case .screen:
                self.refresh = true
                (UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene)?.windows.first?.rootViewController?.dismiss(animated: true)
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
            case .sheets:
                (UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene)?.windows.first?.rootViewController?.dismiss(animated: true)
            case .none:
                break
            }
        }
        .sheet(isPresented: $viewModel.showSubsList, onDismiss: { }) {
            subsList
                .padding(.horizontal, 16)
                .padding(.top, 20)
        }
    }
    
    @ViewBuilder
    var subsList: some View {
        VStack {
            ForEach(0 ..< viewModel.listOfSubs.count, id: \.self) { index in
                HStack {
                    Button(action: {
                        viewModel.setChosenSub(viewModel.listOfSubs[index])
                    }) {
                        Text(viewModel.listOfSubs[index])
                        Spacer()
                    }
                    
                    Button(action: {}) {
                        ImageNames.trash.image()
                            .frame(width: 24, height: 24)
                    }
                }
            }
            Button(action: viewModel.presentCreateSubView) {
                VStack {
                    ImageNames.add.image()
                        .frame(width: 24, height: 24)
                    Text("add new")
                }
            }
            Spacer()
        }
        .sheet(isPresented: $viewModel.showCreateSubView, onDismiss: {}) {
            createNewSub
                .padding(.horizontal, 16)
                .padding(.top, 200)

        }
    }
    
    @ViewBuilder
    var createNewSub: some View {
        VStack {
            
//            Button(action: viewModel.presentCreateImagePickerView) {
//                submissionImage
//            }
            
            LoginTextField("Submission Name", text: $viewModel.newSubName)
            
            Button(action: {
                Task {
                    await viewModel.saveNewSubmission()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(ColorNames.bar.color())
                        .frame(maxWidth: .infinity, maxHeight: 44)
                    
                    Text("submit")
                        .foregroundColor(.cyan)
                }
            }
            
            Spacer()
        }
//        .sheet(isPresented: $viewModel.showImagePicker) {
//            ImagePicker(image: $viewModel.inputImage)
//        }
    }
    
    @ViewBuilder
    var submissionImage: some View {
        if let image = viewModel.inputImage {
            Image(uiImage: image)
                .resizable()
                .frame(width: 100, height: 100)
        } else {
            Rectangle()
                .fill(.gray)
                .frame(width: 100, height: 100)
        }
    }
}
