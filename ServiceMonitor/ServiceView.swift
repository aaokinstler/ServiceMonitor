//
//  ServiceView.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 16.01.2022.
//

import SwiftUI

struct ServiceView: View {
    
    @ObservedObject var service: Service
    @State var editing: Bool = false
    
    var body: some View {
        Form {
            nameSection
            groupSection
            descriptionSection
            typeSection
            addressSection
            intervalSection
        }
    }
    
    var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("Name", text: $service.name)
        }
    }
    
    var groupSection: some View {
        Section(header: Text("Group")) {
            
        }
    }
    
    var descriptionSection: some View {
        Section(header: Text("Description")) {
            
        }
    }
    
    var typeSection: some View {
        Section(header: Text("Type")) {
            
        }
    }
     
    var addressSection: some View {
        Section(header: Text("Address")) {
            
        }
    }
    
    var intervalSection: some View {
        Section(header: Text("Interval")) {
            
        }
    }
}

//struct ServiceView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServiceView()
//    }
//}
