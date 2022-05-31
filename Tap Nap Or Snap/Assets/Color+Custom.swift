//
//  Color+Custom.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 16/03/22.
//

import Foundation
import SwiftUI
enum ColorOpacity: Double {
    case ten = 0.1
    case twenty = 0.2
    case thirty = 0.3
    case forty = 0.4
    case fifty = 0.5
    case sixty = 0.6
    case seventy = 0.7
    case eighty = 0.8
    case ninety = 0.9
    case hundred = 1
}
enum ColorNames: String {
    case background = "Background"
    case text = "Text"
    case bar = "Bar"
    func color(opacity: ColorOpacity = .hundred) -> Color {
        Color(self.rawValue)
            .opacity(opacity.rawValue)
    }
}

extension View {
    func foregroundColor(_ colorName: ColorNames) -> some View {
        self.foregroundColor(colorName.color())
    }
    
    func backgroundColor(_ colorName: ColorNames) -> some View {
        self.background(colorName.color())
    }
}
