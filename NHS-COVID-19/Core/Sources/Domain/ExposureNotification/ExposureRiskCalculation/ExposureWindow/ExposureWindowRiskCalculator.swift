//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import RiskScore

@available(iOS 13.7, *)
class ExposureWindowRiskCalculator {
    private static let riskScoreVersion = 2
    private let infectiousnessFactorCalculator: ExposureWindowInfectiousnessFactorCalculator
    private let dateProvider: DateProviding
    private let isolationLength: DayDuration
    private let nonRiskyWindowSelector: NonRiskyWindowSelecting
    private let submitExposureWindows: ([(ExposureNotificationExposureWindow, ExposureRiskInfo)]) -> Void
    
    init(
        infectiousnessFactorCalculator: ExposureWindowInfectiousnessFactorCalculator = ExposureWindowInfectiousnessFactorCalculator(),
        dateProvider: DateProviding,
        isolationLength: DayDuration,
        nonRiskyWindowSelector: NonRiskyWindowSelecting = NonRiskyWindowSelector(),
        submitExposureWindows: @escaping ([(ExposureNotificationExposureWindow, ExposureRiskInfo)]) -> Void
    ) {
        self.infectiousnessFactorCalculator = infectiousnessFactorCalculator
        self.dateProvider = dateProvider
        self.isolationLength = isolationLength
        self.nonRiskyWindowSelector = nonRiskyWindowSelector
        self.submitExposureWindows = submitExposureWindows
    }
    
    func riskInfo(
        for exposureWindows: [ExposureNotificationExposureWindow],
        configuration: ExposureDetectionConfiguration,
        riskScoreCalculator: ExposureWindowRiskScoreCalculator
    ) -> ExposureRiskInfo? {
        var windows = [(ExposureNotificationExposureWindow, ExposureRiskInfo)]()
        
        let shouldIncludeNonRiskyWindows = nonRiskyWindowSelector.allow
        
        let maxRiskInfo = exposureWindows.compactMap { exposureWindow in
            // We've seen in our field test data that on rare occasion we get a ScanInstance with a secondsSinceLastScan of 0
            // This is invalid input for `RiskScoreCalculator` so we filter out these `ScanInstance`s
            let scanInstances = exposureWindow.enScanInstances
                .filter { $0.secondsSinceLastScan > 0 }
                .map(ScanInstance.init(from:))
            
            // An empty list is also invalid input
            guard !scanInstances.isEmpty else {
                return nil
            }
            
            let riskScore = riskScoreCalculator.calculate(instances: scanInstances) * 60
            let infectiousnessFactor = infectiousnessFactorCalculator.infectiousnessFactor(for: exposureWindow.infectiousness, config: configuration)
            let riskInfo = ExposureRiskInfo(
                riskScore: riskScore * infectiousnessFactor,
                riskScoreVersion: Self.riskScoreVersion,
                day: GregorianDay(date: exposureWindow.date, timeZone: .utc),
                riskThreshold: configuration.v2RiskThreshold
            )
            
            if riskInfo.isConsideredRisky, isRecentDate(exposureRiskInfo: riskInfo) {
                windows.append((exposureWindow, riskInfo))
                Metrics.signpost(.totalExposureWindowsConsideredRisky)
            } else {
                if shouldIncludeNonRiskyWindows {
                    windows.append((exposureWindow, riskInfo))
                }
                Metrics.signpost(.totalExposureWindowsNotConsideredRisky)
            }
            
            return riskInfo
        }
        .filter { isRecentDate(exposureRiskInfo: $0) }
        .max { $1.isHigherPriority(than: $0) }
        
        submitExposureWindows(windows)
        return maxRiskInfo
    }
    
    private func isRecentDate(exposureRiskInfo: ExposureRiskInfo) -> Bool {
        let today = dateProvider.currentGregorianDay(timeZone: .current)
        return today - isolationLength < exposureRiskInfo.day
    }
}
