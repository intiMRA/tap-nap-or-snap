//
//  CustomRoundRectangle.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 24/05/22.
//

import SwiftUI

struct CustomRoundRectangle: View {
    let color: Color
    let opacity: CGFloat
    init(color: Color = .clear, opacity: CGFloat = 1) {
        self.color = color
        self.opacity = opacity
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(color)
            .opacity(opacity)
    }
}
