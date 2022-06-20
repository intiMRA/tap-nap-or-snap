//
//  EditGoalDetailsView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 25/05/22.
//

import SwiftUI

struct EditGoalDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: EditGoalDetailsViewModel
    @FocusState var focusState: Bool?
    init(_ viewModel: EditGoalDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text(viewModel.currentGoal?.title ?? "")
                    .font(.title)
                    .bold()
                    .padding(.bottom, length: .medium)
                
                ZStack {
                    TextEditor(text: $viewModel.description)
                        .font(.body)
                        .opacity(1)
                        .focused($focusState, equals: true)
                    
                    CustomRoundRectangle(color: ColorNames.text.color(opacity: .ten))
                }
                .frame(height: 200)
                .padding(.bottom, length: .medium)
                .onTapGesture {
                    self.focusState = true
                }
                
                Button(action: { viewModel.saveDescription() }) {
                    ZStack {
                        CustomRoundRectangle(color: .blue)
                        Text("Done".localized)
                    }
                }
                .standardHeightFillUp()
                
                Spacer()
            }
        }
        .background(.background)
        .padding(.top, length: .large)
        .horizontalPadding()
        .onReceive(viewModel.$shouldDismiss) { value in
            if value {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .alert(viewModel.error?.title ?? "", isPresented: $viewModel.showAlert, actions: { EmptyView() }) {
            Text(viewModel.error?.message ?? "")
        }
    }
}
