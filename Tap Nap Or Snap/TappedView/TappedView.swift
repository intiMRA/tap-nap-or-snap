//
//  TappedView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 17/03/22.
//

import SwiftUI

struct TappedView: View {
    @StateObject var viewModel = TappedViewModel()
    var body: some View {
        ZStack(alignment: .topLeading) {
            NavigationLink(isActive: $viewModel.navigateToNewSub, destination: { AddNewSubView() }, label: { EmptyView() })
            ScrollView {
                VStack {
                    ForEach(0...100, id:\.self) { number in
                        Text("number\(number)")
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            HStack {
                Spacer()
                Button(action: viewModel.showNewSub) {
                    VStack {
                        ImageNames.add.image()
                            .frame(width: 24, height: 24)
                        Text("add new")
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 16)
        
    }
}

struct TappedView_Previews: PreviewProvider {
    static var previews: some View {
        TappedView()
    }
}
