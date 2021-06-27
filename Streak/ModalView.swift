//
//  ModalView.swift
//  Streak
//
//  Created by Jeffrey Rogers on 6/27/21.
//

import SwiftUI
import CoreData

struct ModalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var showModal: Bool
    @State private var title = ""
    
    var body: some View {
        Form {
            Section(header: Text("Add Activity")) {
                TextField("Activity Name", text: $title)
                HStack {
                    Spacer()
                    Button("Save") {
                        showModal = false
                        addItem(title: title)
                    }
                }
            }
        }.textFieldStyle(RoundedBorderTextFieldStyle())
    }

    private func addItem(title: String) {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.streak = 0
            newItem.title = title

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
