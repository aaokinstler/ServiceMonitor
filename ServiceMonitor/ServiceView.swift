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
    @ObservedObject var service: Service
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var timeFromLastExecution: String = ""
   
    
    var body: some View {
        Form {
            statusData
            serviceInfoSection
            serviceTypeSection
            saveButton.disabled(!service.hasChanges)
        }.onAppear {
            updateExecutionTime(nil)
        }
        .onDisappear(perform: deleteIfObjectNotSaved)
    }
    
    var serviceInfoSection: some View {
        Section(header: Text("Service info")) {
            VStack(alignment: .leading) {
                Text("Name").font(.footnote)
                TextField("Name", text: $service.name)
            }
            
            VStack(alignment: .leading) {
                Text("Description").font(.footnote)
                TextEditor(text: $service.descr).frame(minHeight: 80)
            }

            Picker("Group", selection: $service.group) {
                ForEach(groups, id: \.self) { (group: Group?) in
                    Text("\(group?.name ?? "Empty")").tag(group)
                }
            }
        }
    }
    
    var serviceTypeSection: some View {
        Section(header: Text("Type")) {
            Picker("Type", selection: $service.type) {
                ForEach(ServiceTypes.allCases) { type in
                    Text(type.stringValue).tag(type.rawValue)
                }
            }
            if service.type == 2 {
                TextField("Address", text: $service.address)
            } else {
                HStack {
                    Text("Interval")
                    TextField("0", text: $service.stringInterval)
                        .keyboardType(.numberPad)
                }
            }
        }
    }
    
    var statusData: some View {
        Section(header: Text("Status info")) {
            HStack {
                Label {
                    Text("Status: \(service.status?.name ?? "Never")")
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
    
    var saveButton: some View {
        Button("Save") {
            try! viewContext.save()
        }
    }
    
    private func updateExecutionTime(_ : Any?) {
        timeFromLastExecution = service.timeFromLastExecution
    }
    
    private func deleteIfObjectNotSaved() {
        if service.isInserted {
            viewContext.delete(service)
        }
    }
}

//struct ServiceView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServiceView()
//    }
//}
