//
//  ResistanceSetView.swift
//  Golympians
//
//  Created by Bernard Scott on 7/16/25.
//

import SwiftUI

struct ResistanceSetView: View {
    let set: DBResistanceSet
    let onCommit: (DBActivitySet) -> Void

    @State private var weight: Double
    @State private var reps: Int
    @FocusState private var focusedField: Bool

    init(set: DBResistanceSet, onCommit: @escaping (DBActivitySet) -> Void) {
        self.set = set
        self.onCommit = onCommit
        _weight = State(initialValue: set.weight)
        _reps = State(initialValue: set.repetitions)
    }

    var body: some View {
        HStack {
            
            Image(systemName: "scalemass.fill")
            TextField("Weight", value: $weight, format: .number)
                .focused($focusedField)
                .keyboardType(.decimalPad)
                .onSubmit(commit)
            
            Image(systemName: "checkmark.arrow.trianglehead.counterclockwise")
            TextField("Reps", value: $reps, format: .number)
                .focused($focusedField)
                .keyboardType(.numberPad)
                .onSubmit(commit)
        }
        .onDisappear(perform: commit)
        .onChange(of: focusedField) {
            if focusedField == false {
                commit()
            }
        }
    }

    private func commit() {
        onCommit(
            .resistance(
                DBResistanceSet(
                    id: set.id,
                    setIndex: set.setIndex,
                    weight: weight,
                    repetitions: reps
                )
            )
        )
    }
}

#Preview {
    @Previewable @State var weight: Double = 11.5
    @Previewable @State var repetitions: Int = 5
    List {
        ResistanceSetView(set: DBResistanceSet(id: "1234", setIndex: 0, weight: weight, repetitions: repetitions), onCommit: {_ in })
    }
}
