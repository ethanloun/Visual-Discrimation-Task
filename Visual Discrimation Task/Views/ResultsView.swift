//
//  ResultsView.swift
//  Visual Discrimation Task
//
//  Created by Ethan on 9/18/25.
//

import SwiftUI
import Charts

struct ResultsView: View {
    @ObservedObject var session: ExperimentSession
    @Environment(\.dismiss) private var dismiss
    @State private var showingExportSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Statistics
                    summarySection
                    
                    // Accuracy by Rotation Angle
                    accuracyByRotationChart
                    
                    // Reaction Time Analysis
                    reactionTimeChart
                    
                    // Figure Type Comparison
                    figureTypeComparison
                    
                    // Detailed Results Table
                    detailedResultsTable
                }
                .padding()
            }
            .navigationTitle("Experiment Results")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Export") {
                        showingExportSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportView(session: session)
        }
    }
    
    // MARK: - Summary Section
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Summary Statistics")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatCard(
                    title: "Overall Accuracy",
                    value: String(format: "%.1f%%", session.accuracy * 100),
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Avg Reaction Time",
                    value: String(format: "%.2fs", session.averageReactionTime),
                    icon: "clock.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Trials Completed",
                    value: "\(session.trialsCompleted)",
                    icon: "number.circle.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    // MARK: - Accuracy by Rotation Chart
    private var accuracyByRotationChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Accuracy by Rotation Angle")
                .font(.title2)
                .fontWeight(.bold)
            
            if #available(macOS 14.0, *) {
                Chart(accuracyByRotationData, id: \.angle) { dataPoint in
                    LineMark(
                        x: .value("Angle", dataPoint.angle),
                        y: .value("Accuracy", dataPoint.accuracy)
                    )
                    .foregroundStyle(.blue)
                    
                    PointMark(
                        x: .value("Angle", dataPoint.angle),
                        y: .value("Accuracy", dataPoint.accuracy)
                    )
                    .foregroundStyle(.blue)
                }
                .frame(height: 200)
                .chartYScale(domain: 0...1)
                .chartYAxisLabel("Accuracy")
                .chartXAxisLabel("Rotation Angle (degrees)")
            } else {
                // Fallback for older macOS versions
                VStack {
                    Text("Charts require macOS 14.0 or later")
                        .foregroundColor(.secondary)
                    
                    // Simple text-based representation
                    ForEach(accuracyByRotationData, id: \.angle) { data in
                        HStack {
                            Text("\(Int(data.angle))°")
                                .frame(width: 40, alignment: .leading)
                            ProgressView(value: data.accuracy)
                                .frame(width: 100)
                            Text("\(Int(data.accuracy * 100))%")
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    // MARK: - Reaction Time Chart
    private var reactionTimeChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Reaction Time by Rotation Angle")
                .font(.title2)
                .fontWeight(.bold)
            
            if #available(macOS 14.0, *) {
                Chart(reactionTimeData, id: \.angle) { dataPoint in
                    BarMark(
                        x: .value("Angle", dataPoint.angle),
                        y: .value("Reaction Time", dataPoint.reactionTime)
                    )
                    .foregroundStyle(.orange)
                }
                .frame(height: 200)
                .chartYAxisLabel("Reaction Time (seconds)")
                .chartXAxisLabel("Rotation Angle (degrees)")
            } else {
                // Fallback for older macOS versions
                VStack {
                    Text("Charts require macOS 14.0 or later")
                        .foregroundColor(.secondary)
                    
                    ForEach(reactionTimeData, id: \.angle) { data in
                        HStack {
                            Text("\(Int(data.angle))°")
                                .frame(width: 40, alignment: .leading)
                            Text(String(format: "%.2fs", data.reactionTime))
                                .frame(width: 60, alignment: .trailing)
                        }
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    // MARK: - Figure Type Comparison
    private var figureTypeComparison: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Figure Type Comparison")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                ForEach(FigureType.allCases, id: \.self) { figureType in
                    VStack {
                        FigurePreview(figureType: figureType, rotationAngle: 0)
                            .frame(width: 60, height: 60)
                        
                        Text(figureType.rawValue)
                            .font(.caption)
                        
                        Text("\(accuracyForFigureType(figureType), specifier: "%.1f%%")")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    // MARK: - Detailed Results Table
    private var detailedResultsTable: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Detailed Results")
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView(.horizontal) {
                Table(session.trials) {
                    TableColumn("Trial") { trial in
                        Text("\(trial.trialNumber)")
                    }
                    
                    TableColumn("Figure Type") { trial in
                        Text(trial.figureType.rawValue)
                    }
                    
                    TableColumn("Rotation") { trial in
                        Text("\(Int(trial.rotationAngle))°")
                    }
                    
                    TableColumn("Response") { trial in
                        Text(trial.response ?? "N/A")
                    }
                    
                    TableColumn("Correct") { trial in
                        Image(systemName: trial.isCorrect == true ? "checkmark" : "xmark")
                            .foregroundColor(trial.isCorrect == true ? .green : .red)
                    }
                    
                    TableColumn("Reaction Time") { trial in
                        Text(trial.reactionTime != nil ? String(format: "%.2fs", trial.reactionTime!) : "N/A")
                    }
                }
                .frame(minWidth: 600)
            }
            .frame(maxHeight: 300)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    // MARK: - Computed Properties
    private var accuracyByRotationData: [ChartDataPoint] {
        let groupedTrials = Dictionary(grouping: session.trials.filter { $0.isCorrect != nil }) { $0.rotationAngle }
        
        return groupedTrials.map { (angle, trials) in
            let correctCount = trials.filter { $0.isCorrect == true }.count
            let accuracy = Double(correctCount) / Double(trials.count)
            return ChartDataPoint(angle: angle, accuracy: accuracy, reactionTime: 0)
        }.sorted { $0.angle < $1.angle }
    }
    
    private var reactionTimeData: [ChartDataPoint] {
        let groupedTrials = Dictionary(grouping: session.trials.filter { $0.reactionTime != nil }) { $0.rotationAngle }
        
        return groupedTrials.map { (angle, trials) in
            let avgReactionTime = trials.compactMap { $0.reactionTime }.reduce(0, +) / Double(trials.count)
            return ChartDataPoint(angle: angle, accuracy: 0, reactionTime: avgReactionTime)
        }.sorted { $0.angle < $1.angle }
    }
    
    private func accuracyForFigureType(_ figureType: FigureType) -> Double {
        let trials = session.trials.filter { $0.figureType == figureType && $0.isCorrect != nil }
        guard !trials.isEmpty else { return 0 }
        
        let correctCount = trials.filter { $0.isCorrect == true }.count
        return Double(correctCount) / Double(trials.count) * 100
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

struct ChartDataPoint {
    let angle: Double
    let accuracy: Double
    let reactionTime: Double
}

#Preview {
    ResultsView(session: ExperimentSession())
}
