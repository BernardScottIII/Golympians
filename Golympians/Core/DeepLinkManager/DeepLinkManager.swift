//
//  DeepLinkManager.swift
//  Golympians
//
//  Created by Bernard Scott on 1/21/26.
//

import Foundation

class DeepLinkManager: ObservableObject {
    @Published var navigatedToProfile: Profile?
    @Published var selectedTab: TabbarTab = .workouts

    init(navigatedToProfile: Profile? = nil) {
        self.navigatedToProfile = navigatedToProfile
    }

    func handle(url: URL) {
        // Example parsing logic
        if url.pathComponents.contains("profile"), let lastComponent = url.pathComponents.last, lastComponent != "profile" {
            Task {
                let profile = try await ProfileManager.shared.getProfile(username: lastComponent)
                await MainActor.run {
                    self.selectedTab = .explore
                    self.navigatedToProfile = profile
                }
            }
        }
    }
}
