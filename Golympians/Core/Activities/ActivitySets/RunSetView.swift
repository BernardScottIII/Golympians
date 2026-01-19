//
//  RunSetView.swift
//  Golympians
//
//  Created by Bernard Scott on 7/16/25.
//

import SwiftUI

struct RunSetView: View {
    let set: DBRunSet
    let onCommit: (DBActivitySet) -> Void

    @State private var distance: Double
    @State private var duration: Double
    @State private var elevation: Double
    @FocusState private var focusedField: Bool

    init(set: DBRunSet, onCommit: @escaping (DBActivitySet) -> Void) {
        self.set = set
        self.onCommit = onCommit
        _distance = State(initialValue: set.distance)
        _duration = State(initialValue: set.duration)
        _elevation = State(initialValue: set.elevation)
    }
    
    var body: some View {
        HStack {
            
            Image(systemName: "point.bottomleft.forward.to.arrow.triangle.scurvepath.fill")
            TextField("distance", value: $distance, format: .number)
                .focused($focusedField)
                .keyboardType(.decimalPad)
                .onSubmit(commit)
            
            Image(systemName: "barometer",)
            TextField("elevation", value: $elevation, format: .number)
                .focused($focusedField)
                .keyboardType(.decimalPad)
                .onSubmit(commit)
            
            Image(systemName: "stopwatch.fill")
            TextField("duration", value: $duration, format: .number)
                .focused($focusedField)
                .keyboardType(.decimalPad)
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
            .run(
                DBRunSet(
                    id: set.id,
                    setIndex: set.setIndex,
                    distance: set.distance,
                    elevation: set.elevation,
                    duration: set.duration
                )
            )
        )
    }
}

#Preview {
    @Previewable @State var distance = 0.0
    @Previewable @State var duration = 0.0
    @Previewable @State var elevation = 0.0
    List {
        RunSetView(set: DBRunSet(id: "1234", setIndex: 0, distance: distance, elevation: elevation, duration: duration), onCommit: {_ in})
    }
}
