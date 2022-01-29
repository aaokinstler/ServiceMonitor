//
//  Group+Extension.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 16.09.2021.
//
import CoreData

extension Group: Comparable {
    
    var numberOfServicesOk: Int {
        services.filter{($0 as AnyObject).status?.id == 1}.count
    }
    
    var colorId: Int {
        if services.count == numberOfServicesOk {
            return 1
        } else {
            return 3
        }
    }
    
    var services: Set<Service> {
        get {(services_ as? Set<Service>) ?? [] }
        set { services_ = newValue as NSSet }
    }
    
    // Get core data instance
    class func instance(id: Int, context: NSManagedObjectContext) -> Group? {
        let request:NSFetchRequest<Group> = Group.fetchRequest()
        let predicate = NSPredicate(format: "monitorId == %ld", id)
        request.predicate = predicate

        do {
            let objects = try context.fetch(request)
            return objects.first
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // Cteate object from server
    class func createEntityObject(data: MonitorGroup, parentGroup: Group?, context: NSManagedObjectContext) -> Group {
        let newGroup = NSEntityDescription.insertNewObject(forEntityName: "Group", into: context) as! Group
        newGroup.setValue(data.id, forKey: "monitorId")
        newGroup.setValue(data.name, forKey: "name_")
        newGroup.setValue(parentGroup, forKey: "group")
        
        
        data.sevicesWithStatus.forEach { service in
            newGroup.addToServices_(Service.createEntityObject(data: service, parentGroup: newGroup, context: context))
        }
        
        data.gruops.forEach { group in
            newGroup.addToGroups(Group.createEntityObject(data: group, parentGroup: newGroup, context: context))
        }
        
        return newGroup
    }
    
    // Create empty object to fill it on client.
    class func createEntityObject(context: NSManagedObjectContext) -> Group {
        let newGroup = NSEntityDescription.insertNewObject(forEntityName: "Group", into: context) as! Group
        return newGroup
    }
    
    // Update object from server
    func updateGroupStatus(data: MonitorGroup, parentGroup: Group?) {
        let context = self.managedObjectContext!
        var ids: [Int] = []
        
        if self.name != data.name {
            self.name = data.name
        }
        
        if self.group != parentGroup {
            self.group = parentGroup
        }
        
        data.sevicesWithStatus.forEach { service in
            if let serviceObject = Service.instance(id: service.id!, context: context) {
                serviceObject.updateStatus(data: service)
            } else {
                self.addToServices_(Service.createEntityObject(data: service, parentGroup: self, context: context))
            }
            ids.append(service.id!)
        }
        
        deleteSubServices(ids: ids, context: context)
        ids.removeAll()
        
        data.gruops.forEach { group in
            if let groupObject = Group.instance(id: group.id, context: context) {
                groupObject.updateGroupStatus(data: group, parentGroup: self)
            } else {
                self.addToGroups(Group.createEntityObject(data: group, parentGroup: self, context: context))
            }
            ids.append(group.id)
        }
        
        deleteSubGroups(ids: ids, context: context)
    }
    
    // Delete groups deleted on server
    func deleteSubGroups(ids: [Int], context: NSManagedObjectContext) {
        let predicate = NSPredicate(format: "NOT (monitorId IN %@)", ids)
        
        let groupsToDelete = self.groups?.filtered(using: predicate)
        groupsToDelete?.forEach() { group in
            context.delete(group as! NSManagedObject)
        }
    }
    
    // Delete services deleted on server
    func deleteSubServices(ids: [Int], context: NSManagedObjectContext) {
        let predicate = NSPredicate(format: "NOT (monitorId IN %@)", ids)
        
        let groupsToDelete = self.services_?.filtered(using: predicate)
        groupsToDelete?.forEach() { group in
            context.delete(group as! NSManagedObject)
        }
    }
    
//    func deleteSubObjects(ids: [Int], entityName: String, context: NSManagedObjectContext) {
//
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
//        let predicate = NSPredicate(format: "NOT (monitorId IN %@)",  ids)
//        fetchRequest.predicate = predicate
//
//        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        do {
//            try managedObjectContext?.execute(batchDeleteRequest)
//        } catch {
//            print(error)
//        }
//
//    }

    // Get object for server exchange
    func getMonitorGroup() -> MonitorGroup {
        var parentGroupId: Int? = nil
        if let group = group  {
            parentGroupId = Int(group.monitorId)
        }
        
        let object = MonitorGroup(id: self.isInserted ? nil : Int(self.monitorId), name: self.name, parent: parentGroupId, sevicesWithStatus: nil, gruops: nil)
        return object
    }
    

    public static func < (lhs: Group, rhs: Group) -> Bool {
        lhs.name < rhs.name 
    }
    
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Group> {
        let request = NSFetchRequest<Group>(entityName: "Group")
        request.sortDescriptors = [NSSortDescriptor(key: "name_", ascending: true)]
        request.predicate = predicate
        return request
    }
}
