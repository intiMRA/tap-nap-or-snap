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
    case medal = "Medal"
    case user = "User"
    case add = "Add"
    case trash = "Trash"
    
    func image() -> Image {
        Image(self.rawValue)
            .resizable()
    }
}
