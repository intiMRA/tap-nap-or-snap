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
                        ImageNames.add.rawIcon()
                        
                        Text("Add.New".localized)
                    }
                }
            }
            ScrollView {
                ForEach(viewModel.goalModels) { goal in
                    ZStack {
                        CustomRoundRectangle(color: color(for: goal), opacity: 0.3)
                        
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
    
    func color(for goal: GoalModel) -> Color {
        goal.isComplete ? .green : (goal.timeStamp.isPastDueDate() ? .blue : .red)
    }
}

struct GoalView: View {
    let goal: GoalModel
    @StateObject var viewModel: GoalsViewModel
    
    var body: some View {
            LazyVStack(alignment: .leading, spacing: PaddingValues.xxSmall.rawValue) {
                HStack {
                    Text(goal.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(ColorNames.text.color())
                    Spacer()
                    
                    Button(action: { viewModel.deleteGoal(with: goal.id) }) {
                        ImageNames.cancel.rawIcon()
                    }
                }
                
                HStack {
                    Text("Done.Date".localized)
                        .bold()
                    Spacer()
                    Text(goal.timeStamp.asString())
                }
                
                HStack {
                    Text("Time.Remaining".localized)
                        .bold()
                    Spacer()
                    Text(Date().difference(from: goal.timeStamp))
                }
                VStack(alignment: .leading) {
                    if viewModel.goalCollapsed[goal.id] ?? false {
                        HStack {
                            Text("Expand".localized)
                                .bold()
                            
                            Image(systemName: "chevron.down")
                        }
                        .standardHeight()
                    } else {
                        VStack(alignment: .leading) {
                            if goal.description.filter({ $0 == "\n" }).count > 1 {
                                HStack {
                                    Text("Collapse".localized)
                                        .bold()
                                    
                                    Image(systemName: "chevron.up")
                                }
                                .standardHeight()
                            }
                            
                        Text(goal.description)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .font(.body)
                            .foregroundColor(ColorNames.text.color())
                            .padding(.bottom, length: .xxxSmall)
                        }
                    }
                }
                .padding(.vertical, length: .xSmall)
                .onTapGesture {
                    withAnimation {
                        viewModel.flipGoal(with: goal.id)
                    }
                }
                
                HStack {
                    
                    Button(action: { viewModel.completeGoal(with: goal.id, status: !goal.isComplete) }) {
                        ZStack {
                            CustomRoundRectangle(color: goal.isComplete ? .yellow : .green)
                            Text(goal.isComplete ? "Reopen".localized : "Complete".localized)
                        }
                    }
                    Spacer()
                    
                    Button(action: { viewModel.showEditGoal(currentGoal: goal) }) {
                        ZStack {
                            CustomRoundRectangle(color: .blue)
                            Text("Edit".localized)
                        }
                    }
                }
                .standardHeight()
                .padding(.bottom, length: .small)
            }
            .padding(.horizontal, length: .small)
    }
}
