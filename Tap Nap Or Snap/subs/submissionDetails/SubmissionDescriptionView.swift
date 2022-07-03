//
//  SubmissionDescriptionView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 6/05/22.
//

import SwiftUI

struct SubmissionDescriptionView: View {
    @StateObject var viewModel: SubmissionDescriptionViewModel
    @FocusState private var focusedField: SubmissionDescriptionViewFocusField?
    @Environment(\.presentationMode) var presentationMode
    init(viewModel: SubmissionDescriptionViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                LeftAlignedTextView(viewModel.title)
                    .font(.title)
                    .padding(.bottom, length: .large)
                
                VStack(alignment: .leading) {
                    LeftAlignedTextView(viewModel.winsTitle)
                        .font(.title3)
                        .padding(.all, length: .small)
                        .foregroundColor(.green)
                    
                    ZStack {
                        CustomRoundRectangle(color: ColorNames.text.color(opacity: .ten))
                        
                        TextEditor(text: viewModel.winDescription.isEmpty ? $viewModel.winPlaceholder : $viewModel.winDescription)
                            .focused($focusedField, equals: .wins)
                            .font(viewModel.winDescription.isEmpty ? .callout : .body)
                            .opacity(viewModel.winDescription.isEmpty ? 0.3 : 1)
                    }
                    .frame(height: 200)
                    .padding(.bottom, length: .medium)
                    .onTapGesture {
                        self.focusedField = .wins
                        viewModel.isFocused(.wins)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, length: .small)
                
                VStack(alignment: .leading) {
                    LeftAlignedTextView(viewModel.lossesTitle)
                        .font(.title3)
                        .padding(.all, length: .small)
                        .foregroundColor(.red)
                    
                    ZStack {
                        CustomRoundRectangle(color: ColorNames.text.color(opacity: .ten))
                        
                        TextEditor(text: viewModel.lossesDescription.isEmpty ? $viewModel.lossesPlaceholder : $viewModel.lossesDescription)
                            .focused($focusedField, equals: .losses)
                            .font(viewModel.lossesDescription.isEmpty ? .callout : .body)
                            .opacity(viewModel.lossesDescription.isEmpty ? 0.3 : 1)
                    }
                    .frame(height: 200)
                    .padding(.bottom, length: .medium)
                    .onTapGesture {
                        self.focusedField = .losses
                        viewModel.isFocused(.losses)
                    }
                    
                }
                .frame(maxWidth: .infinity)
                
                Button(action: { viewModel.saveDescriptions() }) {
                    ZStack {
                        CustomRoundRectangle(color: .blue)
                        Text("Done".localized)
                    }
                }
                .standardHeightFillUp()
            }
            .padding(.bottom, length: .medium)
        }
        .horizontalPadding()
        .padding(.vertical, length: .large)
        .onReceive(viewModel.$shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .alert(viewModel.error?.title ?? "", isPresented: $viewModel.showAlert, actions: { EmptyView() }) {
            Text(viewModel.error?.message ?? "")
        }
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
