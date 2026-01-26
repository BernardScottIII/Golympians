//
//  WorkoutManager.swift
//  Goalympians
//
//  Created by Bernard Scott on 4/3/25.
//

// Problems with Singletons
// 1. Singletons are global, which will lead to clutter and confusion. Gets even worse in a multi-threaded env.
// 2. Unable to customize the init() because the singleton is initialized at write-time, as opposed to ideally at runtime
// 3. Unable to switch service providers, meaning I can't test my code!

import Foundation
import FirebaseFirestore

struct DBWorkoutArray: Codable {
    let workouts: [DBWorkout]
    let total, skip, limit: Int
}

struct DBWorkout: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    var name: String
    var description: String
    var date: Date
    var isPublic: Bool
}

final class ProdWorkoutManager: WorkoutManagerProtocol {
    
    private var workoutCollection: CollectionReference //= Firestore.firestore().collection("workouts")
    
    init(workoutCollection: CollectionReference) {
        self.workoutCollection = workoutCollection
    }
    
    private func workoutDocument(workoutId: String) -> DocumentReference {
        workoutCollection.document(workoutId)
    }
    
    func createNewWorkout(workout: DBWorkout) async throws {
        try workoutDocument(workoutId: workout.id).setData(from: workout, merge: false)
    }
    
    func getWorkout(workoutId: String) async throws -> DBWorkout {
        try await workoutDocument(workoutId: workoutId).getDocument(as: DBWorkout.self)
    }
    
    func getAllWorkouts(descending: Bool?) async throws -> [DBWorkout] {
        var result: Query = try workoutCollection
            .whereField("userId", isEqualTo: AuthenticationManager.shared.getAuthenticatedUser().uid)
        
        if let descending = descending {
            result = result.order(by: "date", descending: descending)
        }
        
        return try await result.getDocuments(as: DBWorkout.self)
    }
    
    func updateWorkout(workout: DBWorkout) async throws {
        try workoutDocument(workoutId: workout.id).setData(from: workout, merge: true)
    }
    
    func removeWorkout(workoutId: String) async throws {
        let activities = try await getAllWorkoutActivities(workoutId: workoutId)
        for activity in activities {
            try await removeWorkoutActivity(workoutId: workoutId, activityId: activity.id)
        }
        
        try await workoutDocument(workoutId: workoutId).delete()
    }
    
//    func toggleWorkoutVisibility(workout: DBWorkout) async throws {
//        try workoutDocument(workoutId: workout.id).setData(from: workout, merge: true)
//    }
}

// MARK: Workout Activity
extension ProdWorkoutManager {
    
    private func workoutActivityDocument(workoutId: String, activityId: String) -> DocumentReference {
        workoutActivityCollection(workoutId: workoutId).document(activityId)
    }
    
    private func workoutActivityCollection(workoutId: String) -> CollectionReference {
        workoutDocument(workoutId: workoutId).collection("activities")
    }
    
    func addWorkoutActivity(workoutId: String, exercise: APIExercise) async throws {
        let document = workoutActivityCollection(workoutId: workoutId).document()
        let documentId = document.documentID
        let exerciseCount = try await workoutActivityCollection(workoutId: workoutId).count.getAggregation(source: .server).count.intValue
        
        let initialSet: DBActivitySet
        switch exercise.setType {
        case .resistance:
            initialSet = .resistance(DBResistanceSet(id: UUID().uuidString, setIndex: 0, weight: 0.0 ,repetitions: 0))
        case .run:
            initialSet = .run(DBRunSet(id: UUID().uuidString, setIndex: 0, distance: 0.0, elevation: 0.0, duration: 0.0))
        case .swim:
            initialSet = .swim(DBSwimSet(id: UUID().uuidString, setIndex: 0, distance: 0.0, laps: 0, duration: 0.0))
        }
        
        let activity = DBActivity(
            id: documentId,
            exerciseId: exercise.id!,
            setType: exercise.setType,
            workoutIndex: exerciseCount,
            activitySets: [initialSet]
        )
        
        try document.setData(from: activity, merge: false)
    }
    
    func removeWorkoutActivity(workoutId: String, activityId: String) async throws {
        try await workoutActivityDocument(workoutId: workoutId, activityId: activityId).delete()
    }
    
    func getAllWorkoutActivities(workoutId: String) async throws -> [DBActivity] {
        try await workoutActivityCollection(workoutId: workoutId)
            .order(by: DBActivity.CodingKeys.workoutIndex.rawValue)
            .getDocuments(as: DBActivity.self)
    }
    
    func updateWorkoutActivity(workoutId: String, activity: DBActivity) async throws {
        try workoutActivityDocument(workoutId: workoutId, activityId: activity.id).setData(from: activity, merge: true)
    }
    
    func getWorkoutActivity(workoutId: String, activityId: String) async throws -> DBActivity {
        try await workoutActivityDocument(workoutId: workoutId, activityId: activityId).getDocument(as: DBActivity.self)
    }
    
    func addEmptyActivitySet(workoutId: String, activity: DBActivity) async throws {
        let setIndex = activity.activitySets.count
        var newSet: DBActivitySet
            
        switch activity.setType {
        case .resistance: newSet = .resistance(DBResistanceSet(id: UUID().uuidString, setIndex: setIndex, weight: 0.0, repetitions: 0))
        case .run: newSet = .run(DBRunSet(id: UUID().uuidString, setIndex: setIndex, distance: 0.0, elevation: 0.0, duration: 0.0))
        case .swim: newSet = .swim(DBSwimSet(id: UUID().uuidString, setIndex: setIndex, distance: 0.0, laps: 0, duration: 0.0))
        }
            
        try await addActivitySet(workoutId: workoutId, activityId: activity.id, set: newSet)
    }
    
    func addActivitySet(workoutId: String, activityId: String, set: DBActivitySet) async throws {
        var activity = try await getWorkoutActivity(workoutId: workoutId, activityId: activityId)
        activity.activitySets.append(set)
        try await updateWorkoutActivity(workoutId: workoutId, activity: activity)
    }
    
    func removeActivitySet(workoutId: String, activityId: String, set: DBActivitySet) async throws {
        let data: [String:Any] = [
            DBActivity.CodingKeys.activitySets.rawValue : FieldValue.arrayRemove([set])
        ]
        
        try await workoutActivityDocument(workoutId: workoutId, activityId: activityId).updateData(data)
    }
}
