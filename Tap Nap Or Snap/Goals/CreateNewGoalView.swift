//
//  CreateNewGoalView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 8/04/22.
//

import SwiftUI

struct CreateNewGoalView: View {
    @FocusState private var focusedField: FocusField?
    @StateObject var viewModel = CreateNewGoalViewModel()
    var body: some View {
        VStack {
            LoginTextField("title", keyBoard: .alphabet, text: $viewModel.title)
                .focused($focusedField, equals: .title)
                .onTapGesture {
                    self.focusedField = .title
                    viewModel.isFocused(.title)
                }
            TextEditor(text: viewModel.description.isEmpty ? $viewModel.placeholder : $viewModel.description)
                .focused($focusedField, equals: .description)
                .font(viewModel.description.isEmpty ? .callout : .body)
                .opacity(viewModel.description.isEmpty ? 0.3 : 1)
                .onTapGesture {
                    self.focusedField = .description
                    viewModel.isFocused(.description)
                }
        }
        .padding(.horizontal, 16)
    }
}

struct CreateNewGoalView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewGoalView()
    }
}
