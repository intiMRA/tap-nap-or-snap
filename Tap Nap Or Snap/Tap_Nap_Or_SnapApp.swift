//
//  Tap_Nap_Or_SnapApp.swift
//  Tap Nap Or Snap
//
//  Created by Inti Albuquerque on 16/03/22.
//

import SwiftUI
import Firebase

@main
struct Tap_Nap_Or_SnapApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var stack = Router()
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $stack.stack) {
                LogInView()
                    .navigationBarTitleDisplayMode(.inline)
                    .environmentObject(stack)
            }
            .navigationViewStyle(.stack)
            .accentColor(ColorNames.text.color())
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UITextView.appearance().backgroundColor = .clear
        return true
    }
}
