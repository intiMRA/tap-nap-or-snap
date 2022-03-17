//
//  TappedView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 17/03/22.
//

import SwiftUI

struct TappedView: View {
    var body: some View {
        ScrollView {
            VStack {
                ForEach(0...100, id:\.self) { number in
                    Text("number\(number)")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 16)

    }
}

struct TappedView_Previews: PreviewProvider {
    static var previews: some View {
        TappedView()
    }
}
