//
//  EnhancedTests.swift
//  Visual Discrimation TaskTests
//
//  Created by Ethan on 9/18/25.
//

import XCTest
@testable import Visual_Discrimation_Task

class EnhancedTests: XCTestCase {
    
    var session: ExperimentSession!
    var config: ExperimentConfig!
    
    override func setUpWithError() throws {
        config = ExperimentConfig.defaultConfig
        session = ExperimentSession(config: config)
    }
    
    override func tearDownWithError() throws {
        session = nil
        config = nil
    }
    
    // MARK: - Figure Type Tests
    func testFigureTypeComplexity() throws {
        XCTAssertEqual(FigureType.simple.complexity, 1)
        XCTAssertEqual(FigureType.medium.complexity, 2)
        XCTAssertEqual(FigureType.complex.complexity, 3)
        XCTAssertEqual(FigureType.veryComplex.complexity, 4)
    }
    
    func testFigureTypeDescriptions() throws {
        XCTAssertFalse(FigureType.simple.description.isEmpty)
        XCTAssertFalse(FigureType.medium.description.isEmpty)
        XCTAssertFalse(FigureType.complex.description.isEmpty)
        XCTAssertFalse(FigureType.veryComplex.description.isEmpty)
    }
    
    // MARK: - Practice Mode Tests
    func testPracticeModeGeneration() throws {
        let practiceConfig = ExperimentConfig(
            participantID: "TEST",
            sessionID: "TEST_SESSION",
            totalTrials: 20,
            practiceTrials: 5,
            rotationAngles: [0, 90, 180],
            figureTypes: [.simple, .complex],
            presentationDuration: 1.0,
            responseTimeout: 3.0,
            breakInterval: 10,
            enablePracticeMode: true,
            adaptiveDifficulty: false
        )
        
        let practiceSession = ExperimentSession(config: practiceConfig)
        
        XCTAssertEqual(practiceSession.practiceTrials.count, 5)
        XCTAssertEqual(practiceSession.trials.count, 20)
        XCTAssertTrue(practiceSession.config.enablePracticeMode)
    }
    
    func testPracticeModeTransition() throws {
        session.startSession()
        XCTAssertTrue(session.isPracticeMode)
        
        // Complete practice trials
        for _ in 0..<session.practiceTrials.count {
            session.nextTrial()
        }
        
        XCTAssertFalse(session.isPracticeMode)
    }
    
    // MARK: - Statistical Analysis Tests
    func testBasicStatistics() throws {
        let trials = createMockTrials()
        let stats = StatisticalAnalysis.calculateBasicStatistics(for: trials)
        
        XCTAssertEqual(stats.totalTrials, 10)
        XCTAssertEqual(stats.completedTrials, 10)
        XCTAssertEqual(stats.accuracy, 0.8, accuracy: 0.01)
    }
    
    func testTTest() throws {
        let group1 = [1.0, 2.0, 3.0, 4.0, 5.0]
        let group2 = [2.0, 3.0, 4.0, 5.0, 6.0]
        
        let result = StatisticalAnalysis.tTest(group1: group1, group2: group2)
        
        XCTAssertNotNil(result.tStatistic)
        XCTAssertNotNil(result.pValue)
        XCTAssertEqual(result.degreesOfFreedom, 8)
    }
    
    func testANOVA() throws {
        let groups = [
            [1.0, 2.0, 3.0],
            [2.0, 3.0, 4.0],
            [3.0, 4.0, 5.0]
        ]
        
        let result = StatisticalAnalysis.oneWayANOVA(groups: groups)
        
        XCTAssertNotNil(result.fStatistic)
        XCTAssertNotNil(result.pValue)
        XCTAssertEqual(result.degreesOfFreedomBetween, 2)
        XCTAssertEqual(result.degreesOfFreedomWithin, 6)
    }
    
    func testLinearRegression() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [2.0, 4.0, 6.0, 8.0, 10.0]
        
        let result = StatisticalAnalysis.linearRegression(x: x, y: y)
        
        XCTAssertEqual(result.slope, 2.0, accuracy: 0.01)
        XCTAssertEqual(result.rSquared, 1.0, accuracy: 0.01)
    }
    
    func testCohensD() throws {
        let group1 = [1.0, 2.0, 3.0, 4.0, 5.0]
        let group2 = [3.0, 4.0, 5.0, 6.0, 7.0]
        
        let d = StatisticalAnalysis.cohensD(group1: group1, group2: group2)
        
        XCTAssertNotNil(d)
        XCTAssertGreaterThan(d, 0)
    }
    
    // MARK: - Error Handling Tests
    func testDataValidation() throws {
        let invalidConfig = ExperimentConfig(
            participantID: "",
            sessionID: "",
            totalTrials: 0,
            practiceTrials: 0,
            rotationAngles: [],
            figureTypes: [],
            presentationDuration: 0,
            responseTimeout: 0,
            breakInterval: 0,
            enablePracticeMode: false,
            adaptiveDifficulty: false
        )
        
        XCTAssertThrowsError(try DataValidator.validateConfiguration(invalidConfig))
    }
    
    func testInsufficientDataError() throws {
        let emptyTrials: [TrialData] = []
        XCTAssertThrowsError(try DataValidator.validateTrialData(emptyTrials))
    }
    
    // MARK: - Performance Tests
    func testTrialGenerationPerformance() throws {
        measure {
            let largeConfig = ExperimentConfig(
                participantID: "PERF_TEST",
                sessionID: "PERF_SESSION",
                totalTrials: 1000,
                practiceTrials: 50,
                rotationAngles: Array(stride(from: 0, through: 180, by: 15)),
                figureTypes: FigureType.allCases,
                presentationDuration: 2.0,
                responseTimeout: 5.0,
                breakInterval: 50,
                enablePracticeMode: true,
                adaptiveDifficulty: false
            )
            
            let perfSession = ExperimentSession(config: largeConfig)
            XCTAssertEqual(perfSession.trials.count, 1000)
            XCTAssertEqual(perfSession.practiceTrials.count, 50)
        }
    }
    
    func testStatisticalAnalysisPerformance() throws {
        let largeDataset = createLargeMockTrials(count: 1000)
        
        measure {
            let _ = StatisticalAnalysis.calculateBasicStatistics(for: largeDataset)
            let _ = StatisticalAnalysis.analyzeByRotationAngle(for: largeDataset)
            let _ = StatisticalAnalysis.analyzeByFigureType(for: largeDataset)
        }
    }
    
    // MARK: - Accessibility Tests
    func testAccessibilityManager() throws {
        let accessibilityManager = AccessibilityManager()
        
        XCTAssertFalse(accessibilityManager.isVoiceOverEnabled)
        XCTAssertFalse(accessibilityManager.isHighContrastEnabled)
        XCTAssertFalse(accessibilityManager.isLargeTextEnabled)
        XCTAssertFalse(accessibilityManager.isAudioFeedbackEnabled)
    }
    
    func testAccessibilityAnnouncements() throws {
        let accessibilityManager = AccessibilityManager()
        accessibilityManager.isAudioFeedbackEnabled = true
        
        // Test that announcements don't crash
        accessibilityManager.announceTrialStart(trialNumber: 1, totalTrials: 10, figureType: .simple)
        accessibilityManager.announceResponse(correct: true, reactionTime: 1.5)
        accessibilityManager.announcePracticeComplete(accuracy: 0.8)
        accessibilityManager.announceExperimentComplete(accuracy: 0.75)
    }
    
    // MARK: - Research Manager Tests
    func testResearchStudyCreation() throws {
        let researchManager = ResearchManager()
        let config = ExperimentConfig.defaultConfig
        
        researchManager.createStudy(
            title: "Test Study",
            description: "A test study for unit testing",
            principalInvestigator: "Dr. Test",
            institution: "Test University",
            ethicsApprovalNumber: "TEST-2024-001",
            configuration: config
        )
        
        XCTAssertEqual(researchManager.studies.count, 1)
        XCTAssertEqual(researchManager.studies.first?.title, "Test Study")
    }
    
    func testParticipantDemographics() throws {
        let demographics = Demographics(
            age: 25,
            gender: .female,
            education: .bachelors,
            handedness: .right,
            vision: .normal,
            additionalNotes: "Test participant"
        )
        
        XCTAssertEqual(demographics.age, 25)
        XCTAssertEqual(demographics.gender, .female)
        XCTAssertEqual(demographics.education, .bachelors)
    }
    
    // MARK: - Helper Methods
    private func createMockTrials() -> [TrialData] {
        var trials: [TrialData] = []
        
        for i in 0..<10 {
            let trial = TrialData(
                trialNumber: i + 1,
                figureType: i % 2 == 0 ? .simple : .complex,
                rotationAngle: Double(i * 20),
                presentationTime: Date(),
                blockNumber: 1
            )
            
            // Simulate 80% accuracy
            var updatedTrial = trial
            updatedTrial.response = i % 5 != 0 ? trial.figureType.rawValue : "Wrong"
            updatedTrial.isCorrect = i % 5 != 0
            updatedTrial.reactionTime = Double.random(in: 0.5...2.0)
            
            trials.append(updatedTrial)
        }
        
        return trials
    }
    
    private func createLargeMockTrials(count: Int) -> [TrialData] {
        var trials: [TrialData] = []
        
        for i in 0..<count {
            let trial = TrialData(
                trialNumber: i + 1,
                figureType: FigureType.allCases.randomElement()!,
                rotationAngle: Double.random(in: 0...180),
                presentationTime: Date(),
                blockNumber: 1
            )
            
            var updatedTrial = trial
            updatedTrial.response = trial.figureType.rawValue
            updatedTrial.isCorrect = Bool.random()
            updatedTrial.reactionTime = Double.random(in: 0.5...3.0)
            
            trials.append(updatedTrial)
        }
        
        return trials
    }
}
