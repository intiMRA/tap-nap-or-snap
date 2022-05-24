//
//  LogInView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 16/03/22.
//

import SwiftUI

struct LogInView: View {
    @StateObject var viewModel = LogInViewModel()
    
    var body: some View {
        VStack {
            NavigationLink(destination: TabItemsView(), isActive: $viewModel.navigateToTabView) {
                EmptyView()
            }
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    ImageNames.tomoeNage.image()
                        .renderingMode(.template)
                        .frame(width: 270, height: 200)
                        .foregroundColor(ColorNames.text.color())
                    
                    Text("TapNapOrSnap".localized)
                        .foregroundColor(ColorNames.text.color())
                        .font(.title)
                        .fontWeight(.bold)
                    
                    LoginTextField("Email".localized, keyBoard: .emailAddress, text: $viewModel.email)
                    
                    LoginTextField("Password".localized, text: $viewModel.password)
                    
                    Button(action: viewModel.login) {
                        Text("LogIn".localized)
                            .foregroundColor(ColorNames.text.color())
                    }
                    
                    Button(action: viewModel.signup) {
                        Text("SignUp".localized)
                            .foregroundColor(ColorNames.text.color())
                    }
                }
                .horizontalPadding()
                .padding(.top, length: .large)
            }
            .padding(.top, length: .large)
        }
        .ignoresSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorNames.background.color())
    }
}

struct LoginTextField: View {
    let name: String
    let keyBoard: UIKeyboardType
    @Binding var text: String
    
    init(_ name: String, keyBoard: UIKeyboardType = .alphabet, text: Binding<String>) {
        self.name = name
        self._text = text
        self.keyBoard = keyBoard
    }
    
    var body: some View {
        ZStack {
            CustomRoundRectangle(color: ColorNames.text.color(opacity: .ten))
            
            TextField(name, text: $text)
                .keyboardType(keyBoard)
                .foregroundColor(ColorNames.text.color())
                .accentColor(ColorNames.text.color())
                .padding(length: .small)
        }
        .standardHeightFillUp()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
