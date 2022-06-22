//
//  Image+Custom.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 16/03/22.
//

import Foundation
import SwiftUI

enum ImageNames: String {
    case tomoeNage = "TomoeNage"
    case dead = "Dead"
    case deadDisabled = "DeadDisabled"
    case medal = "Medal"
    case target = "Target"
    case targetDisabled = "TargetDisabled"
    case add = "Add"
    case trash = "Trash"
    case cancel = "Cancel"
    case confirm = "Confirm"
    case edit = "Edit"
    case eye = "Eye"
    
    func image() -> Image {
        Image(self.rawValue)
            .resizable()
    }
    
    func icon(color: Color = ColorNames.text.color()) -> some View {
        Image(self.rawValue)
            .resizable()
            .renderingMode(.template)
            .foregroundColor(color)
            .frame(width: 24, height: 24)
    }
    
    func rawIcon() -> some View {
        Image(self.rawValue)
            .resizable()
            .frame(width: 24, height: 24)
    }
}
