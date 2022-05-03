//
//  SubmissionDetailsView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 3/05/22.
//

import SwiftUI

struct SubmissionDetailsView: View {
    @StateObject var viewModel: SubmissionDetailsViewModel
    
    init(with viewModel: SubmissionDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text(viewModel.name)
                    .font(.title)
                
                ForEach(viewModel.subsList, id: \.personsName) { sub in
                    HStack {
                        Text(sub.personsName)
                        Text("\(sub.numberOfWins) \(sub.numberOfWins == 1 ? "win" : "wins")")
                            .foregroundColor(.green)
                        
                        Text("\(sub.numberOfLosses) \(sub.numberOfLosses == 1 ? "loss" : "losses")")
                            .foregroundColor(.red)
                    }
                    .padding(.bottom, 10)
                }
            }
        }
    }
}
