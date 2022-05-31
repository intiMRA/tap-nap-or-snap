//
//  SubmissionDetailsView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 3/05/22.
//

import SwiftUI

struct SubmissionDetailsView: View {
    @StateObject var viewModel: SubmissionDetailsViewModel
    
    init(with viewModel: SubmissionDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                NavigationLink(isActive: $viewModel.navigateToDescription, destination: { SubmissionDescriptionView(viewModel: viewModel.createDescriptionViewModel()) }, label: { EmptyView() })
                
                Text(viewModel.submissionName)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(viewModel.subsList, id: \.personsName) { sub in
                    Button(action: { viewModel.showDescription(for: sub.personsName) }) {
                        ZStack {
                            CustomRoundRectangle(color: .blue, opacity: 0.3)
                            VStack(alignment: .center) {
                                Text(sub.personsName)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .padding(.bottom, length: .xxSmall)
                                
                                HStack {
                                    Spacer()
                                    Text("Won:")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .padding(.trailing, length: .xxSmall)
                                    
                                    Text(viewModel.getWinsCountCopy(for: sub))
                                        .foregroundColor(.green)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Text("Lost:")
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
        }
    }
}
