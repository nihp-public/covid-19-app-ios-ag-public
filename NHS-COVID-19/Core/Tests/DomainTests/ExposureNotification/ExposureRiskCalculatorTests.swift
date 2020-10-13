//
// Copyright © 2020 NHSX. All rights reserved.
//

import ExposureNotification
import XCTest
@testable import Domain

class ExposureRiskCalculatorTests: XCTestCase {
    
    func testRiskScoreForNoExposures() {
        let riskCalculator = getRiskCalculator()
        let exposure = getExposureInfoWith(attenuationDurations: [0, 0, 0])
        
        let riskInfo = riskCalculator.riskInfo(for: [exposure])
        
        XCTAssertEqual(riskInfo?.riskScore, 0.0)
    }
    
    func testWeightingAppliedToExposure() {
        let riskCalculator = getRiskCalculator()
        let exposure = getExposureInfoWith(attenuationDurations: [300, 300, 300])
        
        let riskInfo = riskCalculator.riskInfo(for: [exposure])
        
        XCTAssertEqual(riskInfo?.riskScore, 450)
    }
    
    func testParameterisedWeightingAppliedToExposures() {
        let riskCalculator = getRiskCalculator()
        let parameterisedTestCases: [([NSNumber], Double?)] = [
            ([1800, 0, 0], 1800.0),
            ([0, 1800, 0], 900.0),
            ([0, 0, 1800], 0.0),
            ([300, 300, 300], 450.0),
            ([0, 300, 300], 150.0),
            ([300, 0, 300], 300.0),
        ]
        
        for (durations, expectedRiskScore) in parameterisedTestCases {
            let exposure = getExposureInfoWith(attenuationDurations: durations)
            let riskInfo = riskCalculator.riskInfo(for: [exposure])
            
            XCTAssertEqual(riskInfo?.riskScore, expectedRiskScore)
        }
    }
    
    func testGreatestRiskScoreAmongstExposuresIsReturned() {
        let riskCalculator = getRiskCalculator()
        let shorterExposure = getExposureInfoWith(attenuationDurations: [300, 0, 0])
        let longerExposure = getExposureInfoWith(attenuationDurations: [900, 0, 0])
        
        let riskInfo = riskCalculator.riskInfo(for: [shorterExposure, longerExposure])
        
        XCTAssertEqual(riskInfo?.riskScore, 900)
    }
    
    func testParameterisedGreatestRiskScoreAmongstExposuresIsReturned() {
        let riskCalculator = getRiskCalculator()
        let shorterExposure = getExposureInfoWith(attenuationDurations: [300, 0, 0])
        let longerExposure = getExposureInfoWith(attenuationDurations: [900, 0, 0])
        
        let parameterisedTestCases = [
            ([longerExposure, shorterExposure], 900.0),
            ([shorterExposure, shorterExposure], 300.0),
            ([longerExposure, longerExposure], 900.0),
        ]
        
        for (exposures, expectedRiskScore) in parameterisedTestCases {
            let riskInfo = riskCalculator.riskInfo(for: exposures)
            
            XCTAssertEqual(riskInfo?.riskScore, expectedRiskScore)
        }
    }
    
    func testAppliesInfectiousnessFactorToRiskScore() {
        let riskCalculator = getRiskCalculator(infectiousnessFactorCalculator: StubInfectiousnessFactorCalculator(factor: 0.5))
        let exposure = getExposureInfoWith(
            attenuationDurations: [300, 300, 300])
        
        let riskInfo = riskCalculator.riskInfo(for: [exposure])
        
        XCTAssertEqual(riskInfo?.riskScore, 225)
    }
    
    func testCallsInfectiousnessFactorWithNumberOfDaysFromOnset() {
        let mockInfectiousnessFactorCalculator = StubInfectiousnessFactorCalculator()
        let riskCalculator = getRiskCalculator(infectiousnessFactorCalculator: mockInfectiousnessFactorCalculator)
        
        let exposure = getExposureInfoWith(attenuationDurations: [300, 300, 300], transmissionRiskLevel: 5)
        
        _ = riskCalculator.riskInfo(for: [exposure])
        
        let expectedDaysFromOnset = 2
        XCTAssertEqual(mockInfectiousnessFactorCalculator.infectiousnessFactorCalledWith, expectedDaysFromOnset)
    }
    
    func getRiskCalculator(infectiousnessFactorCalculator: InfectiousnessFactorCalculating = StubInfectiousnessFactorCalculator()) -> ExposureRiskCalculator {
        let configuration = ExposureDetectionConfiguration(
            transmitionWeight: 0,
            durationWeight: 0,
            attenuationWeight: 0,
            daysWeight: 0,
            transmition: [],
            duration: [],
            daysSinceLastExposure: [],
            attenuation: [],
            thresholds: [],
            durationBucketWeights: [1.0, 0.5, 0],
            riskThreshold: 5
        )
        
        return ExposureRiskCalculator(configuration: configuration, infectiousnessFactorCalculator: infectiousnessFactorCalculator)
    }
    
    func getExposureInfoWith(attenuationDurations: [NSNumber], transmissionRiskLevel: Int = 7) -> MockENExposureInfo {
        let exposure = MockENExposureInfo(attenuationDurations: attenuationDurations, date: Date(), totalRiskScore: 0, transmissionRiskLevel: ENRiskLevel(transmissionRiskLevel))
        
        return exposure
    }
}

private class StubInfectiousnessFactorCalculator: InfectiousnessFactorCalculating {
    let factor: Double
    var infectiousnessFactorCalledWith: Int?
    
    init(factor: Double = 1.0) {
        self.factor = factor
    }
    
    func infectiousnessFactor(for daysFromOnset: Int) -> Double {
        infectiousnessFactorCalledWith = daysFromOnset
        return factor
    }
}
