//
//  SharedWorkoutsView.swift
//  Golympian
//
//  Created by Bernard Scott on 6/19/25.
//

import SwiftUI

struct SharedWorkoutsView: View {
    private let sharedWorkouts:[DBWorkout] = [
        .init(id: UUID().uuidString, userId: UUID().uuidString, name: "Example 1", description: "Description 1", date: .now, isPublic: false),
        .init(id: UUID().uuidString, userId: UUID().uuidString, name: "Example 2", description: "Description 2", date: .now, isPublic: false),
        .init(id: UUID().uuidString, userId: UUID().uuidString, name: "Example 3", description: "Description 3", date: .now, isPublic: false),
        .init(id: UUID().uuidString, userId: UUID().uuidString, name: "Example 4", description: "Description 4", date: .now, isPublic: false),
        .init(id: UUID().uuidString, userId: UUID().uuidString, name: "Example 5", description: "Description 5", date: .now, isPublic: false),
        .init(id: UUID().uuidString, userId: UUID().uuidString, name: "Example 6", description: "Description 6", date: .now, isPublic: false),
    ]
    
    var body: some View {
        List {
            ForEach(sharedWorkouts, id: \.id) { workout in
                NavigationLink {
                    Text(workout.name)
                    Text(workout.description)
                } label: {
                    Text(workout.name)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SharedWorkoutsView()
    }
}
