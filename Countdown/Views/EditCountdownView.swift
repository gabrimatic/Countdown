import SwiftUI

struct EditCountdownView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: CountdownStore

    @State private var title: String
    @State private var date: Date
    @State private var notes: String
    @FocusState private var isTitleFocused: Bool

    private let existingItem: CountdownItem?

    init(item: CountdownItem?) {
        self._title = State(initialValue: item?.title ?? "")
        self._date = State(initialValue: item?.date ?? Calendar.current.startOfDay(for: Date().addingTimeInterval(86400)))
        self._notes = State(initialValue: item?.notes ?? "")
        self.existingItem = item
    }

    var body: some View {
        Form {
            Section("Details") {
                TextField("Title", text: $title)
                    .focused($isTitleFocused)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.words)
                DatePicker("Date", selection: $date, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                    .textInputAutocapitalization(.sentences)
            }

            if let existingItem {
                Section {
                    Button(role: .destructive) {
                        store.delete(existingItem)
                        dismiss()
                    } label: {
                        Label("Delete Countdown", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle(existingItem == nil ? "New Countdown" : "Edit Countdown")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear {
            if existingItem == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTitleFocused = true
                }
            }
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedDate = Calendar.current.startOfDay(for: date)
        let item = CountdownItem(id: existingItem?.id ?? UUID(), title: trimmedTitle, date: normalizedDate, notes: notes.trimmingCharacters(in: .whitespacesAndNewlines))
        if existingItem == nil {
            store.add(item)
        } else {
            store.update(item)
        }
        dismiss()
    }
}

struct EditCountdownView_Previews: PreviewProvider {
    @MainActor static var previews: some View {
        NavigationStack {
            EditCountdownView(item: CountdownItem(title: "Test", date: Date().addingTimeInterval(86400 * 4)))
                .environmentObject(.preview)
        }
    }
}
