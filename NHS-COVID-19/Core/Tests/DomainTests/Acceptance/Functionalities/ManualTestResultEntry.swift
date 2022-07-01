//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import TestSupport
@testable import Domain
@testable import Scenarios

struct ManualTestResultEntry {
    private let context: RunningAppContext
    private let apiClient: MockHTTPClient
    private let currentDateProvider: AcceptanceTestMockDateProvider

    init(
        configuration: AcceptanceTestCase.Instance.Configuration,
        context: RunningAppContext
    ) {
        apiClient = configuration.apiClient
        currentDateProvider = configuration.currentDateProvider
        self.context = context
    }

    private let validToken = "f3dzcfdt"

    func enterPositive(requiresConfirmatoryTest: Bool = false, symptomsOnsetDay: GregorianDay? = nil, endDate: Date? = nil, testKitType: VirologyTestResult.TestKitType = .labResult, confirmatoryDayLimit: Int? = nil) throws {
        let testResultAcknowledgementState = try getAcknowledgementState(resultType: .positive, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, confirmatoryDayLimit: confirmatoryDayLimit, endDate: endDate ?? currentDateProvider.currentDate)
        if case .askForSymptomsOnsetDay(_, let didFinishAskForSymptomsOnsetDay, let didConfirmSymptoms, let onsetDay) = testResultAcknowledgementState {
            if let symptomsOnsetDay = symptomsOnsetDay {
                didConfirmSymptoms()
                onsetDay(symptomsOnsetDay)
            }
            didFinishAskForSymptomsOnsetDay()
        }

        let testResultAcknowledgementStateResult = try context.testResultAcknowledgementState.await()

        switch try testResultAcknowledgementStateResult.get() {
        case .neededForPositiveResultNotIsolating(let acknowledge),
             .neededForPositiveResultStartToIsolate(let acknowledge, _),
             .neededForPositiveResultContinueToIsolate(let acknowledge, _, _):
            acknowledge()
        default:
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
    }

    func enterNegative(endDate: Date? = nil) throws {
        let testResultAcknowledgementState = try getAcknowledgementState(resultType: .negative, testKitType: .labResult, requiresConfirmatoryTest: false, endDate: endDate ?? currentDateProvider.currentDate)
        switch testResultAcknowledgementState {
        case .neededForNegativeResultNotIsolating(let acknowledge),
             .neededForNegativeResultContinueToIsolate(let acknowledge, _),
             .neededForNegativeAfterPositiveResultContinueToIsolate(let acknowledge, _):
            acknowledge()
        default:
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
    }

    func enterVoid(endDate: Date? = nil) throws {
        let testResultAcknowledgementState = try getAcknowledgementState(resultType: .void, testKitType: .labResult, requiresConfirmatoryTest: false, endDate: endDate ?? currentDateProvider.currentDate)
        switch testResultAcknowledgementState {
        case .neededForVoidResultNotIsolating(let acknowledge),
             .neededForVoidResultContinueToIsolate(let acknowledge, _):
            acknowledge()
        default:
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
    }

    private func getAcknowledgementState(resultType: VirologyTestResult.TestResult, testKitType: VirologyTestResult.TestKitType, requiresConfirmatoryTest: Bool, confirmatoryDayLimit: Int? = nil, endDate: Date) throws -> TestResultAcknowledgementState {
        let result = getTestResult(result: resultType, testKitType: testKitType, endDate: endDate, diagnosisKeySubmissionSupported: !requiresConfirmatoryTest, requiresConfirmatoryTest: requiresConfirmatoryTest, confirmatoryDayLimit: confirmatoryDayLimit)
        apiClient.response(for: "/virology-test/v2/cta-exchange", response: .success(.ok(with: .json(result))))
        let manager = context.virologyTestingManager
        _ = try manager.linkExternalTestResult(with: validToken).await()

        let testResultAcknowledgementStateResult = try context.testResultAcknowledgementState.await()
        return try testResultAcknowledgementStateResult.get()
    }
}
