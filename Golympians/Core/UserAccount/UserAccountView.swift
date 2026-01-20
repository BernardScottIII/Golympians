//
//  ProfileView.swift
//  Goalympians
//
//  Created by Bernard Scott on 3/30/25.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore

struct UserAccountView: View {
    @StateObject private var viewModel = UserAccountViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var userId: String = ""
//    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State var profile: Profile? = nil
    @State private var followerCount: Int = 0
    @State private var followingCount: Int = 0
    
    @Binding var showSignInView: Bool
    @Binding var profileIncomplete: Bool
    let workoutDataService: WorkoutManagerProtocol
    
    var body: some View {
        if let profile = profileViewModel.myProfile {
            ProfileHeaderView(
                followerCount: $followerCount,
                followingCount: $followingCount,
                profile: profile
            )
            .padding()
        }
        
        List {
            Section("Personal Content") {
                NavigationLink("My Exercises") {
                    UserExerciseListView(
                        viewModel: ExercisesViewModel(dataService: workoutDataService),
                        userId: userId,
                        workoutDataService: workoutDataService
                    )
                }
            }
        }
        .scrollDisabled(true)
        .task {
            try? await viewModel.loadCurrentUser()
            do {
                try await profileViewModel.loadMyProfile()
            } catch {
                profileIncomplete = true
            }
            if let profile = profileViewModel.myProfile {
                followerCount = profile.followers.count
                followingCount = profile.following.count
            }
        }
        .onAppear {
            Task {
                userId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            }
        }
        .onChange(of: showSignInView, { oldValue, newValue in
            Task {
                try? await viewModel.loadCurrentUser()
                userId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            }
        })
        .onChange(of: profileIncomplete) {
            if profileIncomplete == false {
                Task {
                    try await profileViewModel.loadMyProfile()
                    if let profile = profileViewModel.myProfile {
                        followerCount = profile.followers.count
                        followingCount = profile.following.count
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView(showSignInView: $showSignInView, workoutDataService: workoutDataService)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    EditProfileView(profileViewModel: profileViewModel, userAccountViewModel: viewModel)
                } label: {
                    Text("Edit Profile")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        UserAccountView(
            showSignInView: .constant(false),
            profileIncomplete: .constant(false),
            workoutDataService: ProdWorkoutManager(workoutCollection: Firestore.firestore().collection("workouts"))
        )
    }
}
