import SwiftUI

struct CountdownListView: View {
    @EnvironmentObject private var store: CountdownStore
    @State private var selectedItem: CountdownItem?
    @State private var isPresentingEditor = false
    @State private var useCardLayout = true // Toggle between list and card layout

    var body: some View {
        NavigationStack {
            Group {
                if store.countdowns.isEmpty {
                    EmptyStateView()
                } else {
                    if useCardLayout {
                        cardLayoutView
                    } else {
                        listLayoutView
                    }
                }
            }
            .navigationTitle("Countdowns")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.easeInOut) {
                            useCardLayout.toggle()
                        }
                    } label: {
                        Label(
                            useCardLayout ? "List View" : "Card View",
                            systemImage: useCardLayout ? "list.bullet" : "square.grid.2x2"
                        )
                        .labelStyle(.iconOnly)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedItem = nil
                        isPresentingEditor = true
                    } label: {
                        Label("Add", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            .sheet(isPresented: $isPresentingEditor) {
                NavigationStack {
                    EditCountdownView(item: selectedItem)
                        .environmentObject(store)
                }
            }
        }
    }

    @ViewBuilder
    private var cardLayoutView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.countdowns) { item in
                    Button {
                        selectedItem = item
                        isPresentingEditor = true
                    } label: {
                        CountdownCard(item: item)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            withAnimation {
                                store.delete(item)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .transition(.opacity)
    }

    @ViewBuilder
    private var listLayoutView: some View {
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
        .transition(.opacity)
    }
}

struct CountdownListView_Previews: PreviewProvider {
    @MainActor static var previews: some View {
        CountdownListView()
            .environmentObject(CountdownStore.preview)
    }
}
