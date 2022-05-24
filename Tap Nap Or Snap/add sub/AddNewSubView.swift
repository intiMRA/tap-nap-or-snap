//
//  AddNewSub.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 19/03/22.
//

import SwiftUI

struct AddNewSubView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: AddNewSubViewModel
    @FocusState var focusedField: AddSubsViewFocusField?
    init(viewModel: AddNewSubViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                LoginTextField("Persons Name", text: $viewModel.name)
                    .focused($focusedField, equals: .title)
                Button(action: { viewModel.presentSubsList() }) {
                    if let sub = viewModel.chosenSub {
                        Text(sub)
                            .foregroundColor(ColorNames.text.color())
                    } else {
                        Text("Add sub")
                            .foregroundColor(ColorNames.text.color())
                    }
                }
                
                HStack {
                    Button(action: { viewModel.selectedWin () }) {
                        ZStack {
                            CustomRoundRectangle(color: .green)
                                .opacity(viewModel.isWin ? 1 : 0.2)
                            
                            Text("Tapped")
                                .foregroundColor(ColorNames.text.color())
                        }
                    }
                    
                    Button(action: { viewModel.selectedLoss() }) {
                        ZStack {
                            CustomRoundRectangle(color: .red)
                                .opacity(viewModel.isWin ? 0.2 : 1)
                            
                            Text("Got Tapped")
                                .foregroundColor(ColorNames.text.color())
                        }
                    }
                    
                }
                .standardHeight()
                .padding(.horizontal, length: .large)
                
                
                TextEditor(text: viewModel.description.isEmpty ? $viewModel.placeholder : $viewModel.description)
                    .focused($focusedField, equals: .description)
                    .font(viewModel.description.isEmpty ? .callout : .body)
                    .opacity(viewModel.description.isEmpty ? 0.3 : 1)
                    .onTapGesture {
                        self.focusedField = .description
                        viewModel.isFocused(.description)
                    }
                    .padding(.bottom, length: .large)
                
                Button(action: { viewModel.saveWholeSub() }) {
                    ZStack {
                        CustomRoundRectangle(color: ColorNames.bar.color())
                        
                        Text("submit")
                            .foregroundColor(.cyan)
                    }
                }
                .standardHeightFillUp()
            }
        }
        .horizontalPadding()
        
        .navigationTitle("New Tap")
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.reloadNotification), perform: { output in
            guard output.name == NSNotification.reloadNotification else {
                return
            }
            viewModel.reloadState()
        })
        .onReceive(viewModel.$dismissState) { value in
            switch value {
            case .screen:
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
            ZStack {
                ColorNames.background.color()
                subsList
                    .horizontalPadding()
                    .padding(.top, length: .large)
            }
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
                            .foregroundColor(ColorNames.text.color())
                        Spacer()
                    }
                    
                    Button(action: {}) {
                        ImageNames.trash.rawIcon()
                    }
                }
            }
            Button(action: { viewModel.presentCreateSubView() }) {
                VStack {
                    ImageNames.add.icon(color: ColorNames.text.color())
                    Text("add new")
                        .foregroundColor(ColorNames.text.color())
                }
            }
            Spacer()
        }
        .sheet(isPresented: $viewModel.showCreateSubView, onDismiss: {}) {
            ZStack {
                ColorNames.background.color()
                createNewSub
                    .horizontalPadding()
                    .padding(.top, length: .twoHundred)
            }
            
        }
    }
    
    @ViewBuilder
    var createNewSub: some View {
        VStack {
            
            //            Button(action: viewModel.presentCreateImagePickerView) {
            //                submissionImage
            //            }
            
            LoginTextField("Submission Name", text: $viewModel.newSubName)
            
            Button(action: { viewModel.chooseNewSubmission() }) {
                ZStack {
                    CustomRoundRectangle(color: ColorNames.bar.color())
                        .standardHeightFillUp()
                    
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
