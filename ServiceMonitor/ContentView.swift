//
//  ContentView.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 16.01.2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    private var parentGroup: Group?
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var monitorObjects: FetchedResults<MonitorObject>
    
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
                        GroupCardView(group: item as! Group).aspectRatio(3/2, contentMode: .fit)
                    } else {
                        ServiceCardView(service: item as! Service).aspectRatio(3/2, contentMode: .fit)
                    }
                    
                }
            }
            .padding(3)
        }
        .navigationBarTitle((parentGroup == nil ? "Monitor status" : parentGroup?.name)!,  displayMode: .inline)
    }
}


struct GroupCardView: View {
    var group: Group
    @State private var isActive = false
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack(alignment: .leading) {
            NavigationLink(destination: ContentView(group), isActive: $isActive, label: { EmptyView() })
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
        .background{
            if colorScheme == .dark {
                Color.black
            }
        }
        .onTapGesture {
            isActive = true
        }
    }
}

struct ServiceCardView: View {
    var service: Service
    @State private var isActive = false
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                NavigationLink(destination: ServiceView(service: service), isActive: $isActive, label: { EmptyView() })
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
                        .frame(maxHeight: geometry.size.height * 0.5)
                    Spacer()
                    HStack {
                        Text(service.status?.name ?? "")
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
            .onTapGesture {
                isActive = true
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(nil).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
