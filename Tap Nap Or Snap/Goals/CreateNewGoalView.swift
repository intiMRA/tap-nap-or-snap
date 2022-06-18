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
        ScrollView {
            VStack {
                CustomTextField("Title".localized, keyBoard: .alphabet, text: $viewModel.title)
                    .focused($focusedField, equals: .title)
                    .onTapGesture {
                        self.focusedField = .title
                        viewModel.isFocused(.title)
                    }
                
                ZStack {
                    CustomRoundRectangle(color: ColorNames.text.color(opacity: .ten))
                    
                    TextEditor(text: viewModel.description.isEmpty ? $viewModel.placeholder : $viewModel.description)
                        .focused($focusedField, equals: .description)
                        .font(viewModel.description.isEmpty ? .callout : .body)
                        .opacity(viewModel.description.isEmpty ? 0.3 : 1)
                }
                .frame(height: 200)
                .padding(.bottom, length: .medium)
                .onTapGesture {
                    self.focusedField = .description
                    viewModel.isFocused(.description)
                }
                
                
                timeToCompleteView
                
                Button(action: viewModel.saveGoal) {
                    ZStack {
                        CustomRoundRectangle(color: .blue)
                            .standardHeightFillUp()
                        
                        Text("Submit".localized)
                            .foregroundColor(ColorNames.text.color())
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
            
            .background(.background)
        }
        .padding(.top, length: .large)
    }
    
    @ViewBuilder
    var timeToCompleteView: some View {
        VStack(alignment: .leading) {
            Text("Time to complete your goal:")
                .font(.title3)
                .bold()
                .foregroundColor(.text)
            
            HStack {
                CustomTextField("Time".localized, keyBoard: .numberPad, text: $viewModel.numberOfDays)
                
                Spacer()
                
                Button(action: { viewModel.setTimeToComplete(timeToComplete: .weeks) }) {
                    ZStack {
                        GoalsRectangle(isSelected: viewModel.timeToComplete == .weeks)
                        
                        Text("Weeks".localized)
                            .foregroundColor(.text)
                    }
                }
                
                Button(action: { viewModel.setTimeToComplete(timeToComplete: .months) }) {
                    ZStack {
                        GoalsRectangle(isSelected: viewModel.timeToComplete == .months)
                        
                        Text("Months".localized)
                            .foregroundColor(.text)
                    }
                }
                
                Button(action: { viewModel.setTimeToComplete(timeToComplete: .years) }) {
                    ZStack {
                        GoalsRectangle(isSelected: viewModel.timeToComplete == .years)
                        
                        Text("Years".localized)
                            .foregroundColor(.text)
                    }
                }
                
            }
        }
    }
}

struct GoalsRectangle: View {
    let isSelected: Bool
    var body: some View {
        CustomRoundRectangle(color: isSelected ? ColorNames.bar.color() : Color.gray)
            .standardHeightFillUp()
    }
}
