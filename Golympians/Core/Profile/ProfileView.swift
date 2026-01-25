//
//  ProfileView.swift
//  Golympians
//
//  Created by Bernard Scott on 7/24/25.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    
    @State private var followerCount: Int
    @State private var followingCount: Int
    
//    private let shareURL = URL(string:"https://github.com/BernardScottIII/Golympians")!
    
    let profile: Profile
    
    init(
        profile: Profile
    ) {
        self.profile = profile
        followerCount = profile.followers.count
        followingCount = profile.following.count
    }
    
    var body: some View {
        VStack {
            
            ProfileHeaderView(followerCount: $followerCount, followingCount: $followingCount, profile: profile)
            
            HStack {
                Spacer()
                // There's certainly a better way to implement this, but I'm
                // garbage at coding.
                if viewModel.isFollowing ?? false == true {
                    Button {
                        viewModel.removeFollower(profile, notFollowedBy: viewModel.myProfile)
                    } label: {
                        Text("Unfollow")
                    }
                    .padding([.leading, .trailing], 32)
                    .padding([.top, .bottom], 4)
                    .background(Color.gray.opacity(0.4))
                    .clipShape(.buttonBorder)
                } else {
                    Button {
                        viewModel.addFollower(profile, followedBy: viewModel.myProfile)
                    } label: {
                        Text("Follow")
                    }
                    .padding([.leading, .trailing], 32)
                    .padding([.top, .bottom], 4)
                    .background(Color.gray.opacity(0.4))
                    .clipShape(.buttonBorder)
                }
                
                Spacer()
                
                if let shareURL = URL(string:"https://golympians.github.io/profile/\(profile.username)") {
                    ShareLink(item: shareURL, message: Text("Check out \(profile.username)'s Golympians profile!")) {
                        Text("Share")
                    }
                    .padding([.leading, .trailing], 32)
                    .padding([.top, .bottom], 4)
                    .background(Color.gray.opacity(0.4))
                    .clipShape(.buttonBorder)
                }
                
                Spacer()
            }
            Spacer()
        }
        .padding()
        .onAppear {
            Task {
                try await viewModel.loadMyProfile()
                viewModel.checkIsFollowing(for: profile)
            }
        }
        .onChange(of: viewModel.isFollowing) { oldValue, newValue in
            Task {
                followerCount = try await viewModel.getFollowerCount(for: profile.username)
                followingCount = try await viewModel.getFollowingCount(for: profile.username)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(profile: Profile(username: "TheUser", nickname: "Buddy", followers: ["Nard"], following: ["5", "asd"], photoURL: "", photoPath: ""))
    }
}
