//
//  ContentView.swift
//  AppDataTest
//
//  Created by Bernard Scott on 3/3/25.
//

import SwiftUI
import FirebaseFirestore

struct TabbarView: View {
    enum TabbarTab: Hashable {
        case workouts, insights, profile, explore
    }
    
    @State private var selectedTab: TabbarTab = .workouts
    
    @State private var workoutNavigationPath = NavigationPath()
    @State private var insightNavigationPath = NavigationPath()
    @State private var profileNavigationPath = NavigationPath()
    @State private var exploreNavigationPath = NavigationPath()
    
    @Binding var showSignInView: Bool
    @Binding var profileIncomplete: Bool
    let workoutDataService: WorkoutManagerProtocol
    
    init(
        workoutDataService: WorkoutManagerProtocol,
        showSignInView: Binding<Bool>,
        profileIncomplete: Binding<Bool>
    ) {
        _showSignInView = showSignInView
        _profileIncomplete = profileIncomplete
        self.workoutDataService = workoutDataService
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Workouts", systemImage: "dumbbell", value: .workouts) {
                NavigationStack(path: $workoutNavigationPath) {
//                    WorkoutsView(workoutDataService: workoutDataService)
                    UserWorkoutsView(workoutDataService: workoutDataService, path: $workoutNavigationPath)
                }
            }
            
            Tab("Insights", systemImage: "chart.xyaxis.line", value: .insights) {
                NavigationStack(path: $insightNavigationPath) {
                    InsightsView(showSignInView: $showSignInView)
                }
            }
            
            Tab("Explore", systemImage: "magnifyingglass", value: .explore) {
                NavigationStack(path: $exploreNavigationPath) {
                    ExploreView()
                }
            }
            
            Tab("Profile", systemImage: "person", value: .profile) {
                NavigationStack(path: $profileNavigationPath) {
                    UserAccountView(showSignInView: $showSignInView, profileIncomplete: $profileIncomplete, workoutDataService: workoutDataService)
                }
            }
        }
        .onChange(of: selectedTab) {
            if selectedTab == .workouts { workoutNavigationPath = NavigationPath() }
            if selectedTab == .insights { insightNavigationPath = NavigationPath() }
            if selectedTab == .profile { profileNavigationPath = NavigationPath() }
            if selectedTab == .explore { exploreNavigationPath = NavigationPath() }
        }
    }
}

#Preview {
    TabbarView(
        workoutDataService: ProdWorkoutManager(workoutCollection: Firestore.firestore().collection("workouts")),
        showSignInView: .constant(false), profileIncomplete: .constant(false)
    )
}
