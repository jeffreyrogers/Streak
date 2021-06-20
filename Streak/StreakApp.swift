//
//  StreakApp.swift
//  Streak
//
//  Created by Jeffrey Rogers on 6/20/21.
//

import SwiftUI

@main
struct StreakApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
