//
//  ContentView.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 16.01.2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
        predicate: NSPredicate(format: "group == nil"),
        animation: .default)
    private var items: FetchedResults<MonitorObject>

    var body: some View {
        NavigationView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                ForEach(items) { item in
                    if item.entity.name == "Group" {
                        GroupCardView(group: item as! Group)
                        
                    } else {
                        
                    }

                }
//                .onDelete(perform: deleteItems)
            }
            .padding()
        }
        
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}


struct GroupCardView: View {
    var group: Group
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .aspectRatio(3/2, contentMode: .fit)
                .foregroundColor(Color(customColorId: group.colorId))
            
            VStack(alignment: .leading){
                Text(group.name ?? "")
                    .bold()
//                    .padding()
                Spacer()
                Text("\(group.numberOfServicesOk)/\(group.services.count)")
                Text("ID:\(Int(group.monitorId))")
//                    .padding()
            }.padding()
        }
    }
}

struct ServiceCardView: View {
    var service: Service
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(Color.customGreen)
        
        VStack {
            
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
