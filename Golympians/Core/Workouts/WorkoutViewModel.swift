//
//  WorkoutViewModel.swift
//  Goalympians
//
//  Created by Bernard Scott on 4/3/25.
//

//import Foundation
import SwiftUI

@MainActor
final class WorkoutViewModel: ObservableObject {
    
    @Published private(set) var workouts: [DBWorkout] = []
    @Published private(set) var dateOption: DateOption? = .dateDescending
    let workoutDataService: WorkoutManagerProtocol
    
    init(
        workoutDataService: WorkoutManagerProtocol
    ) {
        self.workoutDataService = workoutDataService
    }
    
    func getAllWorkouts(descending: Bool?) async throws {
        self.workouts = try await workoutDataService.getAllWorkouts(descending: descending)
    }
    
    func binding(for workoutId: String) -> Binding<DBWorkout>? {
        guard let index = workouts.firstIndex(where: {$0.id == workoutId }) else {
            return nil
        }
        
        return Binding(
            get: {self.workouts[index]},
            set: {self.workouts[index] = $0}
        )
    }
    
    func removeWorkout(workoutId: String) async throws {
        try await workoutDataService.removeWorkout(workoutId: workoutId)
    }
    
    func createWorkout(name: String, description: String, date: Date) async throws -> DBWorkout {
        let newWorkout = try DBWorkout(
            id: UUID().uuidString,
            userId: AuthenticationManager.shared.getAuthenticatedUser().uid,
            name: name,
            description: description,
            date: date,
            isPublic: false
        )
        try await workoutDataService.createNewWorkout(workout: newWorkout)
        try await getAllWorkouts(descending: dateOption?.dateDescending)
        return newWorkout
    }
    
    func filterDateOption(option: DateOption) async throws {
        self.dateOption = option
        try await self.getAllWorkouts(descending: dateOption?.dateDescending)
    }
    
    private func replaceWorkoutInList(_ updated: DBWorkout) {
        if let index = workouts.firstIndex(where: { $0.id == updated.id }) {
            workouts[index] = updated
        }
    }

    func refreshWorkout(workoutId: String) async throws {
        let refreshed = try await workoutDataService.getWorkout(workoutId: workoutId)
        replaceWorkoutInList(refreshed)
    }
    
    func toggleWorkoutVisibility(workoutId: String) async throws {
        if let index = workouts.firstIndex(where: { $0.id == workoutId }) {
            // Optimistic local toggle
            workouts[index].isPublic.toggle()
            let updated = workouts[index]
            do {
                try await workoutDataService.updateWorkout(workout: updated)
            } catch {
                // Revert on failure
                workouts[index].isPublic.toggle()
                throw error
            }
        } else {
            // Fallback: fetch, toggle, persist, then update local list if present
            let workout = try await workoutDataService.getWorkout(workoutId: workoutId)
            var updated = workout
            updated.isPublic.toggle()
            try await workoutDataService.updateWorkout(workout: updated)
            replaceWorkoutInList(updated)
        }
    }
}
