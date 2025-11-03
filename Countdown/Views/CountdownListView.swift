import SwiftUI

struct CountdownListView: View {
    @EnvironmentObject private var store: CountdownStore
    @State private var selectedItem: CountdownItem?
    @State private var isPresentingEditor = false

    var body: some View {
        NavigationStack {
            Group {
                if store.countdowns.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(store.countdowns) { item in
                            Button {
                                selectedItem = item
                                isPresentingEditor = true
                            } label: {
                                CountdownRowView(item: item)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    store.delete(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete(perform: store.delete)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Countdowns")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedItem = nil
                        isPresentingEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingEditor) {
                NavigationStack {
                    EditCountdownView(item: selectedItem)
                        .environmentObject(store)
                }
            }
            .animation(.easeInOut, value: store.countdowns)
        }
    }
}

struct CountdownListView_Previews: PreviewProvider {
    @MainActor static var previews: some View {
        CountdownListView()
            .environmentObject(.preview)
    }
}
