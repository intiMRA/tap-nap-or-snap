//
//  TappedViewModel.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 17/03/22.
//

import Foundation


class TappedViewModel: ObservableObject {
    @Published var navigateToNewSub = false
    
    func showNewSub() {
        self.navigateToNewSub = true
    }
}
