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
                    .padding(.bottom, 20)
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(.gray)
                        .opacity(0.1)
                    
                VStack(alignment: .leading) {
                    LeftAlignedTextView(viewModel.winsTitle)
                        .font(.title3)
                        .padding(.all, 10)
                        .foregroundColor(.green)
                    
                    LeftAlignedTextView(viewModel.text(for: viewModel.winDescriptions))
                        .padding(.bottom, 10)
                        .padding(.horizontal, 10)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(.gray)
                        .opacity(0.1)
                    
                VStack(alignment: .leading) {
                    LeftAlignedTextView(viewModel.lossesTitle)
                        .font(.title3)
                        .padding(.all, 10)
                        .foregroundColor(.red)

                    LeftAlignedTextView(viewModel.text(for: viewModel.lossesDescriptions))
                        .padding(.bottom, 10)
                        .padding(.horizontal, 10)

                }
                .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
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
