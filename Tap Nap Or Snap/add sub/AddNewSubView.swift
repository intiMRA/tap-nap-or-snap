//
//  AddNewSub.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 19/03/22.
//

import SwiftUI

struct AddNewSubView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = AddNewSubViewModel()
    
    var body: some View {
        VStack {
            TextField("Persons Name", text: $viewModel.name)
            Button(action: viewModel.presentSubsList) {
                if let sub = viewModel.sub {
                    Text(sub.name)
                } else {
                    Text("Add sub")
                }
            }
        }
        .padding(.horizontal, 16)
        .navigationTitle("New Tap")
        .sheet(isPresented: $viewModel.showSubsList, onDismiss: { }) {
            subsList
                .padding(.horizontal, 16)
                .padding(.top, 20)
        }
    }
    
    @ViewBuilder
    var subsList: some View {
        VStack {
            HStack {
                Text("Armbar")
                Spacer()
                Button(action: {}) {
                    ImageNames.trash.image()
                        .frame(width: 24, height: 24)
                }
            }
            Button(action: viewModel.presentCreateSubView) {
                VStack {
                    ImageNames.add.image()
                        .frame(width: 24, height: 24)
                    Text("add new")
                }
            }
            Spacer()
        }
        .sheet(isPresented: $viewModel.showCreateSubView, onDismiss: {}) {
            createNewSub
                .padding(.horizontal, 16)
                .padding(.top, 20)

        }
    }
    
    @ViewBuilder
    var createNewSub: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {}) {
                    Text("save")
                        .foregroundColor(.cyan)
                }
            }
            
            ImageNames.add.image()
                .frame(width: 100, height: 100)
                .contentShape(RoundedRectangle(cornerRadius: 5))
                .border(Color.black, width: 1)
            Spacer()
        }
    }
}

struct AddNewSub_Previews: PreviewProvider {
    static var previews: some View {
        AddNewSubView()
    }
}
