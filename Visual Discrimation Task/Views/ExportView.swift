//
//  ExportView.swift
//  Visual Discrimation Task
//
//  Created by Ethan on 9/18/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ExportView: View {
    @ObservedObject var session: ExperimentSession
    @Environment(\.dismiss) private var dismiss
    @State private var exportFormat: ExportFormat = .json
    @State private var showingFileExporter = false
    @State private var exportData: Data?
    
    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case csv = "CSV"
        case txt = "Text"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Export Experiment Data")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Export Format")
                        .font(.headline)
                    
                    Picker("Format", selection: $exportFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Text("Choose the format for exporting your experiment data.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Export Summary")
                        .font(.headline)
                    
                    HStack {
                        Text("Total Trials:")
                        Spacer()
                        Text("\(session.trials.count)")
                    }
                    
                    HStack {
                        Text("Completed Trials:")
                        Spacer()
                        Text("\(session.trialsCompleted)")
                    }
                    
                    HStack {
                        Text("Overall Accuracy:")
                        Spacer()
                        Text(String(format: "%.1f%%", session.accuracy * 100))
                    }
                    
                    HStack {
                        Text("Average Reaction Time:")
                        Spacer()
                        Text(String(format: "%.2fs", session.averageReactionTime))
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Button("Export Data") {
                    prepareExport()
                    showingFileExporter = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export Data")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .fileExporter(
            isPresented: $showingFileExporter,
            document: ExportDocument(data: exportData ?? Data()),
            contentType: UTType.plainText,
            defaultFilename: "visual_discrimination_data_\(session.config.participantID)_\(Date().timeIntervalSince1970)"
        ) { result in
            switch result {
            case .success(let url):
                print("Export successful: \(url)")
            case .failure(let error):
                print("Export failed: \(error)")
            }
        }
    }
    
    private func prepareExport() {
        switch exportFormat {
        case .json:
            exportData = session.exportData()
        case .csv:
            exportData = generateCSVData()
        case .txt:
            exportData = generateTextData()
        }
    }
    
    private func generateCSVData() -> Data? {
        var csvContent = "Trial,FigureType,RotationAngle,Response,IsCorrect,ReactionTime,Block,PresentationTime,ResponseTime\n"
        
        for trial in session.trials {
            let response = trial.response ?? ""
            let isCorrect = trial.isCorrect?.description ?? ""
            let reactionTime = trial.reactionTime?.description ?? ""
            let presentationTime = ISO8601DateFormatter().string(from: trial.presentationTime)
            let responseTime = trial.responseTime != nil ? ISO8601DateFormatter().string(from: trial.responseTime!) : ""
            
            csvContent += "\(trial.trialNumber),\(trial.figureType.rawValue),\(trial.rotationAngle),\(response),\(isCorrect),\(reactionTime),\(trial.blockNumber),\(presentationTime),\(responseTime)\n"
        }
        
        return csvContent.data(using: .utf8)
    }
    
    private func generateTextData() -> Data? {
        var textContent = "Visual Discrimination Task - Experiment Results\n"
        textContent += "==========================================\n\n"
        
        textContent += "Participant ID: \(session.config.participantID)\n"
        textContent += "Session ID: \(session.config.sessionID)\n"
        textContent += "Total Trials: \(session.trials.count)\n"
        textContent += "Completed Trials: \(session.trialsCompleted)\n"
        textContent += "Overall Accuracy: \(String(format: "%.1f%%", session.accuracy * 100))\n"
        textContent += "Average Reaction Time: \(String(format: "%.2fs", session.averageReactionTime))\n\n"
        
        textContent += "Trial Details:\n"
        textContent += "=============\n"
        
        for trial in session.trials {
            textContent += "Trial \(trial.trialNumber): \(trial.figureType.rawValue) at \(Int(trial.rotationAngle))° - "
            if let response = trial.response, let isCorrect = trial.isCorrect {
                textContent += "\(response) (\(isCorrect ? "Correct" : "Incorrect"))"
                if let reactionTime = trial.reactionTime {
                    textContent += " - \(String(format: "%.2fs", reactionTime))"
                }
            } else {
                textContent += "No response"
            }
            textContent += "\n"
        }
        
        return textContent.data(using: .utf8)
    }
}

// MARK: - Export Document
struct ExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText, .json] }
    
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    ExportView(session: ExperimentSession())
}
