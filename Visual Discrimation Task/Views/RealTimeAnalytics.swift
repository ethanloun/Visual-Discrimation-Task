//
//  RealTimeAnalytics.swift
//  Visual Discrimation Task
//
//  Created by Ethan on 9/18/25.
//

import SwiftUI
import Charts

struct RealTimeAnalytics: View {
    @ObservedObject var session: ExperimentSession
    @State private var currentAccuracy: Double = 0.0
    @State private var currentReactionTime: Double = 0.0
    @State private var streakCount: Int = 0
    @State private var performanceHistory: [PerformancePoint] = []
    
    var body: some View {
        VStack(spacing: 15) {
            // Current Performance
            HStack(spacing: 20) {
                PerformanceMetric(
                    title: "Accuracy",
                    value: String(format: "%.1f%%", currentAccuracy * 100),
                    color: accuracyColor
                )
                
                PerformanceMetric(
                    title: "Avg RT",
                    value: String(format: "%.2fs", currentReactionTime),
                    color: reactionTimeColor
                )
                
                PerformanceMetric(
                    title: "Streak",
                    value: "\(streakCount)",
                    color: streakColor
                )
            }
            
            // Performance Trend Chart
            if #available(macOS 14.0, *) {
                Chart(performanceHistory, id: \.trialNumber) { point in
                    LineMark(
                        x: .value("Trial", point.trialNumber),
                        y: .value("Accuracy", point.accuracy)
                    )
                    .foregroundStyle(.blue)
                    
                    PointMark(
                        x: .value("Trial", point.trialNumber),
                        y: .value("Accuracy", point.accuracy)
                    )
                    .foregroundStyle(.blue)
                }
                .frame(height: 100)
                .chartYScale(domain: 0...1)
            } else {
                // Fallback for older macOS versions
                HStack {
                    ForEach(Array(performanceHistory.enumerated()), id: \.offset) { index, point in
                        Rectangle()
                            .fill(Color.blue.opacity(point.accuracy))
                            .frame(width: 2, height: CGFloat(point.accuracy * 50))
                    }
                }
                .frame(height: 100)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
            updatePerformanceMetrics()
        }
    }
    
    private var accuracyColor: Color {
        if currentAccuracy >= 0.8 { return .green }
        else if currentAccuracy >= 0.6 { return .orange }
        else { return .red }
    }
    
    private var reactionTimeColor: Color {
        if currentReactionTime <= 1.0 { return .green }
        else if currentReactionTime <= 2.0 { return .orange }
        else { return .red }
    }
    
    private var streakColor: Color {
        if streakCount >= 5 { return .green }
        else if streakCount >= 3 { return .orange }
        else { return .blue }
    }
    
    private func updatePerformanceMetrics() {
        let completedTrials = session.isPracticeMode ? 
            session.practiceTrials.filter { $0.isCorrect != nil } :
            session.trials.filter { $0.isCorrect != nil }
        
        guard !completedTrials.isEmpty else { return }
        
        // Calculate current accuracy
        let correctTrials = completedTrials.filter { $0.isCorrect == true }
        currentAccuracy = Double(correctTrials.count) / Double(completedTrials.count)
        
        // Calculate current average reaction time
        let reactionTimes = completedTrials.compactMap { $0.reactionTime }
        if !reactionTimes.isEmpty {
            currentReactionTime = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
        }
        
        // Calculate current streak
        streakCount = calculateCurrentStreak(completedTrials)
        
        // Update performance history
        updatePerformanceHistory(completedTrials)
    }
    
    private func calculateCurrentStreak(_ trials: [TrialData]) -> Int {
        var streak = 0
        for trial in trials.reversed() {
            if trial.isCorrect == true {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
    
    private func updatePerformanceHistory(_ trials: [TrialData]) {
        let windowSize = 10
        var history: [PerformancePoint] = []
        
        for i in stride(from: windowSize - 1, to: trials.count, by: 5) {
            let windowTrials = Array(trials[max(0, i - windowSize + 1)...i])
            let correctCount = windowTrials.filter { $0.isCorrect == true }.count
            let accuracy = Double(correctCount) / Double(windowTrials.count)
            
            history.append(PerformancePoint(
                trialNumber: i + 1,
                accuracy: accuracy,
                reactionTime: 0.0
            ))
        }
        
        performanceHistory = history
    }
}

struct PerformanceMetric: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 60)
    }
}

struct PerformancePoint {
    let trialNumber: Int
    let accuracy: Double
    let reactionTime: Double
}

#Preview {
    RealTimeAnalytics(session: ExperimentSession())
}
