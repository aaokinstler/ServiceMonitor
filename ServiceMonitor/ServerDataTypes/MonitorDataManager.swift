//
//  DataManager.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 02.09.2021.
//
import CoreData
//import SwiftUI
import Alamofire
import Combine
// The class is responsible for updating data from the server.
class MonitorDataManager {
    var cancellable: AnyCancellable?
    var fetchTimer: Timer?
    let fetchInterval: TimeInterval = 15
    let backgroundContext: NSManagedObjectContext

    init() {
        backgroundContext = PersistenceController.shared.container.newBackgroundContext()
    }

//
//    // MARK: Saving
//    func saveViewContext() {
//        if viewContext.hasChanges {
//            do {
//                try viewContext.save()
//            } catch {
//                print(error)
//            }
//        }
//    }
//
//    private func saveBackgroundContext() {
//        if backgroundContext.hasChanges {
//            do {
//                try backgroundContext.save()
//            } catch {
//                print(error)
//            }
//        }
//    }
//
//
    
    // Starts updating monitor information every fetchInterval seconds.
    func startUpdatingMonitorData() {
        updateMonitorData()
        fetchTimer = Timer.scheduledTimer(withTimeInterval: fetchInterval, repeats: true, block: { [weak self] timer in
            self?.updateMonitorData()
        })
    }
    
    // Stops auto-refresh monitor
    func stopUpdatingMonitorData() {
        cancellable?.cancel()
        fetchTimer?.invalidate()
    }
    
    // MARK: Update monitor
    // Updating all information about groups and services.
    func updateMonitorData() {
        cancellable = AF.request(Endpoints.getMonitorStatus.stringValue)
            .publishDecodable(type: [MonitorGroup].self)
            .sink(receiveValue: handleMonitorStatus(_:))
    }

    private func handleMonitorStatus(_ responce: DataResponsePublisher<[MonitorGroup]>.Output) {
        backgroundContext.perform {
            guard let monitorGroups = responce.value else {
                return
            }

            var ids: [Int] = []

            monitorGroups.forEach{ group in
                if let groupObject = Group.instance(id: group.id!, context: self.backgroundContext) {
                    groupObject.updateGroupStatus(data: group, parentGroup: nil)
                } else {
                    _ = Group.createEntityObject(data: group, parentGroup: nil, context: self.backgroundContext)
                }
                ids.append(group.id!)
            }

    //        deleteRootGroups(ids: ids)
    //        NotificationCenter.default.post(name: .didUpdateGroup, object: nil)
            
            try! self.backgroundContext.save()
        }
    }
//
//
//    // Delete groups that was deleted on server
//    private func deleteRootGroups(ids: [Int]) {
//        let request:NSFetchRequest<Group> = Group.fetchRequest()
//        let predicate = NSPredicate(format: "group == nil && NOT (monitorId IN %@)", ids)
//        request.predicate = predicate
//
//        let groupsToDelete =  try! backgroundContext.fetch(request)
//        groupsToDelete.forEach() { groupToDelete in
//            backgroundContext.delete(groupToDelete)
//        }
//
//    }
//
//    // MARK: Update group
//    func updateGroupData(id: Int) {
//        backgroundContext.perform {
//            ServiceClient.getGroupStatus(id: id, completion: self.handleGroupStatus(monitorGroup:error:))
//        }
//    }
//
//    private func handleGroupStatus(monitorGroup: MonitorGroup?, error: String?) {
//        guard error == nil else {
//            let errorDataDict:[String: String] = ["error": error!]
//            NotificationCenter.default.post(name: .didReceiveError, object: nil, userInfo: errorDataDict)
//            return
//        }
//
//        // MARK: Delete
//        if backgroundContext.hasChanges {
//            print("background context has changes")
//        }
//
//        if dataController.viewContext.hasChanges {
//            print("view cintext has changes")
//        }
//
//        guard let groupObject = Group.instance(id: monitorGroup!.id, context: backgroundContext) else {
//            let errorDataDict:[String: String] = ["error": "Parent group for group currently being updated was not found."]
//            NotificationCenter.default.post(name: .didReceiveError, object: nil, userInfo: errorDataDict)
//            return
//        }
//
//        var parentGroup: Group? = nil
//
//        if let parentGroupId = monitorGroup?.parent {
//            parentGroup = Group.instance(id: parentGroupId, context: backgroundContext)
//        }
//
//        groupObject.updateGroupStatus(data: monitorGroup!, parentGroup: parentGroup, context: backgroundContext)
//
//        if dataController.viewContext.hasChanges {
//            print("view cintext has changes")
//        }
//
//        saveBackgroundContext()
//        NotificationCenter.default.post(name: .didUpdateGroup, object: nil)
//    }
//
//    // MARK: Update service
//    func updateServiceData(id: Int) {
//        backgroundContext.perform {
//            ServiceClient.getServiceStatus(id: id, completion: self.handleServiceUpdate(monitorService:error:))
//        }
//    }
//
//    private func handleServiceUpdate(monitorService: MonitorService?, error: String?) {
//        guard error == nil else {
//            let errorDataDict:[String: String] = ["error": error!]
//            NotificationCenter.default.post(name: .didReceiveError, object: nil, userInfo: errorDataDict)
//            return
//        }
//
//        guard let serviceObject = Service.instance(id: monitorService!.id!, context: backgroundContext)  else {
//            let errorDataDict:[String: String] = ["error": "Service currently being updated was not found."]
//            NotificationCenter.default.post(name: .didReceiveError, object: nil, userInfo: errorDataDict)
//
//            return
//        }
//
//        guard let parentGroup = Group.instance(id: (monitorService?.parent)!, context: backgroundContext) else {
//            let errorDataDict:[String: String] = ["error": "Parent group for service currently being updated was not found."]
//            NotificationCenter.default.post(name: .didReceiveError, object: nil, userInfo: errorDataDict)
//            return
//        }
//
//        serviceObject.updateService(data: monitorService!, parentGroup: parentGroup, context: backgroundContext)
//
//        saveBackgroundContext()
//        NotificationCenter.default.post(name: .didUpdateService, object: nil)
//    }
//
//    // MARK: Seingletone
    static let shared = MonitorDataManager()
    
    enum Endpoints {
        static let base = "https://bonus.1hmm.ru/MonitorWebService-0.1/rest/methods/"
        
        case getMonitorStatus
        case addGroup
        case deleteGroup(id: Int)
        case updateGroup
        case addService
        case updateService
        case deleteService(id: Int)
        case getGroupStatus(id: Int)
        case getServiceStatus(id: Int)
        
        var stringValue: String {
            switch self {
            case .getMonitorStatus: return Endpoints.base + "GetMonitorStatus"
            case .addGroup: return Endpoints.base + "AddGroup"
            case .deleteGroup(id: let id): return Endpoints.base + "DeleteServiceGroup?id=\(id)"
            case .updateGroup: return Endpoints.base + "UpdateGroup"
            case .addService: return Endpoints.base + "AddService"
            case .updateService: return Endpoints.base + "UpdateService"
            case .deleteService(id: let id): return Endpoints.base + "DeleteService?id=\(id)"
            case .getGroupStatus(id: let id): return Endpoints.base + "GetGroup?id=\(id)"
            case .getServiceStatus(id: let id): return Endpoints.base + "GetServiceStatus?id=\(id)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // Server responce for create/update operations.
    struct MonitorResponce: Decodable {
        let success: Bool
        let id: Int? // Unique ID for created objects (Contains nil for update operations).
        let description: String? // String description of error (contains nil for success operations)
    }
}

//extension DataManager {
//
//    func autoupdateData() {
//
//        guard updatingTimeInterval > 0 else {
//            autoUpdateIsOn = false
//            return
//        }
//
//        if let object = object {
//            if object.entity.name == "Group" {
//                let groupObject = object as! Group
//                self.updateGroupData(id: Int(groupObject.monitorId))
//            } else {
//                let serviceObject = object as! Service
//                self.updateServiceData(id: Int(serviceObject.monitorId))
//            }
//
//        } else {
//            self.updateMonitorData()
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + updatingTimeInterval) {
//            self.autoupdateData()
//        }
//    }
//}
