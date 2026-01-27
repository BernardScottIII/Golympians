//
//  WorkoutView.swift
//  AppDataTest
//
//  Created by Bernard Scott on 3/4/25.
//

import SwiftUI
import FirebaseFirestore

struct EditWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var activityViewModel: ActivityViewModel
    @State private var userId: String = ""
    @State private var scrollTargetActivity: Int? = nil
    @State private var keyboardOnScreen: Bool = false
    
    @Binding var workout: DBWorkout
    var workoutDataService: WorkoutManagerProtocol
    
    init(
        workout: Binding<DBWorkout>,
        workoutDataService: WorkoutManagerProtocol
    ) {
        self._workout = workout
        _activityViewModel = StateObject(wrappedValue: ActivityViewModel(dataService: workoutDataService))
        self.workoutDataService = workoutDataService
    }
    
    var body: some View {
        VStack{
            ScrollViewReader { value in
                Form {
                    TextField("name", text: $workout.name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("desc", text: $workout.description, axis: .vertical)
                        .textInputAutocapitalization(.sentences)
                    
                    DatePicker("date", selection: $workout.date)
                    
                    ActivityView(
                        viewModel: activityViewModel,
                        userId: $userId,
                        scrollTargetActivity: $scrollTargetActivity,
                        workoutDataService: workoutDataService,
                        workoutId: workout.id
                    )
                }
                .onAppear {
                    if scrollTargetActivity != nil {
                        withAnimation {
                            value.scrollTo(scrollTargetActivity, anchor: .top)
                        }
                        
                        scrollTargetActivity = nil
                    }
                }
            }
        }
        .navigationTitle("Edit Workout")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .scrollDismissesKeyboard(.immediately)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    WorkoutActivityOrderView(activityViewModel: activityViewModel, workoutId: workout.id)
                } label: {
                    Image(systemName: "arrow.up.and.line.horizontal.and.arrow.down")
                }
            }
            ToolbarItem(placement: .topBarTrailing){
                NavigationLink {
                    ExercisesView(
                        activityViewModel: activityViewModel,
                        workoutDataService: workoutDataService,
                        workoutId: workout.id,
                        userIds: [userId, "global"],
                        scrollTargetActivity: $scrollTargetActivity
                    )
                    .onDisappear {
                        activityViewModel.getAllActivities(workoutId: workout.id)
                    }
                } label: {
                    Image("custom.dumbbell.badge.plus")
                    
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Save", action: saveWorkout)
            }
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            Task {
                self.userId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            keyboardOnScreen = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardOnScreen = false
        }
    }
    
    private func saveWorkout() {
        Task {
            try await workoutDataService.updateWorkout(workout: DBWorkout(id: workout.id, userId: workout.userId, name: workout.name, description: workout.description, date: workout.date))
            /// I think this is fine because it's not forcing the main thread to wait, and instead will be called when
            /// the WorkoutManager is finished updating the workout
            dismiss()
        }
    }
}

#Preview {
    @Previewable @State var workout = DBWorkout(id: UUID().uuidString, userId: UUID().uuidString, name: "Sample", description: "Example", date: .now)
    NavigationStack {
        EditWorkoutView(workout: $workout, workoutDataService: ProdWorkoutManager(workoutCollection: Firestore.firestore().collection("workouts")))
    }
}
