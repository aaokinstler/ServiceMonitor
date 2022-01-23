//
//  ServerClient.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 16.01.2022.
//

import Foundation
import Alamofire

struct ServerClient {
    
    func getMonitorStatus() {
//        AF.request(Endpoints.getMonitorStatus.stringValue, method: .get).responseDecodable(of: MonitorGroup.self) {
//            
//        }
        
    }
    
    enum Endpoints {
        static let base = "https://bonus.1hmm.ru/MonitorService/rest/methods/"
        
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
