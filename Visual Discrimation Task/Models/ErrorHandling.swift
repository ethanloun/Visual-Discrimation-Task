//
//  ErrorHandling.swift
//  Visual Discrimation Task
//
//  Created by Ethan on 9/18/25.
//

import Foundation
import SwiftUI

// MARK: - Error Types
enum ExperimentError: LocalizedError {
    case invalidConfiguration
    case trialGenerationFailed
    case dataExportFailed
    case sessionInterrupted
    case insufficientData
    case fileSystemError(String)
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Invalid experiment configuration. Please check your settings."
        case .trialGenerationFailed:
            return "Failed to generate trials. Please try again."
        case .dataExportFailed:
            return "Failed to export data. Please check file permissions."
        case .sessionInterrupted:
            return "Experiment session was interrupted."
        case .insufficientData:
            return "Insufficient data for analysis. Please complete more trials."
        case .fileSystemError(let message):
            return "File system error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidConfiguration:
            return "Please review and correct your experiment settings."
        case .trialGenerationFailed:
            return "Try reducing the number of trials or changing the configuration."
        case .dataExportFailed:
            return "Check that you have write permissions to the selected location."
        case .sessionInterrupted:
            return "You can resume the experiment from where you left off."
        case .insufficientData:
            return "Complete more trials to enable statistical analysis."
        case .fileSystemError:
            return "Check available disk space and file permissions."
        case .networkError:
            return "Check your internet connection and try again."
        }
    }
}

// MARK: - Error Handler
class ErrorHandler: ObservableObject {
    @Published var currentError: ExperimentError?
    @Published var showingError = false
    
    func handle(_ error: ExperimentError) {
        currentError = error
        showingError = true
        print("Error: \(error.localizedDescription)")
    }
    
    func clearError() {
        currentError = nil
        showingError = false
    }
}

// MARK: - Error Alert View
struct ErrorAlert: View {
    let error: ExperimentError
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title)
                .fontWeight(.bold)
            
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            Button("OK") {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

// MARK: - Performance Monitor
class PerformanceMonitor: ObservableObject {
    @Published var memoryUsage: Double = 0.0
    @Published var cpuUsage: Double = 0.0
    @Published var isLowMemory: Bool = false
    
    private var timer: Timer?
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateMetrics()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateMetrics() {
        // Monitor memory usage
        let memoryInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &memoryInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedMemory = Double(memoryInfo.resident_size) / 1024.0 / 1024.0 // MB
            memoryUsage = usedMemory
            isLowMemory = usedMemory > 500.0 // Alert if using more than 500MB
        }
    }
}

// MARK: - Data Validation
struct DataValidator {
    static func validateConfiguration(_ config: ExperimentConfig) throws {
        guard config.totalTrials > 0 else {
            throw ExperimentError.invalidConfiguration
        }
        
        guard !config.figureTypes.isEmpty else {
            throw ExperimentError.invalidConfiguration
        }
        
        guard !config.rotationAngles.isEmpty else {
            throw ExperimentError.invalidConfiguration
        }
        
        guard config.presentationDuration > 0 else {
            throw ExperimentError.invalidConfiguration
        }
        
        guard config.responseTimeout > 0 else {
            throw ExperimentError.invalidConfiguration
        }
    }
    
    static func validateTrialData(_ trials: [TrialData]) throws {
        guard !trials.isEmpty else {
            throw ExperimentError.insufficientData
        }
        
        let completedTrials = trials.filter { $0.isCorrect != nil }
        guard completedTrials.count >= 5 else {
            throw ExperimentError.insufficientData
        }
    }
}

// MARK: - Recovery Actions
extension ErrorHandler {
    func attemptRecovery(for error: ExperimentError) {
        switch error {
        case .invalidConfiguration:
            // Reset to default configuration
            break
        case .trialGenerationFailed:
            // Retry with simplified configuration
            break
        case .dataExportFailed:
            // Try alternative export format
            break
        case .sessionInterrupted:
            // Save current progress and offer resume
            break
        case .insufficientData:
            // Suggest completing more trials
            break
        case .fileSystemError:
            // Check disk space and permissions
            break
        case .networkError:
            // Retry network operation
            break
        }
    }
}
