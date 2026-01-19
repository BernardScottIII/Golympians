//
//  SwimSetView.swift
//  Golympians
//
//  Created by Bernard Scott on 7/16/25.
//

import SwiftUI

struct SwimSetView: View {
    let set: DBSwimSet
    let onCommit: (DBActivitySet) -> Void

    @State private var distance: Double
    @State private var duration: Double
    @State private var laps: Int

    init(set: DBSwimSet, onCommit: @escaping (DBActivitySet) -> Void) {
        self.set = set
        self.onCommit = onCommit
        _distance = State(initialValue: set.distance)
        _duration = State(initialValue: set.duration)
        _laps = State(initialValue: set.laps)
    }
    
    var body: some View {
        HStack {
            
            Image(systemName: "point.bottomleft.forward.to.arrow.triangle.scurvepath.fill")
            TextField("distance", value: $distance, format: .number)
                .keyboardType(.decimalPad)
                .onSubmit(commit)
            
            Image(systemName: "point.forward.to.point.capsulepath",)
            TextField("laps", value: $laps, format: .number)
                .keyboardType(.numberPad)
                .onSubmit(commit)
            
            Image(systemName: "stopwatch.fill")
            TextField("duration", value: $duration, format: .number)
                .keyboardType(.decimalPad)
                .onSubmit(commit)
            
        }
    }
    
    private func commit() {
        onCommit(
            .swim(
                DBSwimSet(
                    id: set.id,
                    setIndex: set.setIndex,
                    distance: set.distance,
                    laps: set.laps,
                    duration: set.duration
                )
            )
        )
    }
}

#Preview {
    @Previewable @State var distance = 0.0
    @Previewable @State var duration = 0.0
    @Previewable @State var laps = 0
    List {
        SwimSetView(set: DBSwimSet(id: "1234", setIndex: 0, distance: distance, laps: laps, duration: duration), onCommit: {_ in})
    }
}
