//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import ExposureNotification
import RiskScore
import Scenarios
import XCTest
@testable import Domain

@available(iOS 13.7, *)
class ExposureWindowRiskCalculatorTests: XCTestCase {
    private var riskScoreCalculator: MockRiskScoreCalculator!
    private var riskCalculator: ExposureWindowRiskCalculator!
    private var infectiousnessFactorCalculator: MockExposureWindowInfectiousnessFactorCalculator!
    private var dateProvider: DateProviding = MockDateProvider()

    override func setUp() {
        riskScoreCalculator = MockRiskScoreCalculator()
        infectiousnessFactorCalculator = MockExposureWindowInfectiousnessFactorCalculator()
        riskCalculator = ExposureWindowRiskCalculator(
            infectiousnessFactorCalculator: infectiousnessFactorCalculator,
            dateProvider: dateProvider,
            isolationLength: DayDuration(10),
            submitExposureWindows: { _ in }
        )
    }

    func testPassesScanInstancesToRiskScorer() {
        let expectedAttenuation = UInt8(45)
        let expectedSecondsSinceLastScan = 180
        let expectedScanInstances = [ScanInstance(attenuationValue: expectedAttenuation, secondsSinceLastScan: expectedSecondsSinceLastScan)]
        let scanInstances: [ExposureNotificationScanInstance] = [MockScanInstance(minimumAttenuation: expectedAttenuation, secondsSinceLastScan: expectedSecondsSinceLastScan, typicalAttenuation: 1)]
        let exposureWindows: [ExposureNotificationExposureWindow] = [MockExposureWindow(enScanInstances: scanInstances, date: Date(), infectiousness: .standard)]

        _ = riskCalculator.riskInfo(
            for: exposureWindows,
            configuration: .dummyForTesting,
            riskScoreCalculator: riskScoreCalculator
        )

        XCTAssertEqual(riskScoreCalculator.calledWithScanInstances, expectedScanInstances)
    }

    func testFiltersOutScanInstanceWithZeroSecondsSinceLastScan() {
        let expectedAttenuation = UInt8(50)
        let expectedSecondsSinceLastScan = 180
        let scanInstances: [ExposureNotificationScanInstance] = [
            MockScanInstance(minimumAttenuation: 45, secondsSinceLastScan: 0, typicalAttenuation: 1),
            MockScanInstance(minimumAttenuation: expectedAttenuation, secondsSinceLastScan: expectedSecondsSinceLastScan, typicalAttenuation: 1),
        ]
        let exposureWindows: [ExposureNotificationExposureWindow] = [MockExposureWindow(enScanInstances: scanInstances, date: Date(), infectiousness: .standard)]

        _ = riskCalculator.riskInfo(
            for: exposureWindows,
            configuration: .dummyForTesting,
            riskScoreCalculator: riskScoreCalculator
        )

        let expectedScanInstances = [ScanInstance(attenuationValue: expectedAttenuation, secondsSinceLastScan: expectedSecondsSinceLastScan)]
        XCTAssertEqual(riskScoreCalculator.calledWithScanInstances, expectedScanInstances)
    }

    func testDoesNotCallRiskScoreWithNoScanInstances() {
        let exposureWindows: [ExposureNotificationExposureWindow] = [MockExposureWindow(enScanInstances: [], date: Date(), infectiousness: .standard)]

        _ = riskCalculator.riskInfo(
            for: exposureWindows,
            configuration: .dummyForTesting,
            riskScoreCalculator: riskScoreCalculator
        )

        XCTAssertNil(riskScoreCalculator.calledWithScanInstances)
    }

    func testRiskCalculatorReturnsExposureRiskInfo() {
        let expectedRiskScore = 22.0
        let expectedExposureRiskInfo = ExposureRiskInfo(riskScore: expectedRiskScore * 60, riskScoreVersion: 1, day: .today, isConsideredRisky: true)
        let exposureWindows: [ExposureNotificationExposureWindow] = [MockExposureWindow(enScanInstances: [MockScanInstance.dummyValue], date: Date(), infectiousness: .standard)]
        riskScoreCalculator.riskScore = expectedRiskScore

        let exposureRiskInfo = riskCalculator.riskInfo(
            for: exposureWindows,
            configuration: .dummyForTesting,
            riskScoreCalculator: riskScoreCalculator
        )

        XCTAssertEqual(exposureRiskInfo, expectedExposureRiskInfo)
    }

    func testRiskCalculatorReturnsMostRecentHighRiskExposure() {
        let newerDate = dateProvider.currentDate.advanced(by: 5 * 24 * 60 * 60)
        let olderDate = dateProvider.currentDate
        let expectedRiskScore = 22.0
        let expectedExposureRiskInfo = ExposureRiskInfo(
            riskScore: expectedRiskScore * 60,
            riskScoreVersion: 1,
            day: GregorianDay(date: newerDate, timeZone: .utc),
            isConsideredRisky: true
        )
        let exposureWindows: [ExposureNotificationExposureWindow] = [
            MockExposureWindow(enScanInstances: [MockScanInstance.dummyValue], date: olderDate, infectiousness: .standard),
            MockExposureWindow(enScanInstances: [MockScanInstance.dummyValue], date: newerDate, infectiousness: .standard),
        ]
        riskScoreCalculator.riskScore = expectedRiskScore

        let exposureRiskInfo = riskCalculator.riskInfo(
            for: exposureWindows,
            configuration: .dummyForTesting,
            riskScoreCalculator: riskScoreCalculator
        )

        XCTAssertEqual(exposureRiskInfo, expectedExposureRiskInfo)
    }

    func testInfectiousFactorIsApplied() {
        infectiousnessFactorCalculator.infectiousnessFactor = 0.4
        let expectedRiskScore = 40.0 * 60
        riskScoreCalculator.riskScore = 100.0

        let exposureRiskInfo = riskCalculator.riskInfo(
            for: [MockExposureWindow(enScanInstances: [MockScanInstance.dummyValue], date: Date(), infectiousness: .standard)],
            configuration: .dummyForTesting,
            riskScoreCalculator: riskScoreCalculator
        )

        XCTAssertEqual(exposureRiskInfo?.riskScore, expectedRiskScore)
    }

    func testKeysOlderThanTheIsolationPeriodAreFilteredOut() {
        riskScoreCalculator.riskScore = 100.0
        let calendar = Calendar.utc
        let oldDate = calendar.date(from: DateComponents(year: 2020, month: 7, day: 9))
        dateProvider = MockDateProvider { Date.dateFrom(year: 2020, month: 7, day: 20) }

        var submittedWindows = [(ExposureNotificationExposureWindow, ExposureRiskInfo)]()
        let riskCalculator = ExposureWindowRiskCalculator(
            infectiousnessFactorCalculator: MockExposureWindowInfectiousnessFactorCalculator(),
            dateProvider: dateProvider,
            isolationLength: DayDuration(10),
            submitExposureWindows: { windowInfo in submittedWindows.append(contentsOf: windowInfo) }
        )

        let exposureRiskInfo = riskCalculator.riskInfo(
            for: [MockExposureWindow(enScanInstances: [], date: oldDate!, infectiousness: .high)],
            configuration: .dummyForTesting,
            riskScoreCalculator: riskScoreCalculator
        )

        XCTAssertNil(exposureRiskInfo)
        XCTAssertTrue(submittedWindows.isEmpty)
    }

    func testReturnsMostRecentRiskyExposureInfoAndSubmitRiskyWindows() {
        class StubRiskScoreCalculator: ExposureWindowRiskScoreCalculator {
            var answers = [10.0, 9.0, 1.0]

            func calculate(instances: [ScanInstance]) -> Double {
                return answers.removeFirst()
            }
        }

        let riskyScore = 540.0
        let (olderDate, newerDate, newestDate) = getThreeConsecutiveDates()
        let dateProvider = MockDateProvider { Date.dateFrom(year: 2020, month: 7, day: 4) }

        let expectedRiskInfo = ExposureRiskInfo(
            riskScore: riskyScore,
            riskScoreVersion: 2,
            day: GregorianDay(date: newerDate, timeZone: .utc),
            isConsideredRisky: true
        )
        var config = ExposureDetectionConfiguration.dummyForTesting
        config.v2RiskThreshold = 100.0

        var submittedWindows = [(ExposureNotificationExposureWindow, ExposureRiskInfo)]()
        let riskCalc = ExposureWindowRiskCalculator(
            infectiousnessFactorCalculator: MockExposureWindowInfectiousnessFactorCalculator(),
            dateProvider: dateProvider,
            isolationLength: DayDuration(10),
            nonRiskyWindowSelector: MockNonRiskyWindowSelector(allow: false),
            submitExposureWindows: { windowInfo in submittedWindows.append(contentsOf: windowInfo) }
        )

        let riskInfo = riskCalc.riskInfo(for: getWindowsForDates(dates: [olderDate, newerDate, newestDate]), configuration: config, riskScoreCalculator: StubRiskScoreCalculator())

        XCTAssertEqual(riskInfo, expectedRiskInfo)
        XCTAssertEqual(submittedWindows.count, 2)
    }

    func testReturnsMostRecentRiskyExposureInfoAndSubmitAllWindows() {
        class StubRiskScoreCalculator: ExposureWindowRiskScoreCalculator {
            var answers = [10.0, 9.0, 1.0]

            func calculate(instances: [ScanInstance]) -> Double {
                return answers.removeFirst()
            }
        }

        let riskyScore = 540.0
        let (olderDate, newerDate, newestDate) = getThreeConsecutiveDates()
        let dateProvider = MockDateProvider { Date.dateFrom(year: 2020, month: 7, day: 4) }

        let expectedRiskInfo = ExposureRiskInfo(
            riskScore: riskyScore,
            riskScoreVersion: 2,
            day: GregorianDay(date: newerDate, timeZone: .utc),
            isConsideredRisky: true
        )
        var config = ExposureDetectionConfiguration.dummyForTesting
        config.v2RiskThreshold = 100.0

        var submittedWindows = [(ExposureNotificationExposureWindow, ExposureRiskInfo)]()
        let riskCalc = ExposureWindowRiskCalculator(
            infectiousnessFactorCalculator: MockExposureWindowInfectiousnessFactorCalculator(),
            dateProvider: dateProvider,
            isolationLength: DayDuration(10),
            nonRiskyWindowSelector: MockNonRiskyWindowSelector(allow: true),
            submitExposureWindows: { windowInfo in submittedWindows.append(contentsOf: windowInfo) }
        )

        let riskInfo = riskCalc.riskInfo(for: getWindowsForDates(dates: [olderDate, newerDate, newestDate]), configuration: config, riskScoreCalculator: StubRiskScoreCalculator())

        XCTAssertEqual(riskInfo, expectedRiskInfo)
        XCTAssertEqual(submittedWindows.count, 3)
    }

    private func getThreeConsecutiveDates() -> (Date, Date, Date) {
        let calendar = Calendar.utc
        let olderDate = calendar.date(from: DateComponents(year: 2020, month: 7, day: 1))!
        let newerDate = calendar.date(from: DateComponents(year: 2020, month: 7, day: 2))!
        let newestDate = calendar.date(from: DateComponents(year: 2020, month: 7, day: 3))!

        return (olderDate, newerDate, newestDate)
    }

    private func getWindowsForDates(dates: [Date]) -> [MockExposureWindow] {
        return dates.map { MockExposureWindow(enScanInstances: [MockScanInstance.dummyValue], date: $0, infectiousness: .high) }
    }
}

class MockRiskScoreCalculator: ExposureWindowRiskScoreCalculator {
    var calledWithScanInstances: [ScanInstance]?
    var riskScore: Double = 0.0

    func calculate(instances: [ScanInstance]) -> Double {
        calledWithScanInstances = instances
        return riskScore
    }
}

@available(iOS 13.7, *)
class MockExposureWindowInfectiousnessFactorCalculator: ExposureWindowInfectiousnessFactorCalculator {
    var infectiousnessFactor = 1.0

    override func infectiousnessFactor(for infectiousness: ENInfectiousness, config: ExposureDetectionConfiguration) -> Double {
        return infectiousnessFactor
    }
}

@available(iOS 13.7, *)
struct MockExposureWindow: ExposureNotificationExposureWindow {
    var enScanInstances: [ExposureNotificationScanInstance]
    var date: Date
    var infectiousness: ENInfectiousness
}

@available(iOS 13.7, *)
struct MockScanInstance: ExposureNotificationScanInstance {
    let minimumAttenuation: ENAttenuation
    let secondsSinceLastScan: Int
    let typicalAttenuation: ENAttenuation

    static let dummyValue = MockScanInstance(minimumAttenuation: 50, secondsSinceLastScan: 180, typicalAttenuation: 49)
}

extension Date {
    static func dateFrom(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents(year: year, month: month, day: day)
        components.calendar = .current
        return components.date!
    }
}

private struct MockNonRiskyWindowSelector: NonRiskyWindowSelecting {
    var allow: Bool
}
