//
//  GoalsView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 8/04/22.
//

import SwiftUI

struct GoalsView: View {
    @StateObject var viewModel = GoalsViewModel()
    var body: some View {
        VStack {
            NavigationLink(isActive: $viewModel.navigateToAddGoal, destination: { CreateNewGoalView() }) {
                EmptyView()
            }
            HStack {
                Spacer()
                Button(action: viewModel.showAddGoal) {
                    VStack {
                        ImageNames.add.image()
                            .renderingMode(.template)
                            .foregroundColor(ColorNames.text.color())
                            .frame(width: 24, height: 24)
                        Text("add new")
                    }
                }
            }
            ScrollView {
                ForEach(viewModel.goalModels) { goal in
                    VStack {
                        Text(goal.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(ColorNames.text.color())
                        
                        Text(goal.description)
                            .font(.body)
                            .foregroundColor(ColorNames.text.color())
                    }
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(ColorNames.text.color())
                    )
                    .padding(.bottom, 20)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
    }
}
