//
//  TappedView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 17/03/22.
//

import SwiftUI

struct TappedView: View {
    @StateObject var viewModel = TappedViewModel()
    var body: some View {
        ZStack(alignment: .topLeading) {
            NavigationLink(isActive: $viewModel.navigateToNewSub, destination: { AddNewSubView(refresh: $viewModel.refresh) }, label: { EmptyView() })
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.peopleTapped.sorted(by: { $0.1.count > $1.1.count }), id: \.0) { list in
                        VStack(alignment: .leading) {
                            Text(list.0)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.bottom, 16)
                                
                            
                            ForEach(list.1.sorted(by: { $0.numberOfTimes > $1.numberOfTimes })) { sub in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("tapped: \(sub.personName ?? "")")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        
                                        Text("by: \(sub.subName)")
                                            .font(.body)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(sub.numberOfTimes) times")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                                .padding(.trailing, 32)
                            }
                            .padding(.bottom, 16)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Spacer()
                Button(action: viewModel.showNewSub) {
                    VStack {
                        ImageNames.add.image()
                            .frame(width: 24, height: 24)
                        Text("add new")
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 16)
        
    }
}

struct TappedView_Previews: PreviewProvider {
    static var previews: some View {
        TappedView()
    }
}
