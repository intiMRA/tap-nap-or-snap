//
//  NavigationDestinations.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 11/10/22.
//

import Foundation
import SwiftUI

enum LogInDestinations: String {
    case tabView
}

enum SubmissionsDestinations: String {
    case addNewSub
    case subDetails
}

enum SubmissionDetailsDestinations: String {
    case subDescription 
}

class Router: ObservableObject {
    @Published var stack = NavigationPath()
}
