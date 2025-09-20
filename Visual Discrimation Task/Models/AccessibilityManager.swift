//
//  AccessibilityManager.swift
//  Visual Discrimation Task
//
//  Created by Ethan on 9/18/25.
//

import SwiftUI
import AVFoundation

class AccessibilityManager: ObservableObject {
    @Published var isVoiceOverEnabled: Bool = false
    @Published var isHighContrastEnabled: Bool = false
    @Published var isLargeTextEnabled: Bool = false
    @Published var isAudioFeedbackEnabled: Bool = false
    @Published var fontSize: FontSize = .normal
    
    enum FontSize: String, CaseIterable {
        case small = "Small"
        case normal = "Normal"
        case large = "Large"
        case extraLarge = "Extra Large"
        
        var scale: CGFloat {
            switch self {
            case .small: return 0.8
            case .normal: return 1.0
            case .large: return 1.2
            case .extraLarge: return 1.5
            }
        }
    }
    
    private let synthesizer = AVSpeechSynthesizer()
    
    init() {
        checkAccessibilitySettings()
    }
    
    private func checkAccessibilitySettings() {
        // Check if VoiceOver is enabled
        isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
        
        // Check for high contrast mode (simplified check)
        isHighContrastEnabled = UIAccessibility.isDarkerSystemColorsEnabled
        
        // Check for large text
        let contentSizeCategory = UIApplication.shared.preferredContentSizeCategory
        isLargeTextEnabled = contentSizeCategory.isAccessibilityCategory
    }
    
    func speak(_ text: String) {
        guard isAudioFeedbackEnabled else { return }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }
    
    func announceTrialStart(trialNumber: Int, totalTrials: Int, figureType: FigureType) {
        let message = "Trial \(trialNumber) of \(totalTrials). Figure type: \(figureType.rawValue)"
        speak(message)
    }
    
    func announceResponse(correct: Bool, reactionTime: TimeInterval) {
        let message = correct ? "Correct" : "Incorrect"
        let timeMessage = String(format: "Reaction time: %.2f seconds", reactionTime)
        speak("\(message). \(timeMessage)")
    }
    
    func announcePracticeComplete(accuracy: Double) {
        let message = String(format: "Practice complete. Accuracy: %.1f percent", accuracy * 100)
        speak(message)
    }
    
    func announceExperimentComplete(accuracy: Double) {
        let message = String(format: "Experiment complete. Final accuracy: %.1f percent", accuracy * 100)
        speak(message)
    }
}

// MARK: - Accessibility Modifiers
extension View {
    func accessibilityEnhanced() -> some View {
        self
            .accessibilityLabel("Visual Discrimination Task")
            .accessibilityHint("Tap to interact with the experiment")
    }
    
    func accessibilityTrial(_ trialNumber: Int, _ totalTrials: Int, _ figureType: FigureType) -> some View {
        self
            .accessibilityLabel("Trial \(trialNumber) of \(totalTrials)")
            .accessibilityValue("Figure type: \(figureType.rawValue)")
    }
    
    func accessibilityResponse(_ response: String, _ correct: Bool) -> some View {
        self
            .accessibilityLabel("Response: \(response)")
            .accessibilityValue(correct ? "Correct" : "Incorrect")
    }
}

// MARK: - High Contrast Colors
extension Color {
    static let highContrastBlue = Color(red: 0.0, green: 0.0, blue: 1.0)
    static let highContrastRed = Color(red: 1.0, green: 0.0, blue: 0.0)
    static let highContrastGreen = Color(red: 0.0, green: 0.8, blue: 0.0)
    static let highContrastOrange = Color(red: 1.0, green: 0.5, blue: 0.0)
    static let highContrastPurple = Color(red: 0.5, green: 0.0, blue: 1.0)
}
