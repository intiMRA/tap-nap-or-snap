//
//  CreateNewGoalView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 8/04/22.
//

import SwiftUI

struct CreateNewGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var focusedField: GoalsViewFocusField?
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
                .padding(.bottom, 20)
            VStack {
                Text("Time to complete")
                timeToCompleteView
            }
            Button(action: viewModel.saveGoal) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(ColorNames.bar.color())
                        .frame(maxWidth: .infinity, maxHeight: 44)
                    
                    Text("submit")
                        .foregroundColor(.cyan)
                }
            }
        }
        .padding(.horizontal, 16)
        .onReceive(viewModel.$shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                DispatchQueue.main.async {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    @ViewBuilder
    var timeToCompleteView: some View {
        HStack {
            LoginTextField("days", keyBoard: .numberPad, text: $viewModel.numberOfDays)
            
            Spacer()
            
            Button(action: { viewModel.setTimeToComplete(timeToComplete: .weeks) }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill( viewModel.timeToComplete == .weeks ? ColorNames.bar.color() : Color.gray)
                        .frame(maxWidth: .infinity, maxHeight: 44)
                    
                    Text("Weeks")
                        .foregroundColor(.cyan)
                }
            }
            
            Button(action: { viewModel.setTimeToComplete(timeToComplete: .months) }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(viewModel.timeToComplete == .months ? ColorNames.bar.color() : Color.gray)
                        .frame(maxWidth: .infinity, maxHeight: 44)
                    
                    Text("Months")
                        .foregroundColor(.cyan)
                }
            }
            
            Button(action: { viewModel.setTimeToComplete(timeToComplete: .years) }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(viewModel.timeToComplete == .years ? ColorNames.bar.color() : Color.gray)
                        .frame(maxWidth: .infinity, maxHeight: 44)
                    
                    Text("Years")
                        .foregroundColor(.cyan)
                }
            }
            
        }
    }
}

struct CreateNewGoalView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewGoalView()
    }
}
