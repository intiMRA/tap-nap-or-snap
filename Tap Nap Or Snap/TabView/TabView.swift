//
//  TabView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 16/03/22.
//

import SwiftUI

struct TabItemsView: View {
    @StateObject var viewModel = TabItemsViewModel()
    
    init() {
        UITabBar.appearance().isTranslucent = false
    }
    
    var body: some View {
        ZStack {
            ColorNames.bar.color()
            TabView(selection: $viewModel.selection) {
            ZStack {
                ColorNames.background.color()
                VStack {

                    WinsView()
                            .padding(.top, 10)
                    
                    Rectangle()
                        .fill(ColorNames.text.color())
                        .frame(height: 1)
                        .opacity(0.3)
                }
            }
                .tabItem {
                    VStack {
                        ImageNames.dead.image()
                            .renderingMode(.template)
                        
                        Text("Submissions")
                    }
                }
                .tag(ViewSelection.submissions)
            
                ZStack {
                    ColorNames.background.color()
                    VStack {

                        GoalsView()
                                .padding(.top, 10)
                        
                        Rectangle()
                            .fill(ColorNames.text.color())
                            .frame(height: 1)
                            .opacity(0.3)
                    }
                }
                .tabItem {
                    VStack {
                        ImageNames.user.image()
                            .renderingMode(.template)
                       
                        Text("Goals")
                    }
                }
                .tag(ViewSelection.goals)
        }
        .accentColor(ColorNames.text.color())
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(Text(viewModel.title))
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        TabItemsView()
    }
}
