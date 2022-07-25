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
            LazyVStack(spacing: 20) {
                VStack(alignment: .leading) {
                    CustomTextField("Persons.Name".localized, text: $viewModel.name)
                        .focused($focusedField, equals: .title)
                        .onTapGesture {
                            self.focusedField = .title
                            viewModel.isFocused(.title)
                        }
                    
                    if viewModel.fieldsToHighlight.name {
                        Text("Persons.Name.Error".localized)
                            .bold()
                            .foregroundColor(ColorNames.warning.color())
                    }
                }
                Button(action: { viewModel.presentSubsList() }) {
                    if let sub = viewModel.chosenSub {
                        HStack {
                            Text(sub)
                                .font(.title3)
                                .bold()
                                .foregroundColor(ColorNames.text.color())
                            Spacer()
                            ImageNames.edit.rawIcon()
                        }
                    } else {
                        HStack {
                            Text("Add.Sub".localized)
                                .font(.title3)
                                .bold()
                                .foregroundColor(viewModel.fieldsToHighlight.subName ? ColorNames.warning.color() : ColorNames.text.color())
                            Spacer()
                            ImageNames.edit.rawIcon()
                        }
                    }
                }
                
                HStack {
                    Button(action: { viewModel.selectedWin () }) {
                        ZStack {
                            CustomRoundRectangle(color: .green, opacity: viewModel.isWin ? 1 : 0.2)
                            
                            Text("Tapped".localized)
                                .foregroundColor(ColorNames.text.color())
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { viewModel.selectedLoss() }) {
                        ZStack {
                            CustomRoundRectangle(color: .red, opacity: viewModel.isWin ? 0.2 : 1)
                            
                            Text("Got.Tapped".localized)
                                .foregroundColor(ColorNames.text.color())
                        }
                    }
                    
                }
                .standardHeight()
                
                ZStack {
                    CustomRoundRectangle(color: ColorNames.text.color(opacity: .ten))
                    TextEditor(text: viewModel.description.isEmpty ? $viewModel.placeholder : $viewModel.description)
                        .focused($focusedField, equals: .description)
                        .font(viewModel.description.isEmpty ? .callout : .body)
                        .opacity(viewModel.description.isEmpty ? 0.3 : 1)
                }
                .frame(height: 200)
                .padding(.bottom, length: .large)
                .onTapGesture {
                    self.focusedField = .description
                    viewModel.isFocused(.description)
                }
                
                Button(action: {
                    Task {
                        await viewModel.saveWholeSub()
                    } 
                }) {
                    ZStack {
                        CustomRoundRectangle(color: .blue)
                            .standardHeightFillUp()
                        
                        Text("Submit".localized)
                            .foregroundColor(ColorNames.text.color())
                    }
                }
                .standardHeightFillUp()
            }
            .horizontalPadding()
            .padding(.top, length: .large)
        }
        .background(.background)
        .navigationTitle("New.Tap".localized)
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
        .alert(viewModel.error?.title ?? "", isPresented: $viewModel.showAlert, actions: { EmptyView() }) {
            Text(viewModel.error?.message ?? "")
        }
    }
    
    @ViewBuilder
    var subsList: some View {
        VStack {
            ForEach(0 ..< viewModel.listOfSubs.count, id: \.self) { index in
                ZStack {
                    CustomRoundRectangle(color: .blue, opacity: 0.3)
                    HStack {
                        Button(action: {
                            viewModel.setChosenSub(viewModel.listOfSubs[index])
                        }) {
                            Text(viewModel.listOfSubs[index])
                                .font(.title3)
                                .bold()
                                .foregroundColor(ColorNames.text.color())
                            Spacer()
                        }
                        
                        Button(action: {
                            Task {
                                await viewModel.deleteSubFromList(with: index)
                            }
                        }) {
                            ImageNames.trash.rawIcon()
                        }
                    }
                    .padding(length: .medium)
                }
                .standardHeight()
                .padding(.bottom, length: .medium)
                .offset(x: viewModel.shakeAnimationIndex == index ? -10 : 0)
            }
            Button(action: { viewModel.presentCreateSubView() }) {
                VStack {
                    ImageNames.add.rawIcon()
                    Text("Add.New".localized)
                        .foregroundColor(.text)
                }
            }
            Spacer()
        }
        .padding(.top, length: .large)
        .sheet(isPresented: $viewModel.showCreateSubView, onDismiss: {}) {
            ZStack {
                ColorNames.background.color()
                createNewSub
                    .horizontalPadding()
                    .padding(.top, length: .xLarge)
            }
            
        }
    }
    
    @ViewBuilder
    var createNewSub: some View {
        VStack {
            CustomTextField("Submission.Name".localized, text: $viewModel.newSubName)
            
            Button(action: { viewModel.chooseNewSubmission() }) {
                ZStack {
                    CustomRoundRectangle(color: .blue)
                        .standardHeightFillUp()
                    
                    Text("Submit".localized)
                        .foregroundColor(ColorNames.text.color())
                }
            }
            Spacer()
        }
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
