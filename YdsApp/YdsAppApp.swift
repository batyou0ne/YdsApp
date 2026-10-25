//
//  YdsAppApp.swift
//  YdsApp
//
//  Created by Batuhan Keskin on 24.10.2026.
//

import SwiftUI

@main
struct YdsAppApp: App {
    private let container = AppDependencyContainer()

    var body: some Scene {
        WindowGroup {
            ContentView(container: container)
        }
    }
}
