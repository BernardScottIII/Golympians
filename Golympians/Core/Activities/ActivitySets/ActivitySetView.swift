//
//  ActivitySetView.swift
//  Golympians
//
//  Created by Bernard Scott on 1/2/26.
//

import SwiftUI

struct ActivitySetView: View {
    let set: DBActivitySet
    let onCommit: (DBActivitySet) -> Void
    let onDelete: (DBActivitySet) -> Void

    var body: some View {
        HStack {
            switch set {
            case .resistance(let s):
                ResistanceSetView(set: s, onCommit: onCommit)

            case .run(let s):
                RunSetView(set: s, onCommit: onCommit)

            case .swim(let s):
                SwimSetView(set: s, onCommit: onCommit)
            }

            Button("", systemImage: "trash") {
                onDelete(set)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ActivitySetView(set: .resistance(DBResistanceSet(id: "1234", setIndex: 0, weight: 0.0, repetitions: 0)), onCommit: {_ in}, onDelete: {_ in})
}
