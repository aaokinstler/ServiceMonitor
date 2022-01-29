//
//  MonitorObject+Extension.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 29.01.2022.
//

import CoreData

extension MonitorObject {
    var name: String {
        get { name_ ?? "" }
        set { name_ = newValue }
    }
}
