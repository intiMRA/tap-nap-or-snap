//
//  LogInView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 16/03/22.
//

import SwiftUI

struct LogInView: View {
    @StateObject var viewModel = LogInViewModel()
    @Binding var stack: [LogInDestinations]
    var body: some View {
        VStack {
            NavigationLink(value: LogInDestinations.tabView) {
                EmptyView()
            }
            ScrollView {
                LazyVStack(alignment: .center, spacing: 10) {
                    ImageNames.tomoeNage.image()
                        .renderingMode(.template)
                        .frame(width: 270, height: 200)
                        .foregroundColor(ColorNames.text.color())
                    
                    Text("Tap.Nap.Or.Snap".localized)
                        .foregroundColor(ColorNames.text.color())
                        .font(.title)
                        .fontWeight(.bold)
                    
                    CustomTextField("Email".localized, keyBoard: .emailAddress, text: $viewModel.email)
                    
                    CustomTextField("Password".localized, text: $viewModel.password, isSecureEntry: true)
                    
                    Button(action: {
                        Task {
                            if await viewModel.login() {
                                stack.append(.tabView)
                            }
                        }
                    }) {
                        Text("Log.In".localized)
                            .bold()
                            .foregroundColor(ColorNames.text.color())
                    }
                    
                    Button(action:
                            {
                        Task {
                            if await viewModel.signup() {
                                stack.append(.tabView)
                            }
                        }
                    }) {
                        Text("Sign.Up".localized)
                            .bold()
                            .foregroundColor(ColorNames.text.color())
                    }
                }
                .horizontalPadding()
                .padding(.top, length: .large)
            }
            .padding(.top, length: .large)
            .onAppear {
                Task {
                    await viewModel.clearDetails()
                }
            }
        }
        .navigationDestination(for: LogInDestinations.self) { nextView in
            switch nextView {
            case .tabView:
                TabItemsView()
            }
        }
        .ignoresSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorNames.background.color())
        .alert(viewModel.error?.title ?? "", isPresented: $viewModel.showAlert, actions: { EmptyView() }) {
            Text(viewModel.error?.message ?? "")
        }
        .onAppear {
            Task {
                if await viewModel.logInUserAlreadySignedIn() {
                    stack.append(.tabView)
                }
            }
        }
    }
}

struct CustomTextField: View {
    let name: String
    let keyBoard: UIKeyboardType
    let isSecureEntry: Bool
    let isWarning: Bool
    @Binding var text: String
    @State var isVisible = false
    init(_ name: String, keyBoard: UIKeyboardType = .alphabet, text: Binding<String>, isSecureEntry: Bool = false, isWarning: Bool = false) {
        self.name = name
        self._text = text
        self.keyBoard = keyBoard
        self.isSecureEntry = isSecureEntry
        self.isWarning = isWarning
    }
    
    var body: some View {
        ZStack {
            CustomRoundRectangle(color: ColorNames.text.color(opacity: .ten))
            if isSecureEntry {
                HStack {
                    Group {
                        if isVisible {
                            TextField(name, text: $text)
                                .disableAutocorrection(true)
                                .textInputAutocapitalization(.never)
                                .keyboardType(keyBoard)
                                .foregroundColor(self.isWarning ? ColorNames.warning.color() : ColorNames.text.color())
                                .accentColor(self.isWarning ? ColorNames.warning.color() : ColorNames.text.color())
                                .padding(length: .small)
                        } else {
                            SecureField(name, text: $text)
                                .keyboardType(keyBoard)
                                .foregroundColor(self.isWarning ? ColorNames.warning.color() : ColorNames.text.color())
                                .accentColor(self.isWarning ? ColorNames.warning.color() : ColorNames.text.color())
                                .padding(length: .small)
                        }
                    }
                    
                    Button(action: { self.isVisible = !self.isVisible }) {
                        ImageNames.eye.icon(color: self.isVisible ? .blue : ColorNames.text.color())
                    }
                    .padding(.horizontal, length: .small)
                }
            } else {
                TextField(name, text: $text)
                    .keyboardType(keyBoard)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .foregroundColor(self.isWarning ? ColorNames.warning.color() : ColorNames.text.color())
                    .accentColor(self.isWarning ? ColorNames.warning.color() : ColorNames.text.color())
                    .padding(length: .small)
            }
        }
        .standardHeightFillUp()
    }
}
