//
//  ResearchManager.swift
//  Visual Discrimation Task
//
//  Created by Ethan on 9/18/25.
//

import Foundation
import SwiftUI

// MARK: - Research Study
struct ResearchStudy: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var principalInvestigator: String
    var institution: String
    var ethicsApprovalNumber: String
    var startDate: Date
    var endDate: Date?
    var isActive: Bool
    var participants: [StudyParticipant]
    var configuration: ExperimentConfig
    
    init(title: String, description: String, principalInvestigator: String, institution: String, ethicsApprovalNumber: String, configuration: ExperimentConfig) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.principalInvestigator = principalInvestigator
        self.institution = institution
        self.ethicsApprovalNumber = ethicsApprovalNumber
        self.startDate = Date()
        self.endDate = nil
        self.isActive = true
        self.participants = []
        self.configuration = configuration
    }
}

// MARK: - Study Participant
struct StudyParticipant: Identifiable, Codable {
    let id: UUID
    var participantID: String
    var demographics: Demographics
    var consentGiven: Bool
    var consentDate: Date?
    var sessions: [ExperimentSession]
    var enrollmentDate: Date
    
    init(participantID: String, demographics: Demographics) {
        self.id = UUID()
        self.participantID = participantID
        self.demographics = demographics
        self.consentGiven = false
        self.consentDate = nil
        self.sessions = []
        self.enrollmentDate = Date()
    }
}

// MARK: - Demographics
struct Demographics: Codable {
    var age: Int
    var gender: Gender
    var education: EducationLevel
    var handedness: Handedness
    var vision: VisionStatus
    var additionalNotes: String
    
    enum Gender: String, CaseIterable, Codable {
        case male = "Male"
        case female = "Female"
        case nonBinary = "Non-binary"
        case preferNotToSay = "Prefer not to say"
    }
    
    enum EducationLevel: String, CaseIterable, Codable {
        case highSchool = "High School"
        case someCollege = "Some College"
        case bachelors = "Bachelor's Degree"
        case masters = "Master's Degree"
        case doctorate = "Doctorate"
        case other = "Other"
    }
    
    enum Handedness: String, CaseIterable, Codable {
        case right = "Right-handed"
        case left = "Left-handed"
        case ambidextrous = "Ambidextrous"
    }
    
    enum VisionStatus: String, CaseIterable, Codable {
        case normal = "Normal or corrected to normal"
        case colorBlind = "Color blind"
        case other = "Other vision condition"
    }
}

// MARK: - Research Manager
class ResearchManager: ObservableObject {
    @Published var currentStudy: ResearchStudy?
    @Published var studies: [ResearchStudy] = []
    @Published var isCloudSyncEnabled: Bool = false
    @Published var lastSyncDate: Date?
    
    private let storageKey = "research_studies"
    private let cloudSyncKey = "cloud_sync_enabled"
    
    init() {
        loadStudies()
        checkCloudSyncStatus()
    }
    
    // MARK: - Study Management
    func createStudy(title: String, description: String, principalInvestigator: String, institution: String, ethicsApprovalNumber: String, configuration: ExperimentConfig) {
        let study = ResearchStudy(
            title: title,
            description: description,
            principalInvestigator: principalInvestigator,
            institution: institution,
            ethicsApprovalNumber: ethicsApprovalNumber,
            configuration: configuration
        )
        studies.append(study)
        saveStudies()
    }
    
    func setCurrentStudy(_ study: ResearchStudy) {
        currentStudy = study
    }
    
    func addParticipant(to study: ResearchStudy, participantID: String, demographics: Demographics) {
        guard let index = studies.firstIndex(where: { $0.id == study.id }) else { return }
        
        let participant = StudyParticipant(participantID: participantID, demographics: demographics)
        studies[index].participants.append(participant)
        saveStudies()
    }
    
    func recordSession(for participant: StudyParticipant, session: ExperimentSession) {
        guard let studyIndex = studies.firstIndex(where: { $0.id == currentStudy?.id }),
              let participantIndex = studies[studyIndex].participants.firstIndex(where: { $0.id == participant.id }) else { return }
        
        studies[studyIndex].participants[participantIndex].sessions.append(session)
        saveStudies()
    }
    
    // MARK: - Data Export
    func exportStudyData(_ study: ResearchStudy) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(study)
    }
    
    func exportAllData() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(studies)
    }
    
    // MARK: - Cloud Sync
    func enableCloudSync() {
        isCloudSyncEnabled = true
        UserDefaults.standard.set(true, forKey: cloudSyncKey)
        syncToCloud()
    }
    
    func disableCloudSync() {
        isCloudSyncEnabled = false
        UserDefaults.standard.set(false, forKey: cloudSyncKey)
    }
    
    func syncToCloud() {
        guard isCloudSyncEnabled else { return }
        
        // Simulate cloud sync
        DispatchQueue.global(qos: .background).async {
            // In a real implementation, this would sync to a cloud service
            DispatchQueue.main.async {
                self.lastSyncDate = Date()
            }
        }
    }
    
    // MARK: - Privacy & Ethics
    func generateConsentForm(for study: ResearchStudy) -> String {
        return """
        INFORMED CONSENT FORM
        
        Study Title: \(study.title)
        Principal Investigator: \(study.principalInvestigator)
        Institution: \(study.institution)
        Ethics Approval Number: \(study.ethicsApprovalNumber)
        
        STUDY DESCRIPTION:
        \(study.description)
        
        PARTICIPANT RIGHTS:
        - You have the right to withdraw from the study at any time
        - Your data will be kept confidential and anonymous
        - You will receive a summary of the study results upon completion
        
        DATA COLLECTION:
        - We will collect your responses to visual discrimination tasks
        - We will measure your reaction times and accuracy
        - Your data will be stored securely and used only for research purposes
        
        CONTACT INFORMATION:
        If you have any questions about this study, please contact:
        \(study.principalInvestigator)
        \(study.institution)
        
        By participating in this study, you consent to the collection and use of your data as described above.
        
        Participant Signature: _________________ Date: _________
        """
    }
    
    func generateDataPrivacyStatement() -> String {
        return """
        DATA PRIVACY STATEMENT
        
        This study complies with applicable data protection regulations including GDPR and CCPA.
        
        DATA COLLECTION:
        - We collect only the data necessary for the research
        - Personal identifiers are kept separate from research data
        - Data is stored securely with appropriate access controls
        
        DATA USE:
        - Data is used solely for the stated research purposes
        - Results may be published in anonymized form
        - Data may be shared with other researchers under strict conditions
        
        YOUR RIGHTS:
        - Right to access your data
        - Right to correct inaccurate data
        - Right to request data deletion
        - Right to data portability
        
        DATA RETENTION:
        - Data will be retained for the minimum period required by law
        - Anonymized data may be retained indefinitely for research purposes
        
        CONTACT:
        For questions about data privacy, contact the Principal Investigator.
        """
    }
    
    // MARK: - Private Methods
    private func loadStudies() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ResearchStudy].self, from: data) {
            studies = decoded
        }
    }
    
    private func saveStudies() {
        if let data = try? JSONEncoder().encode(studies) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func checkCloudSyncStatus() {
        isCloudSyncEnabled = UserDefaults.standard.bool(forKey: cloudSyncKey)
    }
}

// MARK: - Study Analytics
extension ResearchManager {
    func generateStudyReport(for study: ResearchStudy) -> StudyReport {
        let allSessions = study.participants.flatMap { $0.sessions }
        let totalParticipants = study.participants.count
        let totalSessions = allSessions.count
        
        // Calculate overall statistics
        let overallAccuracy = calculateOverallAccuracy(allSessions)
        let averageReactionTime = calculateAverageReactionTime(allSessions)
        
        // Calculate demographic breakdown
        let demographicBreakdown = calculateDemographicBreakdown(study.participants)
        
        // Calculate completion rates
        let completionRate = calculateCompletionRate(study.participants)
        
        return StudyReport(
            study: study,
            totalParticipants: totalParticipants,
            totalSessions: totalSessions,
            overallAccuracy: overallAccuracy,
            averageReactionTime: averageReactionTime,
            demographicBreakdown: demographicBreakdown,
            completionRate: completionRate,
            generatedDate: Date()
        )
    }
    
    private func calculateOverallAccuracy(_ sessions: [ExperimentSession]) -> Double {
        let allTrials = sessions.flatMap { $0.trials }
        let completedTrials = allTrials.filter { $0.isCorrect != nil }
        guard !completedTrials.isEmpty else { return 0.0 }
        
        let correctTrials = completedTrials.filter { $0.isCorrect == true }
        return Double(correctTrials.count) / Double(completedTrials.count)
    }
    
    private func calculateAverageReactionTime(_ sessions: [ExperimentSession]) -> Double {
        let allTrials = sessions.flatMap { $0.trials }
        let reactionTimes = allTrials.compactMap { $0.reactionTime }
        guard !reactionTimes.isEmpty else { return 0.0 }
        
        return reactionTimes.reduce(0, +) / Double(reactionTimes.count)
    }
    
    private func calculateDemographicBreakdown(_ participants: [StudyParticipant]) -> DemographicBreakdown {
        let total = participants.count
        guard total > 0 else { return DemographicBreakdown() }
        
        let genderCounts = Dictionary(grouping: participants, by: { $0.demographics.gender })
        let educationCounts = Dictionary(grouping: participants, by: { $0.demographics.education })
        let handednessCounts = Dictionary(grouping: participants, by: { $0.demographics.handedness })
        
        return DemographicBreakdown(
            genderDistribution: genderCounts.mapValues { Double($0.count) / Double(total) },
            educationDistribution: educationCounts.mapValues { Double($0.count) / Double(total) },
            handednessDistribution: handednessCounts.mapValues { Double($0.count) / Double(total) }
        )
    }
    
    private func calculateCompletionRate(_ participants: [StudyParticipant]) -> Double {
        let completedParticipants = participants.filter { !$0.sessions.isEmpty }
        return Double(completedParticipants.count) / Double(participants.count)
    }
}

// MARK: - Supporting Structures
struct StudyReport {
    let study: ResearchStudy
    let totalParticipants: Int
    let totalSessions: Int
    let overallAccuracy: Double
    let averageReactionTime: Double
    let demographicBreakdown: DemographicBreakdown
    let completionRate: Double
    let generatedDate: Date
}

struct DemographicBreakdown {
    let genderDistribution: [Demographics.Gender: Double]
    let educationDistribution: [Demographics.EducationLevel: Double]
    let handednessDistribution: [Demographics.Handedness: Double]
    
    init() {
        self.genderDistribution = [:]
        self.educationDistribution = [:]
        self.handednessDistribution = [:]
    }
}
