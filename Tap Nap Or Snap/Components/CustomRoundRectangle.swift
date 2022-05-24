//
//  CustomRoundRectangle.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 24/05/22.
//

import SwiftUI

struct CustomRoundRectangle: View {
    let color: Color
    init(color: Color = .clear) {
        self.color = color
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(color)
    }
}
