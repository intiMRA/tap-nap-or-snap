//
//  TappedView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 17/03/22.
//

import SwiftUI

struct WinsView: View {
    @StateObject var viewModel = WinsViewModel()
    var body: some View {
        ZStack(alignment: .topLeading) {
            NavigationLink(isActive: $viewModel.navigateToNewSub, destination: { AddNewSubView(viewModel: viewModel.createAddViewModel()) }, label: { EmptyView() })
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.submissionsDict.sorted(by: { $0.1.total > $1.1.total }), id: \.0) { sub in
                        Button(action: viewModel.showSubmissionDetails) {
                            VStack(alignment: .leading) {
                                Text(sub.key)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text(viewModel.getWinsCountCopy(for: sub.key))
                                    .foregroundColor(.green)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text(viewModel.getLossesCountCopy(for: sub.key))
                                    .foregroundColor(.red)
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(.bottom, 16)
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.reloadNotification), perform: { output in
            guard output.name == NSNotification.reloadNotification else {
                return
            }
            viewModel.reloadState()
        })
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 16)
        
    }
}
