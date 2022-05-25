//
//  EditGoalDetailsView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 25/05/22.
//

import SwiftUI

struct EditGoalDetailsView: View {
    @StateObject var viewModel: EditGoalDetailsViewModel
    init(_ viewModel: EditGoalDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Text(viewModel.currentGoal?.title ?? "")
    }
}
