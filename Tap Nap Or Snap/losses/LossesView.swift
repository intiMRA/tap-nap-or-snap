//
//  LossesView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 27/03/22.
//

import SwiftUI

struct LossesView: View {
    @StateObject var viewModel = LossesViewModel()
    var body: some View {
        ZStack(alignment: .topLeading) {
            NavigationLink(isActive: $viewModel.navigateToNewSub, destination: { AddNewSubView(viewModel: viewModel.createAddViewModel()) }, label: { EmptyView() })
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.lossesDict.sorted(by: { $0.1.count > $1.1.count }), id: \.0) { list in
                        VStack(alignment: .leading) {
                            Text(list.0)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.bottom, 16)
                                
                            
                            ForEach(list.1.sorted(by: { $0.numberOfTimes > $1.numberOfTimes })) { sub in
                                VStack(alignment: .leading) {
                                    Text("you got tapped by \(sub.personName ?? "") with \(sub.subName)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Text(viewModel.getCountCopy(for: sub))
                                        .foregroundColor(.red)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                            }
                            .padding(.bottom, 16)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Spacer()
                Button(action: viewModel.showNewSub) {
                    VStack {
                        ImageNames.add.image()
                            .renderingMode(.template)
                            .foregroundColor(ColorNames.text.color())
                            .frame(width: 24, height: 24)
                        Text("add new")
                    }
                }
            }
        }
        .onReceive(NSNotification.publisher, perform: { output in
            guard output.name == NSNotification.reloadNotification else {
                return
            }
            viewModel.reloadState()
        })
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 16)
        
    }
}
