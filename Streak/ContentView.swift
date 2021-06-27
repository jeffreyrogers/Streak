//
//  ContentView.swift
//  Streak
//
//  Created by Jeffrey Rogers on 6/20/21.
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

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State private var showModal = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(items) { item in
                        HStack {
                            Text("\(item.title!)")
                            Spacer()
                            Text("\(item.streak)")
                        }
                        // TODO: when iOS 15 available, change this to a swipe action
                        .contentShape(Rectangle())
                        .onTapGesture(count: 2) {
                            incrementStreak(streak: item)
                        }
                        .onAppear(perform: {
                            updateStreak(streak: item)
                        })
                    }
                    .onDelete(perform: deleteItems)
                }
                Text("Double-tap to increment streak")
                Text("Swipe-left to delete a streak")
            }
            .navigationTitle("Streak")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button(action: { showModal = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }.sheet(isPresented: $showModal) {
                ModalView(showModal: $showModal)
            }
        }
    }

    private func incrementStreak(streak: Item) {
        var components = DateComponents()
        components.hour = 0
        components.minute = 0
        let today = Calendar.current.date(from: components) ?? Date()
        let yesterday = today.addingTimeInterval(-86400)

        if (streak.timestamp! < today && streak.timestamp! > yesterday) || (streak.streak == 0) {
            viewContext.performAndWait {
                streak.streak += 1
                streak.timestamp = Date()
                try? viewContext.save()
            }
        }
    }
    
    private func updateStreak(streak: Item) {
        var components = DateComponents()
        components.hour = 0
        components.minute = 0
        let today = Calendar.current.date(from: components) ?? Date()
        let yesterday = today.addingTimeInterval(-86400)
        
        if streak.timestamp! < yesterday {
            streak.streak = 0
            streak.timestamp = Date()
            viewContext.performAndWait {
                try? viewContext.save()
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
