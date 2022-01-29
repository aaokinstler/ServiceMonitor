//
//  Status+Extension.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 16.09.2021.
//
import CoreData

extension Status {
    
    class func createEntityObject(data: ServiceStatus, context: NSManagedObjectContext) -> Status {
        let newStatus = NSEntityDescription.insertNewObject(forEntityName: "Status", into: context) as! Status
        newStatus.setValue(data.id, forKey: "id")
        newStatus.setValue(data.name, forKey: "name")
        newStatus.setValue(data.description, forKey: "descr")
        return newStatus
    }
}
