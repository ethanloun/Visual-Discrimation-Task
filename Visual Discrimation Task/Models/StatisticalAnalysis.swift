//
//  StatisticalAnalysis.swift
//  Visual Discrimation Task
//
//  Created by Ethan on 9/18/25.
//

import Foundation

// MARK: - Statistical Analysis Engine
class StatisticalAnalysis {
    
    // MARK: - Basic Statistics
    static func calculateBasicStatistics(for trials: [TrialData]) -> BasicStatistics {
        let completedTrials = trials.filter { $0.isCorrect != nil && $0.reactionTime != nil }
        
        guard !completedTrials.isEmpty else {
            return BasicStatistics(
                totalTrials: trials.count,
                completedTrials: 0,
                accuracy: 0.0,
                meanReactionTime: 0.0,
                medianReactionTime: 0.0,
                standardDeviation: 0.0,
                minReactionTime: 0.0,
                maxReactionTime: 0.0
            )
        }
        
        let correctTrials = completedTrials.filter { $0.isCorrect == true }
        let accuracy = Double(correctTrials.count) / Double(completedTrials.count)
        
        let reactionTimes = completedTrials.compactMap { $0.reactionTime }
        let meanReactionTime = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
        let medianReactionTime = calculateMedian(reactionTimes)
        let standardDeviation = calculateStandardDeviation(reactionTimes, mean: meanReactionTime)
        let minReactionTime = reactionTimes.min() ?? 0.0
        let maxReactionTime = reactionTimes.max() ?? 0.0
        
        return BasicStatistics(
            totalTrials: trials.count,
            completedTrials: completedTrials.count,
            accuracy: accuracy,
            meanReactionTime: meanReactionTime,
            medianReactionTime: medianReactionTime,
            standardDeviation: standardDeviation,
            minReactionTime: minReactionTime,
            maxReactionTime: maxReactionTime
        )
    }
    
    // MARK: - Rotation Angle Analysis
    static func analyzeByRotationAngle(for trials: [TrialData]) -> [RotationAnalysis] {
        let completedTrials = trials.filter { $0.isCorrect != nil && $0.reactionTime != nil }
        let groupedByAngle = Dictionary(grouping: completedTrials) { $0.rotationAngle }
        
        return groupedByAngle.map { (angle, trials) in
            let correctCount = trials.filter { $0.isCorrect == true }.count
            let accuracy = Double(correctCount) / Double(trials.count)
            
            let reactionTimes = trials.compactMap { $0.reactionTime }
            let meanReactionTime = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
            let medianReactionTime = calculateMedian(reactionTimes)
            let standardDeviation = calculateStandardDeviation(reactionTimes, mean: meanReactionTime)
            
            return RotationAnalysis(
                angle: angle,
                trialCount: trials.count,
                accuracy: accuracy,
                meanReactionTime: meanReactionTime,
                medianReactionTime: medianReactionTime,
                standardDeviation: standardDeviation
            )
        }.sorted { $0.angle < $1.angle }
    }
    
    // MARK: - Figure Type Analysis
    static func analyzeByFigureType(for trials: [TrialData]) -> [FigureTypeAnalysis] {
        let completedTrials = trials.filter { $0.isCorrect != nil && $0.reactionTime != nil }
        let groupedByType = Dictionary(grouping: completedTrials) { $0.figureType }
        
        return groupedByType.map { (figureType, trials) in
            let correctCount = trials.filter { $0.isCorrect == true }.count
            let accuracy = Double(correctCount) / Double(trials.count)
            
            let reactionTimes = trials.compactMap { $0.reactionTime }
            let meanReactionTime = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
            let medianReactionTime = calculateMedian(reactionTimes)
            let standardDeviation = calculateStandardDeviation(reactionTimes, mean: meanReactionTime)
            
            return FigureTypeAnalysis(
                figureType: figureType,
                trialCount: trials.count,
                accuracy: accuracy,
                meanReactionTime: meanReactionTime,
                medianReactionTime: medianReactionTime,
                standardDeviation: standardDeviation
            )
        }
    }
    
    // MARK: - Correlation Analysis
    static func calculateCorrelation(angles: [Double], reactionTimes: [Double]) -> Double {
        guard angles.count == reactionTimes.count && angles.count > 1 else { return 0.0 }
        
        let n = Double(angles.count)
        let sumX = angles.reduce(0, +)
        let sumY = reactionTimes.reduce(0, +)
        let sumXY = zip(angles, reactionTimes).map(*).reduce(0, +)
        let sumX2 = angles.map { $0 * $0 }.reduce(0, +)
        let sumY2 = reactionTimes.map { $0 * $0 }.reduce(0, +)
        
        let numerator = n * sumXY - sumX * sumY
        let denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))
        
        return denominator != 0 ? numerator / denominator : 0.0
    }
    
    // MARK: - Learning Curve Analysis
    static func analyzeLearningCurve(for trials: [TrialData], windowSize: Int = 10) -> [LearningCurvePoint] {
        let completedTrials = trials.filter { $0.isCorrect != nil && $0.reactionTime != nil }
        guard completedTrials.count >= windowSize else { return [] }
        
        var learningCurve: [LearningCurvePoint] = []
        
        for i in stride(from: windowSize - 1, to: completedTrials.count, by: windowSize) {
            let windowTrials = Array(completedTrials[max(0, i - windowSize + 1)...i])
            let correctCount = windowTrials.filter { $0.isCorrect == true }.count
            let accuracy = Double(correctCount) / Double(windowTrials.count)
            
            let reactionTimes = windowTrials.compactMap { $0.reactionTime }
            let meanReactionTime = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
            
            learningCurve.append(LearningCurvePoint(
                trialWindow: i + 1,
                accuracy: accuracy,
                meanReactionTime: meanReactionTime
            ))
        }
        
        return learningCurve
    }
    
    // MARK: - Helper Functions
    private static func calculateMedian(_ values: [Double]) -> Double {
        let sortedValues = values.sorted()
        let count = sortedValues.count
        
        if count % 2 == 0 {
            return (sortedValues[count / 2 - 1] + sortedValues[count / 2]) / 2.0
        } else {
            return sortedValues[count / 2]
        }
    }
    
    private static func calculateStandardDeviation(_ values: [Double], mean: Double) -> Double {
        guard values.count > 1 else { return 0.0 }
        
        let squaredDifferences = values.map { pow($0 - mean, 2) }
        let variance = squaredDifferences.reduce(0, +) / Double(values.count - 1)
        return sqrt(variance)
    }
}

// MARK: - Data Structures
struct BasicStatistics {
    let totalTrials: Int
    let completedTrials: Int
    let accuracy: Double
    let meanReactionTime: Double
    let medianReactionTime: Double
    let standardDeviation: Double
    let minReactionTime: Double
    let maxReactionTime: Double
}

struct RotationAnalysis {
    let angle: Double
    let trialCount: Int
    let accuracy: Double
    let meanReactionTime: Double
    let medianReactionTime: Double
    let standardDeviation: Double
}

struct FigureTypeAnalysis {
    let figureType: FigureType
    let trialCount: Int
    let accuracy: Double
    let meanReactionTime: Double
    let medianReactionTime: Double
    let standardDeviation: Double
}

struct LearningCurvePoint {
    let trialWindow: Int
    let accuracy: Double
    let meanReactionTime: Double
}

// MARK: - Signal Detection Theory (SDT)
extension StatisticalAnalysis {
    struct SDTResult {
        let hitRate: Double
        let falseAlarmRate: Double
        let dPrime: Double
        let criterion: Double
    }
    
    // Calculates SDT metrics given boolean arrays for signal trials and responses
    static func computeSDT(signalIsPresent: [Bool], respondedYes: [Bool]) -> SDTResult {
        let n = min(signalIsPresent.count, respondedYes.count)
        guard n > 0 else { return SDTResult(hitRate: 0, falseAlarmRate: 0, dPrime: 0, criterion: 0) }
        
        var hits = 0, misses = 0, falseAlarms = 0, correctRejects = 0
        for i in 0..<n {
            if signalIsPresent[i] {
                if respondedYes[i] { hits += 1 } else { misses += 1 }
            } else {
                if respondedYes[i] { falseAlarms += 1 } else { correctRejects += 1 }
            }
        }
        // Apply log-linear correction to avoid 0 or 1 rates
        let hitRate = (Double(hits) + 0.5) / (Double(hits + misses) + 1.0)
        let faRate = (Double(falseAlarms) + 0.5) / (Double(falseAlarms + correctRejects) + 1.0)
        
        let zHit = inverseNormalCDF(hitRate)
        let zFA = inverseNormalCDF(faRate)
        let dPrime = zHit - zFA
        let c = -0.5 * (zHit + zFA)
        
        return SDTResult(hitRate: hitRate, falseAlarmRate: faRate, dPrime: dPrime, criterion: c)
    }
    
    // Approximate inverse CDF for standard normal distribution (Acklam's method simplified)
    private static func inverseNormalCDF(_ p: Double) -> Double {
        // Clamp probabilities
        let pp = max(min(p, 1 - 1e-10), 1e-10)
        // Coefficients
        let a: [Double] = [-3.969683028665376e+01, 2.209460984245205e+02, -2.759285104469687e+02, 1.383577518672690e+02, -3.066479806614716e+01, 2.506628277459239e+00]
        let b: [Double] = [-5.447609879822406e+01, 1.615858368580409e+02, -1.556989798598866e+02, 6.680131188771972e+01, -1.328068155288572e+01]
        let c: [Double] = [-7.784894002430293e-03, -3.223964580411365e-01, -2.400758277161838e+00, -2.549732539343734e+00, 4.374664141464968e+00, 2.938163982698783e+00]
        let d: [Double] = [7.784695709041462e-03, 3.224671290700398e-01, 2.445134137142996e+00, 3.754408661907416e+00]
        let plow = 0.02425
        let phigh = 1 - plow
        var x: Double
        if pp < plow {
            let q = sqrt(-2 * log(pp))
            x = (((((c[0] * q + c[1]) * q + c[2]) * q + c[3]) * q + c[4]) * q + c[5]) /
                ((((d[0] * q + d[1]) * q + d[2]) * q + d[3]) * q + 1)
        } else if pp > phigh {
            let q = sqrt(-2 * log(1 - pp))
            x = -(((((c[0] * q + c[1]) * q + c[2]) * q + c[3]) * q + c[4]) * q + c[5]) /
                ((((d[0] * q + d[1]) * q + d[2]) * q + d[3]) * q + 1)
        } else {
            let q = pp - 0.5
            let r = q * q
            x = (((((a[0] * r + a[1]) * r + a[2]) * r + a[3]) * r + a[4]) * r + a[5]) * q /
                (((((b[0] * r + b[1]) * r + b[2]) * r + b[3]) * r + b[4]) * r + 1)
        }
        return x
    }
}

// MARK: - Statistical Tests
extension StatisticalAnalysis {
    
    // Simple t-test for comparing two groups
    static func tTest(group1: [Double], group2: [Double]) -> TTestResult {
        guard group1.count > 1 && group2.count > 1 else {
            return TTestResult(tStatistic: 0, pValue: 1.0, degreesOfFreedom: 0)
        }
        
        let mean1 = group1.reduce(0, +) / Double(group1.count)
        let mean2 = group2.reduce(0, +) / Double(group2.count)
        
        let var1 = calculateVariance(group1, mean: mean1)
        let var2 = calculateVariance(group2, mean: mean2)
        
        let pooledVariance = ((Double(group1.count - 1) * var1) + (Double(group2.count - 1) * var2)) / Double(group1.count + group2.count - 2)
        let standardError = sqrt(pooledVariance * (1.0/Double(group1.count) + 1.0/Double(group2.count)))
        
        let tStatistic = (mean1 - mean2) / standardError
        let degreesOfFreedom = group1.count + group2.count - 2
        
        // Simplified p-value calculation (would need more sophisticated implementation for production)
        let pValue = abs(tStatistic) > 2.0 ? 0.05 : 0.5
        
        return TTestResult(tStatistic: tStatistic, pValue: pValue, degreesOfFreedom: degreesOfFreedom)
    }
    
    // ANOVA for comparing multiple groups
    static func oneWayANOVA(groups: [[Double]]) -> ANOVAResult {
        guard groups.count > 1 else {
            return ANOVAResult(fStatistic: 0, pValue: 1.0, degreesOfFreedomBetween: 0, degreesOfFreedomWithin: 0)
        }
        
        let allValues = groups.flatMap { $0 }
        let grandMean = allValues.reduce(0, +) / Double(allValues.count)
        
        // Calculate between-group sum of squares
        var betweenSS = 0.0
        for group in groups {
            let groupMean = group.reduce(0, +) / Double(group.count)
            betweenSS += Double(group.count) * pow(groupMean - grandMean, 2)
        }
        
        // Calculate within-group sum of squares
        var withinSS = 0.0
        for group in groups {
            let groupMean = group.reduce(0, +) / Double(group.count)
            for value in group {
                withinSS += pow(value - groupMean, 2)
            }
        }
        
        let dfBetween = groups.count - 1
        let dfWithin = allValues.count - groups.count
        
        let msBetween = betweenSS / Double(dfBetween)
        let msWithin = withinSS / Double(dfWithin)
        
        let fStatistic = msBetween / msWithin
        
        // Simplified p-value calculation
        let pValue = fStatistic > 3.0 ? 0.05 : 0.5
        
        return ANOVAResult(
            fStatistic: fStatistic,
            pValue: pValue,
            degreesOfFreedomBetween: dfBetween,
            degreesOfFreedomWithin: dfWithin
        )
    }
    
    // Linear regression analysis
    static func linearRegression(x: [Double], y: [Double]) -> RegressionResult {
        guard x.count == y.count && x.count > 1 else {
            return RegressionResult(slope: 0, intercept: 0, rSquared: 0, pValue: 1.0)
        }
        
        let n = Double(x.count)
        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).map(*).reduce(0, +)
        let sumX2 = x.map { $0 * $0 }.reduce(0, +)
        let sumY2 = y.map { $0 * $0 }.reduce(0, +)
        
        let slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
        let intercept = (sumY - slope * sumX) / n
        
        // Calculate R-squared
        let yMean = sumY / n
        let ssTotal = y.map { pow($0 - yMean, 2) }.reduce(0, +)
        let ssResidual = zip(x, y).map { pow($1 - (slope * $0 + intercept), 2) }.reduce(0, +)
        let rSquared = 1 - (ssResidual / ssTotal)
        
        // Simplified p-value calculation
        let pValue = abs(slope) > 0.1 ? 0.05 : 0.5
        
        return RegressionResult(slope: slope, intercept: intercept, rSquared: rSquared, pValue: pValue)
    }
    
    // Effect size calculation (Cohen's d)
    static func cohensD(group1: [Double], group2: [Double]) -> Double {
        guard group1.count > 1 && group2.count > 1 else { return 0.0 }
        
        let mean1 = group1.reduce(0, +) / Double(group1.count)
        let mean2 = group2.reduce(0, +) / Double(group2.count)
        
        let var1 = calculateVariance(group1, mean: mean1)
        let var2 = calculateVariance(group2, mean: mean2)
        
        let pooledStdDev = sqrt(((Double(group1.count - 1) * var1) + (Double(group2.count - 1) * var2)) / Double(group1.count + group2.count - 2))
        
        return (mean1 - mean2) / pooledStdDev
    }
    
    // Statistical power analysis
    static func calculatePower(effectSize: Double, sampleSize: Int, alpha: Double = 0.05) -> Double {
        // Simplified power calculation
        let ncp = effectSize * sqrt(Double(sampleSize))
        let criticalValue = 1.96 // For alpha = 0.05, two-tailed
        let power = 1 - normalCDF(criticalValue - ncp)
        return max(0, min(1, power))
    }
    
    // Sample size calculation for desired power
    static func calculateSampleSize(effectSize: Double, desiredPower: Double = 0.8, alpha: Double = 0.05) -> Int {
        let zAlpha = 1.96 // For alpha = 0.05, two-tailed
        let zBeta = normalQuantile(desiredPower)
        let n = pow((zAlpha + zBeta) / effectSize, 2)
        return Int(ceil(n))
    }
    
    private static func calculateVariance(_ values: [Double], mean: Double) -> Double {
        guard values.count > 1 else { return 0.0 }
        let squaredDifferences = values.map { pow($0 - mean, 2) }
        return squaredDifferences.reduce(0, +) / Double(values.count - 1)
    }
    
    // Approximate normal CDF
    private static func normalCDF(_ x: Double) -> Double {
        return 0.5 * (1 + erf(x / sqrt(2)))
    }
    
    // Approximate normal quantile function
    private static func normalQuantile(_ p: Double) -> Double {
        return sqrt(2) * erfinv(2 * p - 1)
    }
    
    // Approximate inverse error function
    private static func erfinv(_ x: Double) -> Double {
        let a: [Double] = [0.886226899, -1.645349621, 0.914624893, -0.140543331]
        let b: [Double] = [1.0, -2.118377725, 1.442710462, -0.329097515, 0.012229801]
        let c: [Double] = [-1.970840454, -1.624906493, 3.429567803, 1.641345311]
        let d: [Double] = [1.0, 3.543889200, 1.637067800]
        
        if abs(x) <= 0.7 {
            let x2 = x * x
            let numerator = a[0] + a[1] * x2 + a[2] * x2 * x2 + a[3] * x2 * x2 * x2
            let denominator = b[0] + b[1] * x2 + b[2] * x2 * x2 + b[3] * x2 * x2 * x2 + b[4] * x2 * x2 * x2 * x2
            return x * numerator / denominator
        } else {
            let sign = x >= 0 ? 1.0 : -1.0
            let x = abs(x)
            let numerator = c[0] + c[1] * x + c[2] * x * x + c[3] * x * x * x
            let denominator = d[0] + d[1] * x + d[2] * x * x
            return sign * numerator / denominator
        }
    }
}

struct TTestResult {
    let tStatistic: Double
    let pValue: Double
    let degreesOfFreedom: Int
}

struct ANOVAResult {
    let fStatistic: Double
    let pValue: Double
    let degreesOfFreedomBetween: Int
    let degreesOfFreedomWithin: Int
}

struct RegressionResult {
    let slope: Double
    let intercept: Double
    let rSquared: Double
    let pValue: Double
}
