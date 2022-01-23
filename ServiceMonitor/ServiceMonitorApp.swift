//
//  ServiceMonitorApp.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 16.01.2022.
//

import SwiftUI

@main
struct ServiceMonitorApp: App {
    let persistenceController = PersistenceController.shared
    let monitorDataManagerNew = MonitorDataManager().updateMonitorData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
