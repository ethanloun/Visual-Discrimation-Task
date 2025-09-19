//
//  ExperimentModels.swift
//  Visual Discrimation Task
//
//  Created by Ethan on 9/18/25.
//

import Foundation
import SwiftUI

// MARK: - Experiment Configuration
struct ExperimentConfig {
    let participantID: String
    let sessionID: String
    let totalTrials: Int
    let rotationAngles: [Double] // in degrees
    let figureTypes: [FigureType]
    let presentationDuration: TimeInterval // in seconds
    let responseTimeout: TimeInterval // in seconds
    let breakInterval: Int // trials between breaks
    
    static let defaultConfig = ExperimentConfig(
        participantID: "P001",
        sessionID: UUID().uuidString,
        totalTrials: 120,
        rotationAngles: [0, 15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 180],
        figureTypes: [.simple, .complex],
        presentationDuration: 2.0,
        responseTimeout: 5.0,
        breakInterval: 30
    )
}

// MARK: - Participant Profile
struct ParticipantProfile: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.createdAt = Date()
    }
}

class ProfileStore: ObservableObject {
    @Published var profiles: [ParticipantProfile] = []
    @Published var activeProfile: ParticipantProfile?
    
    private let storageKey = "vdt_profiles"
    
    init() {
        load()
    }
    
    func add(name: String) {
        let profile = ParticipantProfile(name: name)
        profiles.append(profile)
        activeProfile = profile
        save()
    }
    
    func setActive(_ profile: ParticipantProfile) {
        activeProfile = profile
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
        if let active = activeProfile, let data = try? JSONEncoder().encode(active) {
            UserDefaults.standard.set(data, forKey: storageKey + "_active")
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ParticipantProfile].self, from: data) {
            profiles = decoded
        }
        if let data = UserDefaults.standard.data(forKey: storageKey + "_active"),
           let decoded = try? JSONDecoder().decode(ParticipantProfile.self, from: data) {
            activeProfile = decoded
        }
    }
}

// MARK: - Figure Types
enum FigureType: String, CaseIterable, Codable {
    case simple = "Simple"
    case complex = "Complex"
    
    var complexity: Int {
        switch self {
        case .simple: return 1
        case .complex: return 2
        }
    }
}

// MARK: - Trial Data
struct TrialData: Identifiable, Codable {
    let id = UUID()
    let trialNumber: Int
    let figureType: FigureType
    let rotationAngle: Double
    let presentationTime: Date
    var responseTime: Date?
    var response: String?
    var isCorrect: Bool?
    var reactionTime: TimeInterval?
    let blockNumber: Int
    
    init(trialNumber: Int, figureType: FigureType, rotationAngle: Double, presentationTime: Date, blockNumber: Int) {
        self.trialNumber = trialNumber
        self.figureType = figureType
        self.rotationAngle = rotationAngle
        self.presentationTime = presentationTime
        self.responseTime = nil
        self.response = nil
        self.isCorrect = nil
        self.reactionTime = nil
        self.blockNumber = blockNumber
    }
}

// MARK: - Experiment Session
class ExperimentSession: ObservableObject {
    @Published var config: ExperimentConfig
    @Published var trials: [TrialData] = []
    @Published var currentTrial: TrialData?
    @Published var currentTrialIndex: Int = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var sessionStartTime: Date?
    @Published var sessionEndTime: Date?
    
    // Statistics
    @Published var accuracy: Double = 0.0
    @Published var averageReactionTime: TimeInterval = 0.0
    @Published var trialsCompleted: Int = 0
    
    init(config: ExperimentConfig = ExperimentConfig.defaultConfig) {
        self.config = config
        generateTrials()
    }
    
    func generateTrials() {
        trials = []
        var trialNumber = 1
        let blockNumber = 1
        
        // Generate trials with balanced design
        for figureType in config.figureTypes {
            for rotationAngle in config.rotationAngles {
                for _ in 0..<(config.totalTrials / (config.figureTypes.count * config.rotationAngles.count)) {
                    let trial = TrialData(
                        trialNumber: trialNumber,
                        figureType: figureType,
                        rotationAngle: rotationAngle,
                        presentationTime: Date(),
                        blockNumber: blockNumber
                    )
                    trials.append(trial)
                    trialNumber += 1
                }
            }
        }
        
        // Shuffle trials for randomization
        trials.shuffle()
    }
    
    func startSession() {
        isRunning = true
        isPaused = false
        sessionStartTime = Date()
        currentTrialIndex = 0
        if !trials.isEmpty {
            currentTrial = trials[currentTrialIndex]
        }
    }
    
    func pauseSession() {
        isPaused = true
    }
    
    func resumeSession() {
        isPaused = false
    }
    
    func endSession() {
        isRunning = false
        sessionEndTime = Date()
        calculateStatistics()
    }
    
    func nextTrial() {
        if currentTrialIndex < trials.count - 1 {
            currentTrialIndex += 1
            currentTrial = trials[currentTrialIndex]
        } else {
            endSession()
        }
    }
    
    func recordResponse(response: String, responseTime: Date) {
        guard let trial = currentTrial else { return }
        
        let reactionTime = responseTime.timeIntervalSince(trial.presentationTime)
        let isCorrect = determineCorrectness(figureType: trial.figureType, rotationAngle: trial.rotationAngle, response: response)
        
        // Update the trial with response data
        var updatedTrial = trial
        updatedTrial.responseTime = responseTime
        updatedTrial.response = response
        updatedTrial.isCorrect = isCorrect
        updatedTrial.reactionTime = reactionTime
        
        trials[currentTrialIndex] = updatedTrial
        currentTrial = updatedTrial
        trialsCompleted += 1
    }
    
    private func determineCorrectness(figureType: FigureType, rotationAngle: Double, response: String) -> Bool {
        // Simple rule: correct if response matches figure type
        return response.lowercased() == figureType.rawValue.lowercased()
    }
    
    private func calculateStatistics() {
        let completedTrials = trials.filter { $0.isCorrect != nil }
        guard !completedTrials.isEmpty else { return }
        
        // Calculate accuracy
        let correctTrials = completedTrials.filter { $0.isCorrect == true }
        accuracy = Double(correctTrials.count) / Double(completedTrials.count)
        
        // Calculate average reaction time
        let reactionTimes = completedTrials.compactMap { $0.reactionTime }
        if !reactionTimes.isEmpty {
            averageReactionTime = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
        }
    }
    
    func exportData() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(trials)
    }
}
