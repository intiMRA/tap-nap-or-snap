//
//  SubmissionDescriptionView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 6/05/22.
//

import SwiftUI

struct SubmissionDescriptionView: View {
    @StateObject var viewModel: SubmissionDescriptionViewModel
    init(viewModel: SubmissionDescriptionViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        VStack {
            Text(viewModel.title)
                .font(.title)
                .padding(.bottom, 20)
            
            Text(viewModel.winsTitle)
                .font(.title3)
                .padding(.bottom, 20)
                .foregroundColor(.green)
            
            ForEach(viewModel.winDescriptions) { model in
                Text(model.description)
                    .padding(.bottom, 10)
            }
            
            Text(viewModel.lossesTitle)
                .font(.title3)
                .padding(.bottom, 20)
                .foregroundColor(.red)
            
            ForEach(viewModel.lossesDescriptions) { model in
                Text(model.description)
                    .padding(.bottom, 10)
            }
        }
    }
}
