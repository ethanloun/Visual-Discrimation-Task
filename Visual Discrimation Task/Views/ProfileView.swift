//
//  ProfileView.swift
//  Visual Discrimation Task
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var profileStore: ProfileStore
    @State private var newName: String = ""
    var onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Create or choose your profile")
                    .font(.headline)
                HStack {
                    TextField("Participant name", text: $newName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        profileStore.add(name: newName.trimmingCharacters(in: .whitespaces))
                        newName = ""
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            List(selection: Binding(get: {
                profileStore.activeProfile
            }, set: { newValue in
                if let p = newValue { profileStore.setActive(p) }
            })) {
                ForEach(profileStore.profiles) { profile in
                    HStack {
                        Text(profile.name)
                        Spacer()
                        if profileStore.activeProfile == profile {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { profileStore.setActive(profile) }
                }
            }
            .frame(maxHeight: 240)
            
            Button("Continue") { onContinue() }
                .buttonStyle(.borderedProminent)
                .disabled(profileStore.activeProfile == nil)
        }
        .padding()
    }
}

#Preview {
    ProfileView(profileStore: ProfileStore(), onContinue: {})
}


