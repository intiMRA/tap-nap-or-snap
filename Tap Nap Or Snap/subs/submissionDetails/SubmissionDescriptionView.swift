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
        ScrollView {
            VStack(alignment: .leading) {
                LeftAlignedTextView(viewModel.title)
                    .font(.title)
                    .padding(.bottom, length: .large)
                ZStack {
                    CustomRoundRectangle(color: ColorNames.text.color(), opacity: 0.1)
                    
                VStack(alignment: .leading) {
                    LeftAlignedTextView(viewModel.winsTitle)
                        .font(.title3)
                        .padding(.all, length: .small)
                        .foregroundColor(.green)
                    
                    LeftAlignedTextView(viewModel.text(for: viewModel.winDescriptions))
                        .padding(.bottom, length: .small)
                        .padding(.horizontal, length: .small)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, length: .small)
                
                ZStack {
                    CustomRoundRectangle(color: ColorNames.text.color(), opacity: 0.1)
                    
                VStack(alignment: .leading) {
                    LeftAlignedTextView(viewModel.lossesTitle)
                        .font(.title3)
                        .padding(.all, length: .small)
                        .foregroundColor(.red)

                    LeftAlignedTextView(viewModel.text(for: viewModel.lossesDescriptions))
                        .padding(.bottom, length: .small)
                        .padding(.horizontal, length: .small)

                }
                .frame(maxWidth: .infinity)
                }
            }
        }
        .horizontalPadding()
        .padding(.vertical, length: .large)
    }
}

struct LeftAlignedTextView: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
