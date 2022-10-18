//
//  View+CutomPadding.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 24/05/22.
//

import Foundation
import SwiftUI
enum PaddingValues: CGFloat {
    case none = 0
    case xxxSmall = 2
    case xxSmall = 4
    case xSmall = 8
    case small = 10
    case medium = 16
    case large = 20
    case xLarge = 32
    case twoHundred = 200
}

extension View {
    func horizontalPadding() -> some View {
        self.padding(.horizontal, PaddingValues.medium.rawValue)
    }
    
    func verticalPadding() -> some View {
        self.padding(.vertical, PaddingValues.medium.rawValue)
    }
    
    func padding(_ edges: Edge.Set = .all, length: PaddingValues) -> some View {
        self.padding(edges, length.rawValue)
    }
    
    func standardHeight() -> some View {
        self.frame(idealHeight: 44, maxHeight: 44)
    }
    
    func standardHeightFillUp() -> some View {
        self.frame(maxWidth: .infinity, idealHeight: 44, maxHeight: 44)
    }
    
    func frame(size: CGFloat) -> some View {
        self.frame(width: 44, height: 44)
    }
}
