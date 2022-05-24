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
                        HStack {
                            Text(sub.personsName)
                            Text("\(sub.numberOfWins) \(sub.numberOfWins == 1 ? "win" : "wins")")
                                .foregroundColor(.green)
                            
                            Text("\(sub.numberOfLosses) \(sub.numberOfLosses == 1 ? "loss" : "losses")")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.bottom, length: .small)
                }
            }
            .frame(maxWidth: .infinity)
            .horizontalPadding()
        }
    }
}
