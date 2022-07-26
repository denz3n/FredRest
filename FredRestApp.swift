//
//  FredRestApp.swift
//  Shared
//
//  Created by Nathan Luksik on 5/26/21.
//

import SwiftUI

@main
struct FredRestApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView().onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        }
    }
}
