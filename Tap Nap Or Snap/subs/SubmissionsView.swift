//
//  TappedView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 17/03/22.
//

import SwiftUI

struct SubmissionsView: View {
    @StateObject var viewModel = SubmissionsViewModel()
    @EnvironmentObject var router: Router

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button(action: { router.stack.append(SubmissionsDestinations.addNewSub) }) {
                    VStack {
                        ImageNames.add.rawIcon()
                        Text("Add.New".localized)
                    }
                }
            }
            
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.submissionsDict.sorted(by: { $0.1.total > $1.1.total }), id: \.0) { sub in
                        Button(action: {
                            Task {
                                await viewModel.setSubmissionDetails(for: sub.key)
                                router.stack.append(SubmissionsDestinations.subDetails)
                            }
                        }) {
                            ZStack {
                                CustomRoundRectangle(color: .blue, opacity: 0.3)
                                VStack(alignment: .center) {
                                    Text(sub.key)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .padding(.bottom, length: .xxSmall)
                                    
                                    HStack {
                                        Spacer()
                                        Text("Won".localized)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .padding(.trailing, length: .xxSmall)
                                        
                                        Text(viewModel.getWinsCountCopy(for: sub.key))
                                            .foregroundColor(.green)
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        Text("Lost".localized)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .padding(.trailing, length: .xxSmall)
                                        
                                        Text(viewModel.getLossesCountCopy(for: sub.key))
                                            .foregroundColor(.red)
                                            .font(.headline)
                                        Spacer()
                                    }
                                }
                                .padding(length: .medium)
                            }
                        }
                        .padding(.bottom, length: .medium)
                    }
                    .background(.background)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationDestination(for: SubmissionsDestinations.self) { destination in
                switch destination {
                case .subDetails:
                    SubmissionDetailsView(with: viewModel.createSubmissionDetailsViewModel())
                        .environmentObject(router)
                case .addNewSub:
                    AddNewSubView(viewModel: viewModel.createAddViewModel())
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
        .horizontalPadding()
    }
}
