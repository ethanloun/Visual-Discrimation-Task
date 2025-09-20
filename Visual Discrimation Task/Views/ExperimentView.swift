//
//  ExperimentView.swift
//  Visual Discrimation Task
//
//  Created by Ethan on 9/18/25.
//

import SwiftUI

struct ExperimentView: View {
    @StateObject private var session = ExperimentSession()
    @StateObject private var accessibilityManager = AccessibilityManager()
    @StateObject private var errorHandler = ErrorHandler()
    @State private var showingConfig = false
    @State private var showingResults = false
    @State private var currentResponse = ""
    @State private var responseStartTime: Date?
    @State private var isWaitingForResponse = false
    @State private var lastResponseCorrect: Bool? = nil
    @State private var showingBreak = false
    @State private var breakCountdown = 0
    @State private var showingPracticeComplete = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !session.isRunning {
                    startScreen
                } else if showingPracticeComplete {
                    practiceCompleteScreen
                } else if showingBreak {
                    breakScreen
                } else if isWaitingForResponse {
                    responseScreen
                } else {
                    trialScreen
                }
            }
            .padding()
            .navigationTitle("Visual Discrimination Task")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Settings") {
                        showingConfig = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingConfig) {
            ConfigurationView(session: session)
            #if os(iOS)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            #endif
        }
        .sheet(isPresented: $showingResults) {
            ResultsView(session: session)
            #if os(iOS)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            #endif
        }
        .alert("Error", isPresented: $errorHandler.showingError) {
            Button("OK") {
                errorHandler.clearError()
            }
        } message: {
            if let error = errorHandler.currentError {
                Text(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Start Screen
    private var startScreen: some View {
        VStack(spacing: 30) {
            Image(systemName: "eye.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Visual Discrimination Task")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Study of Human Visual Recognition with Rotated Figures")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Experiment Details:")
                    .font(.headline)
                
                Text("• Total Trials: \(session.config.totalTrials)")
                Text("• Figure Types: \(session.config.figureTypes.map { $0.rawValue }.joined(separator: ", "))")
                Text("• Rotation Angles: \(session.config.rotationAngles.count) different angles")
                Text("• Estimated Duration: \(estimatedDuration) minutes")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Button("Start Experiment") {
                session.startSession()
                startNextTrial()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
    
    // MARK: - Trial Screen
    private var trialScreen: some View {
        VStack(spacing: 30) {
            // Real-time Analytics
            RealTimeAnalytics(session: session)
            
            // Progress indicator
            ProgressView(value: Double(session.currentTrialIndex), 
                        total: Double(session.isPracticeMode ? session.practiceTrials.count : session.trials.count))
                .progressViewStyle(LinearProgressViewStyle())
            
            Text(session.isPracticeMode ? 
                 "Practice Trial \(session.currentTrialIndex + 1) of \(session.practiceTrials.count)" :
                 "Trial \(session.currentTrialIndex + 1) of \(session.trials.count)")
                .font(.headline)
            
            // Figure display
            if let trial = session.currentTrial {
                FigureGenerator.generateFigure(type: trial.figureType, rotationAngle: trial.rotationAngle)
                    .frame(width: 200, height: 200)
                    .background(accessibilityManager.isHighContrastEnabled ? Color.black : Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .accessibilityTrial(session.currentTrialIndex + 1, 
                                      session.isPracticeMode ? session.practiceTrials.count : session.trials.count, 
                                      trial.figureType)
                    .onAppear {
                        // Announce trial start for accessibility
                        accessibilityManager.announceTrialStart(
                            trialNumber: session.currentTrialIndex + 1,
                            totalTrials: session.isPracticeMode ? session.practiceTrials.count : session.trials.count,
                            figureType: trial.figureType
                        )
                        
                        // Start presentation timer
                        DispatchQueue.main.asyncAfter(deadline: .now() + session.config.presentationDuration) {
                            showResponseScreen()
                        }
                    }
            }
            
            // Immediate feedback overlay
            if let correct = lastResponseCorrect {
                Text(correct ? "Correct" : "Incorrect")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(correct ? .green : .red)
                    .transition(.opacity)
            }
            
            Text("Observe the figure carefully...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Response Screen
    private var responseScreen: some View {
        VStack(spacing: 30) {
            Text("What type of figure did you see?")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                Button("Simple") {
                    recordResponse("Simple")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityResponse("Simple", false)
                
                Button("Complex") {
                    recordResponse("Complex")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityResponse("Complex", false)
                
                if session.config.figureTypes.contains(.medium) {
                    Button("Medium") {
                        recordResponse("Medium")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .accessibilityResponse("Medium", false)
                }
                
                if session.config.figureTypes.contains(.veryComplex) {
                    Button("Very Complex") {
                        recordResponse("Very Complex")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .accessibilityResponse("Very Complex", false)
                }
            }
            
            Text("Please respond as quickly and accurately as possible")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Break Screen
    private var breakScreen: some View {
        VStack(spacing: 30) {
            Image(systemName: "pause.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Break Time")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Take a short break. The experiment will resume automatically.")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            if breakCountdown > 0 {
                Text("Resuming in \(breakCountdown) seconds...")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Button("Continue Now") {
                showingBreak = false
                startNextTrial()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - Practice Complete Screen
    private var practiceCompleteScreen: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Practice Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                Text("Practice Accuracy: \(String(format: "%.1f%%", session.practiceAccuracy * 100))")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("You're ready to begin the main experiment.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Button("Start Main Experiment") {
                showingPracticeComplete = false
                session.startMainExperiment()
                startNextTrial()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
    
    // MARK: - Helper Methods
    private var estimatedDuration: Int {
        let trialsPerMinute = 60.0 / (session.config.presentationDuration + session.config.responseTimeout)
        return Int(ceil(Double(session.config.totalTrials) / trialsPerMinute))
    }
    
    private func startNextTrial() {
        guard session.isRunning else { return }
        
        // Check if practice mode is complete
        if session.isPracticeMode && session.currentTrialIndex >= session.practiceTrials.count {
            showingPracticeComplete = true
            return
        }
        
        // Check if we need a break (only in main experiment)
        if !session.isPracticeMode && session.currentTrialIndex > 0 && session.currentTrialIndex % session.config.breakInterval == 0 {
            showBreak()
            return
        }
        
        // Check if experiment is complete
        if !session.isPracticeMode && session.currentTrialIndex >= session.trials.count {
            session.endSession()
            showingResults = true
            return
        }
        
        // Start next trial
        isWaitingForResponse = false
        responseStartTime = Date()
    }
    
    private func showResponseScreen() {
        isWaitingForResponse = true
        responseStartTime = Date()
    }
    
    private func recordResponse(_ response: String) {
        guard let responseTime = responseStartTime else { return }
        
        let beforeIndex = session.currentTrialIndex
        session.recordResponse(response: response, responseTime: Date())
        if beforeIndex < (session.isPracticeMode ? session.practiceTrials.count : session.trials.count) {
            lastResponseCorrect = session.isPracticeMode ? 
                session.practiceTrials[beforeIndex].isCorrect :
                session.trials[beforeIndex].isCorrect
        }
        isWaitingForResponse = false
        
        // Announce response for accessibility
        if let correct = lastResponseCorrect {
            let reactionTime = Date().timeIntervalSince(responseTime)
            accessibilityManager.announceResponse(correct: correct, reactionTime: reactionTime)
        }
        
        // Move to next trial after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            session.nextTrial()
            startNextTrial()
            withAnimation { lastResponseCorrect = nil }
        }
    }
    
    private func showBreak() {
        showingBreak = true
        breakCountdown = 30 // 30 second break
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if breakCountdown > 0 {
                breakCountdown -= 1
            } else {
                timer.invalidate()
                showingBreak = false
                startNextTrial()
            }
        }
    }
}

#Preview {
    ExperimentView()
}
