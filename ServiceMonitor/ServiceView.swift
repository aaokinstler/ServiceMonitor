//
//  ServiceView.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 16.01.2022.
//

import SwiftUI

struct ServiceView: View {
    
    @FetchRequest(fetchRequest: Group.fetchRequest(.all)) var groups: FetchedResults<Group>
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var service: Service
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var timeFromLastExecution: String = ""
   
    
    var body: some View {
        Form {
            statusData
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
        }.onAppear {
            updateExecutionTime(nil)
        }
    }
    
    var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("Name", text: $service.name)
        }
    }
    
    var statusData: some View {
        Section(header: Text("Status info")) {
            HStack {
                Label {
                    Text("Status: \(service.status?.name ?? "None")")
                } icon: {
                    Circle()
                        .foregroundColor(Color(customColorId: Int(service.status?.id ?? 3)))
                        .frame( maxHeight: 13)
                }
                Spacer()
                Text("ID: \(service.monitorId)")
            }
            Text("Last upd: \(timeFromLastExecution)").onReceive(timer, perform: updateExecutionTime(_:))
            Toggle(isOn: $service.isSubscribed) {
                Text("Subscribe for notifications")
            }
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
            try! viewContext.save()
        }
    }
    
    private func updateExecutionTime(_ : Any?) {
        timeFromLastExecution = service.timeFromLastExecution
    }
}

//struct ServiceView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServiceView()
//    }
//}
