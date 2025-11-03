import SwiftUI

struct CountdownListView: View {
    @EnvironmentObject private var store: CountdownStore
    @EnvironmentObject private var settingsStore: AppSettingsStore
    @State private var selectedItem: CountdownItem?
    @State private var isPresentingEditor = false
    @State private var isPresentingSettings = false

    var body: some View {
        NavigationStack {
            Group {
                if store.countdowns.isEmpty {
                    EmptyStateView()
                } else {
                    cardLayoutView
                }
            }
            .navigationTitle(NSLocalizedString("nav.countdowns", comment: "Navigation title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isPresentingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                            .labelStyle(.iconOnly)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedItem = nil
                        isPresentingEditor = true
                    } label: {
                        Label(NSLocalizedString("countdown.list.add", comment: "Add countdown"), systemImage: "plus")
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
            .sheet(isPresented: $isPresentingSettings) {
                SettingsView()
                    .environmentObject(settingsStore)
                    .preferredColorScheme(settingsStore.effectiveColorScheme)
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
                            Label(NSLocalizedString("countdown.list.delete", comment: "Delete"), systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color("PrimaryBackground").ignoresSafeArea())
        .transition(.opacity)
    }
}

struct CountdownListView_Previews: PreviewProvider {
    @MainActor static var previews: some View {
        CountdownListView()
            .environmentObject(CountdownStore.preview)
            .environmentObject(AppSettingsStore.preview)
    }
}
