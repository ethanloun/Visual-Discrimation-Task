//
//  ConfigurationView.swift
//  Visual Discrimation Task
//
//  Created by Ethan on 9/18/25.
//

import SwiftUI

struct ConfigurationView: View {
    @ObservedObject var session: ExperimentSession
    @Environment(\.dismiss) private var dismiss
    
    @State private var participantID: String
    @State private var totalTrials: Int
    @State private var presentationDuration: Double
    @State private var responseTimeout: Double
    @State private var breakInterval: Int
    @State private var selectedFigureTypes: Set<FigureType>
    @State private var rotationAngles: [Double]
    
    init(session: ExperimentSession) {
        self.session = session
        self._participantID = State(initialValue: session.config.participantID)
        self._totalTrials = State(initialValue: session.config.totalTrials)
        self._presentationDuration = State(initialValue: session.config.presentationDuration)
        self._responseTimeout = State(initialValue: session.config.responseTimeout)
        self._breakInterval = State(initialValue: session.config.breakInterval)
        self._selectedFigureTypes = State(initialValue: Set(session.config.figureTypes))
        self._rotationAngles = State(initialValue: session.config.rotationAngles)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Participant Information") {
                    TextField("Participant ID", text: $participantID)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section("Experiment Parameters") {
                    VStack(alignment: .leading) {
                        Text("Total Trials: \(totalTrials)")
                        Slider(value: Binding(
                            get: { Double(totalTrials) },
                            set: { totalTrials = Int($0) }
                        ), in: 20...200, step: 10)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Presentation Duration: \(String(format: "%.1f", presentationDuration))s")
                        Slider(value: $presentationDuration, in: 0.5...5.0, step: 0.1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Response Timeout: \(String(format: "%.1f", responseTimeout))s")
                        Slider(value: $responseTimeout, in: 1.0...10.0, step: 0.5)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Break Interval: \(breakInterval) trials")
                        Slider(value: Binding(
                            get: { Double(breakInterval) },
                            set: { breakInterval = Int($0) }
                        ), in: 10...50, step: 5)
                    }
                }
                
                Section("Figure Types") {
                    ForEach(FigureType.allCases, id: \.self) { figureType in
                        HStack {
                            Button(action: {
                                if selectedFigureTypes.contains(figureType) {
                                    selectedFigureTypes.remove(figureType)
                                } else {
                                    selectedFigureTypes.insert(figureType)
                                }
                            }) {
                                Image(systemName: selectedFigureTypes.contains(figureType) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(selectedFigureTypes.contains(figureType) ? .blue : .gray)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Text(figureType.rawValue)
                            
                            Spacer()
                            
                            FigurePreview(figureType: figureType, rotationAngle: 0)
                                .frame(width: 40, height: 40)
                        }
                    }
                }
                
                Section("Rotation Angles") {
                    VStack(alignment: .leading) {
                        Text("Current angles: \(rotationAngles.map { "\(Int($0))°" }.joined(separator: ", "))")
                            .font(.caption)
                        
                        HStack {
                            Button("Reset to Default") {
                                rotationAngles = [0, 15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 180]
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Custom Range") {
                                showCustomAngleDialog()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                
                Section("Preview") {
                    Text("Estimated Duration: \(estimatedDuration) minutes")
                        .font(.headline)
                    
                    Text("Trials per condition: \(trialsPerCondition)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Experiment Configuration")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveConfiguration()
                        dismiss()
                    }
                    .disabled(selectedFigureTypes.isEmpty)
                }
            }
        }
    }
    
    private var estimatedDuration: Int {
        let trialsPerMinute = 60.0 / (presentationDuration + responseTimeout)
        return Int(ceil(Double(totalTrials) / trialsPerMinute))
    }
    
    private var trialsPerCondition: Int {
        totalTrials / (selectedFigureTypes.count * rotationAngles.count)
    }
    
    private func saveConfiguration() {
        let newConfig = ExperimentConfig(
            participantID: participantID,
            sessionID: UUID().uuidString,
            totalTrials: totalTrials,
            rotationAngles: rotationAngles,
            figureTypes: Array(selectedFigureTypes),
            presentationDuration: presentationDuration,
            responseTimeout: responseTimeout,
            breakInterval: breakInterval
        )
        
        session.config = newConfig
        session.generateTrials()
    }
    
    private func showCustomAngleDialog() {
        // This would show a custom dialog for setting rotation angles
        // For now, we'll use a simple preset
        rotationAngles = [0, 30, 60, 90, 120, 150, 180]
    }
}

#Preview {
    ConfigurationView(session: ExperimentSession())
}
