//
//  ContentView.swift
//  Visual Discrimation Task
//
//  Created by Ethan on 9/18/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var profileStore = ProfileStore()
    @State private var showExperiment = false
    
    var body: some View {
        if showExperiment || profileStore.activeProfile != nil {
            ExperimentView()
        } else {
            ProfileView(profileStore: profileStore) {
                showExperiment = true
            }
        }
    }
}

#Preview {
    ContentView()
}
