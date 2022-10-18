//
//  TabView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 16/03/22.
//

import SwiftUI

struct TabItemsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = TabItemsViewModel()
    
    init() {
        UITabBar.appearance().isTranslucent = false
    }
    
    var body: some View {
        ZStack {
            ColorNames.background.color()
            VStack(spacing: 0) {
                switch viewModel.selection {
                case .submissions:
                    SubmissionsView()
                        .padding(.top, length: .large)
                case .goals:
                    GoalsView()
                        .padding(.top, length: .large)
                }
                
                ZStack {
                    ColorNames.bar.color()
                        .ignoresSafeArea(.all, edges: .bottom)
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                viewModel.selection = .submissions
                            }
                        }) {
                            VStack {
                                (viewModel.selection == .submissions ? ImageNames.dead.image() : ImageNames.deadDisabled.image())
                                    .frame(size: 50)
                                
                                Text("Submissions".localized)
                            }
                        }
                        
                        Spacer()
                        Button(action: {
                            withAnimation {
                                viewModel.selection = .goals
                            }
                        }) {
                            VStack {
                                (viewModel.selection == .goals ? ImageNames.target.image() : ImageNames.targetDisabled.image())
                                    .frame(size: 50)
                                
                                Text("Goals".localized)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.top, length: .medium)
                }
                .frame(height: 80)
            }
            .accentColor(ColorNames.text.color())
        }
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(Text(viewModel.title))
        .toolbar {
            Button("Log.Out".localized) {
                viewModel.logOut()
            }
        }
        .onReceive(viewModel.$shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .alert(viewModel.error?.title ?? "", isPresented: $viewModel.showAlert, actions: { EmptyView() }) {
            Text(viewModel.error?.message ?? "")
        }
    }
}
