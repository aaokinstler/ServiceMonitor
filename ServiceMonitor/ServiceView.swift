//
//  ServiceView.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 16.01.2022.
//

import SwiftUI

struct ServiceView: View {
    
    @FetchRequest(fetchRequest: Group.fetchRequest(.all)) var groups: FetchedResults<Group>
    @ObservedObject var service: Service
    @State var editing: Bool = false
    
    var body: some View {
        Form {
            nameSection
            groupSection
            descriptionSection
            typeSection
            if service.type == 2 {
                addressSection
            } else {
                intervalSection
            }
            
            saveButton.disabled(!service.hasChanges)
        }
    }
    
    var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("Name", text: $service.name)
        }
    }
    
    var groupSection: some View {
        Section(header: Text("Group")) {
            Picker("Group", selection: $service.group) {
                ForEach(groups, id: \.self) { (group: Group?) in
                    Text("\(group?.name ?? "Empty")").tag(group)
                }
                
            }
        }
    }
    
    var descriptionSection: some View {
        Section(header: Text("Description")) {
            TextEditor(text: $service.descr)
                .frame(minHeight: 80)
        }
    }
    
    var typeSection: some View {
        Section(header: Text("Type")) {
            Picker("Type", selection: $service.type) {
                ForEach(ServiceTypes.allCases) { type in
                    Text(type.stringValue).tag(type.rawValue)
                }
            }
        }
    }
     
    var addressSection: some View {
        Section(header: Text("Address")) {
            TextField("Address", text: $service.address)
        }
    }
    
    var intervalSection: some View {
        Section(header: Text("Interval")) {
            TextField("Name", text: $service.stringInterval)
                .keyboardType(.numberPad)
            
        }
    }
    
    var saveButton: some View {
        Button("Save") {
            print("save button tapped")
        }
    }
}

//struct ServiceView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServiceView()
//    }
//}
