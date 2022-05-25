//
//  GoalsView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 8/04/22.
//

import SwiftUI

struct GoalsView: View {
    @StateObject var viewModel: GoalsViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: GoalsViewModel())
    }
    
    var body: some View {
        VStack {
            NavigationLink(isActive: $viewModel.navigateToAddGoal, destination: { CreateNewGoalView() }) {
                EmptyView()
            }
            
            NavigationLink(isActive: $viewModel.navigateToEditGoal, destination: { EditGoalDetailsView(viewModel.createEditViewModel()) }) {
                EmptyView()
            }
            
            HStack {
                Spacer()
                Button(action: { viewModel.showAddGoal() }) {
                    VStack {
                        ImageNames.add.icon(color: ColorNames.text.color())
                        
                        Text("add new")
                    }
                }
            }
            ScrollView {
                ForEach(viewModel.goalModels) { goal in
                    ZStack {
                        CustomRoundRectangle(color: goal.timeStamp.isPastDueDate() ? .blue : Color.red)
                            .opacity(0.3)
                        
                        GoalView(goal: goal, viewModel: viewModel)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, length: .small)
                }
            }
        }
        .horizontalPadding()
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.reloadNotification), perform: { output in
            guard output.name == NSNotification.reloadNotification else {
                return
            }
            viewModel.reloadState()
        })
    }
}

struct GoalView: View {
    let goal: GoalModel
    @StateObject var viewModel: GoalsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(goal.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(ColorNames.text.color())
                Spacer()
                
                Button(action: { print("yooo") }) {
                    ImageNames.cancel.rawIcon()
                }
            }
            
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
            VStack(alignment: .leading) {
                Text("description: ")
                    .padding(.bottom, length: .xxxSmall)
                
                Text(goal.description)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .font(.body)
                    .foregroundColor(ColorNames.text.color())
            }
            
            HStack {
                Button(action: {}) {
                    ZStack {
                        CustomRoundRectangle(color: .green)
                        Text("Complete")
                    }
                }
                Spacer()
                
                Button(action: { viewModel.showEditGoal(currentGoal: goal) }) {
                    ZStack {
                        CustomRoundRectangle(color: .blue)
                        Text("Edit")
                    }
                }
            }
            .standardHeight()
            .padding(.bottom, length: .small)
        }
        .padding(.horizontal, length: .small)
    }
}
