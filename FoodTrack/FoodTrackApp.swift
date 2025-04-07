//
//  FoodTrackApp.swift
//  FoodTrack
//
//  Created by Raphael Morel on 27/03/2025.
//

import SwiftUI

@main
struct FoodTrackApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
