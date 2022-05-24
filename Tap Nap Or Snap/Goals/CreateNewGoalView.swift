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
                .padding(.bottom, length: .large)
            
            VStack {
                Text("Time to complete")
                timeToCompleteView
            }
            Button(action: viewModel.saveGoal) {
                ZStack {
                    CustomRoundRectangle(color: ColorNames.bar.color())
                        .standardHeightFillUp()
                    
                    Text("submit")
                        .foregroundColor(.cyan)
                }
            }
        }
        .horizontalPadding()
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
                    GoalsRectangle(useBarColor: viewModel.timeToComplete == .weeks)
                    
                    Text("Weeks")
                        .foregroundColor(.cyan)
                }
            }
            
            Button(action: { viewModel.setTimeToComplete(timeToComplete: .months) }) {
                ZStack {
                    GoalsRectangle(useBarColor: viewModel.timeToComplete == .months)
                    
                    Text("Months")
                        .foregroundColor(.cyan)
                }
            }
            
            Button(action: { viewModel.setTimeToComplete(timeToComplete: .years) }) {
                ZStack {
                    GoalsRectangle(useBarColor: viewModel.timeToComplete == .years)
                    
                    Text("Years")
                        .foregroundColor(.cyan)
                }
            }
            
        }
    }
}

struct GoalsRectangle: View {
    let useBarColor: Bool
    var body: some View {
        CustomRoundRectangle(color: useBarColor ? ColorNames.bar.color() : Color.gray)
            .standardHeightFillUp()
    }
}

struct CreateNewGoalView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewGoalView()
    }
}
