//
//  TabView.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 16/03/22.
//

import SwiftUI

struct TabItemsView: View {
    var body: some View {
        TabView {
            Text("tapped")
                .tabItem {
                    Text("tapped")
                }
            
            Text("got tapped")
                .tabItem {
                    Text("got tapped")
                }
            
            Text("people")
                .tabItem {
                    Text("people")
                }
        }
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        TabItemsView()
    }
}
