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
    init() {
        MonitorDataManager.shared.startUpdatingMonitorData()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView{
                ContentView(nil)
            }.environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
