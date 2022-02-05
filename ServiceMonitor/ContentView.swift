//
//  ContentView.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 16.01.2022.
//

import SwiftUI
import CoreData
import Alamofire

struct ContentView: View {
    
    private var parentGroup: Group?
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var monitorObjects: FetchedResults<MonitorObject>
    @State var groupSelection: String? = nil
    @State var serviceSelection: String? = nil
    @State var groupEditing: Group? = nil
    
    init(_ group: Group!) {
        var predicate: NSPredicate
        if let group = group {
            predicate = NSPredicate(format: "group == %@", group)
            parentGroup = group
        } else {
            predicate = NSPredicate(format: "group == nil")
        }
        let request = MonitorObject.fetchRequest()
        request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "name_", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        _monitorObjects = FetchRequest(fetchRequest: request, animation: .default)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                ForEach(monitorObjects) { item in
                    if item.entity.name == "Group" {
                        let groupItem = item as! Group
                        NavigationLink(destination: ContentView(groupItem) , tag: String(groupItem.monitorId), selection: $groupSelection) {
                            GroupCardView(group: groupItem, selectGroup: selectGroup(group:), editGroup: editGroup(group:))
                                .aspectRatio(3/2, contentMode: .fit)
                        }
                        .buttonStyle(.plain)
                    } else {
                        let serviceItem = item as! Service
                        NavigationLink(destination: ServiceView(service: serviceItem) , tag: String(serviceItem.monitorId), selection: $serviceSelection) {
                            ServiceCardView(service: item as! Service) { id in
                                serviceSelection = id
                            }
                            .aspectRatio(3/2, contentMode: .fit)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(3)
        }
        .navigationBarTitle((parentGroup == nil ? "Monitor status" : parentGroup?.name)!,  displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { toolbarMenu }
        }
        .sheet(item: $groupEditing) { group in
            GroupView(group)
        }
    }
    
    private func editGroup(group: Group) {
        groupEditing = group
    }
    
    private func selectGroup(group: String) {
        groupSelection = group
    }
    
    var toolbarMenu: some View {
        Menu {
            if parentGroup != nil {
                Button {
                    let addedService = Service.createEntityObject(parentGroup: parentGroup!, context: viewContext)
                    serviceSelection = String(addedService.monitorId)
                } label: {
                    Text("Add service")
                }
            }
            
            Button {
                let newGroup = Group(context: viewContext)
                newGroup.group = parentGroup
                groupEditing = newGroup
            } label: {
                Text("Add group")
            }
            
        } label: {
            Label("Add", systemImage: "plus")
        }
    }
}


struct GroupCardView: View {
    var group: Group
    var selectGroup: (String) -> Void
    var editGroup:(Group) -> Void
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack(alignment: .leading) {
            let shape = RoundedRectangle(cornerRadius: 10)
            if colorScheme == .dark {
                shape.strokeBorder().foregroundColor(Color(customColorId: group.colorId))
            } else {
                shape.foregroundColor(Color(customColorId: group.colorId))
            }
            VStack(alignment: .leading){
                Text(group.name)
                    .bold()
                Spacer()
                Text("\(group.numberOfServicesOk)/\(group.services.count)")
                Text("ID:\(Int(group.monitorId))")
            }.padding(10)
        }
        .background {
            if colorScheme == .dark {
                Color.black
            }
        }
        .onTapGesture { selectGroup(String(group.monitorId)) }
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded { _ in
            editGroup(group)
        })
    }
}

struct ServiceCardView: View {
    var service: Service
    var closure: (String) -> Void
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                let shape = RoundedRectangle(cornerRadius: 10)
                let color = Color(customColorId: Int(service.status?.id ?? 3))
                if colorScheme == .dark {
                    shape.strokeBorder().foregroundColor(color)
                } else {
                    shape.foregroundColor(color)
                }
                VStack(alignment: .leading) {
                    Text(service.name)
                        .bold()
                    Spacer()
                    HStack {
                        Text(service.status?.name ?? "Never")
                        Spacer()
                        Text("ID:\(service.monitorId)")
                    }
                    Text(service.timeFromLastExecution)
                }
                .padding(10)
            }
            .background{
                if colorScheme == .dark {
                    Color.black
                }
            }
            .onTapGesture { closure(String(service.monitorId)) }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(nil).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
