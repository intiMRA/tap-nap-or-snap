//
//  SubmissionDetailsView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 3/05/22.
//

import SwiftUI

struct SubmissionDetailsView: View {
    @StateObject var viewModel: SubmissionDetailsViewModel
    @EnvironmentObject var router: Router
    
    init(with viewModel: SubmissionDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                Text(viewModel.submissionName)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(viewModel.submissionsList, id: \.personName) { sub in
                    Button(action: {
                        Task {
                            await viewModel.setDescription(for: sub.personName)
                            router.stack.append(SubmissionDetailsDestinations.subDescription)
                        }
                    }) {
                        ZStack {
                            CustomRoundRectangle(color: .blue, opacity: 0.3)
                            VStack(alignment: .center) {
                                Text(sub.personName)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .padding(.bottom, length: .xxSmall)
                                
                                HStack {
                                    Spacer()
                                    Text("Won".localized)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .padding(.trailing, length: .xxSmall)
                                    
                                    Text(viewModel.getWinsCountCopy(for: sub))
                                        .foregroundColor(.green)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Text("Lost".localized)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .padding(.trailing, length: .xxSmall)
                                    
                                    Text(viewModel.getLossesCountCopy(for: sub))
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
            }
            .frame(maxWidth: .infinity)
            .horizontalPadding()
            .navigationDestination(for: SubmissionDetailsDestinations.self) { destination in
                switch destination {
                case .subDescription:
                    SubmissionDescriptionView(viewModel: viewModel.createDescriptionViewModel())
                        .environmentObject(router)
                }
            }
        }
    }
}
