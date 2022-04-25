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
                    Button(action: {}) {
                        VStack(alignment: .leading) {
                            Text(goal.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(ColorNames.text.color())
                            
                            HStack {
                                Text("done date:")
                                Spacer()
                                Text(goal.timeStamp.asString())
                            }
                            
                            HStack {
                                Text("time remaining:")
                                Spacer()
                                Text(Date().difference(from: goal.timeStamp))
                            }
                            
                            Text(goal.description)
                                .multilineTextAlignment(.leading)
                                .font(.body)
                                .foregroundColor(ColorNames.text.color())
                        }
                        .padding(.horizontal, 10)
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.reloadNotification), perform: { output in
            guard output.name == NSNotification.reloadNotification else {
                return
            }
            viewModel.reloadState()
        })
    }
}

struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
    }
}
