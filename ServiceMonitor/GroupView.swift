//
//  GroupView.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 02.02.2022.
//

import SwiftUI

struct GroupView: View {
    
    @FetchRequest var groups: FetchedResults<Group>
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var group: Group
    @State var deleteIfNotSaved: Bool = false
    
    init(_ groupToEdit: Group) {
        group = groupToEdit
        let request = Group.fetchRequest(NSPredicate(format: "self != %@", groupToEdit.objectID))
        _groups = FetchRequest(fetchRequest: request, animation: .default)
    }
    
    var body: some View {
        NavigationView {
            Form {
                groupInfoSection
                saveButton.disabled(!group.hasChanges)
            }
        }
        .onAppear(perform: setDeletionIfItNewObject)
        .onDisappear(perform: deleteIfObjectNotSaved)
    }
    
    var groupInfoSection: some View {
        Section("Group info section") {
            Text("ID: \(group.monitorId)")
            VStack(alignment: .leading) {
                Text("Name").font(.footnote)
                TextField("Name", text: $group.name)
            }
            Picker("Group", selection: $group.group) {
                Text("None").tag(Group?.none)
                ForEach(groups, id: \.self) { (groupToSelect: Group?) in
                    Text("\(groupToSelect?.name ?? "Empty")").tag(groupToSelect)
                }
            }
        }
    }
    
    var saveButton: some View {
        Button("Save") {
            deleteIfNotSaved = false
            try! viewContext.save()
        }
    }
    
    private func deleteIfObjectNotSaved() {
        if deleteIfNotSaved {
            viewContext.delete(group)
        }
    }
    
    private func setDeletionIfItNewObject() {
        if group.isInserted {
            deleteIfNotSaved = true
            try! viewContext.save()
        }
    }
}

struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let group = Group.instance(id: 1, context: context)
        GroupView(group!).environment(\.managedObjectContext, context)
    }
}
