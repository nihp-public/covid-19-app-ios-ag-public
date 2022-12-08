//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

private struct VirologyTokensInfo: Codable, Equatable {
    var pollingToken: String
    var creationDay: GregorianDay?
    var diagnosisKeySubmissionToken: String
}

#warning("Extract these types")
// Currently we have decoding interleaved with actual logic. Would be good to separate these, following the pattern from
// `IsolationStatePayload`.
private struct VirologyTestingInfo: Codable, DataConvertible {
    var tokensInfo: [VirologyTokensInfo]?
    var latestUnacknowledgedTestResult: TestResultInfo?
    var unacknowledgedTestResults: [TestResultInfo]?
}

private struct UnknownTestResultInfo: Codable, DataConvertible {
    // currently empty; we intentionally don't store anything about the unknown test result, only that we got one
}

private struct TestResultInfo: Codable, DataConvertible {

    enum TestResult: String, Codable, Equatable {
        case positive
        case plod
        case negative
        case void

        init(_ virologyTestResult: VirologyTestResult.TestResult) {
            switch virologyTestResult {
            case .positive:
                self = .positive
            case .plod:
                self = .plod
            case .negative:
                self = .negative
            case .void:
                self = .void
            }
        }

    }

    enum TestKitType: String, Codable {
        case labResult
        case rapidResult
        case rapidSelfReported

        init?(_ result: Domain.TestKitType?) {
            guard let result = result else { return nil }
            switch result {
            case .labResult:
                self = .labResult
            case .rapidResult:
                self = .rapidResult
            case .rapidSelfReported:
                self = .rapidSelfReported
            }
        }
    }

    var result: TestResult
    var testKitType: TestKitType?
    var endDate: Date // Date test result arrives at NPEx
    var diagnosisKeySubmissionToken: String?
    var requiresConfirmatoryTest: Bool
    var shouldOfferFollowUpTest: Bool?
    var confirmatoryDayLimit: Int?
}

public class VirologyTestingStateStore {

    @PublishedEncrypted private var virologyTestingInfo: VirologyTestingInfo?
    @PublishedEncrypted private var recievedUnknownTestResultInfo: UnknownTestResultInfo?

    private let dateProvider: DateProviding

    private(set) lazy var virologyTestResult: DomainProperty<VirologyStateTestResult?> = {
        $virologyTestingInfo.map { [weak self] virologyTestingInfo in
            guard let self = self,
                let unacknowledgedTestResult = self.getRelevantTestResult(from: virologyTestingInfo)
            else {
                return nil
            }

            let diagnosisSubmissionToken: DiagnosisKeySubmissionToken?
            if let submissionToken = unacknowledgedTestResult.diagnosisKeySubmissionToken {
                diagnosisSubmissionToken = DiagnosisKeySubmissionToken(value: submissionToken)
            } else {
                diagnosisSubmissionToken = nil
            }
            return VirologyStateTestResult(
                testResult: UnacknowledgedTestResult(unacknowledgedTestResult.result),
                testKitType: TestKitType(unacknowledgedTestResult.testKitType),
                endDate: unacknowledgedTestResult.endDate,
                diagnosisKeySubmissionToken: diagnosisSubmissionToken,
                requiresConfirmatoryTest: unacknowledgedTestResult.requiresConfirmatoryTest,
                shouldOfferFollowUpTest: unacknowledgedTestResult.shouldOfferFollowUpTest ?? unacknowledgedTestResult.requiresConfirmatoryTest,
                confirmatoryDayLimit: unacknowledgedTestResult.confirmatoryDayLimit,
                selfReported: false
            )
        }
    }()

    private(set) lazy var recievedUnknownTestResult: DomainProperty<Bool> = {
        $recievedUnknownTestResultInfo.map { $0 != nil }
    }()

    init(store: EncryptedStoring, dateProvider: DateProviding) {
        _virologyTestingInfo = store.encrypted("virology_testing")
        _recievedUnknownTestResultInfo = store.encrypted("unknown_test_result")

        self.dateProvider = dateProvider

        migrate()
    }

    #warning("Delete this migration code one month after a force update")
    private func migrate() {
        if let latestUnacknowledgedTestResult = virologyTestingInfo?.latestUnacknowledgedTestResult {
            let newList: [TestResultInfo] = (virologyTestingInfo?.unacknowledgedTestResults ?? []) + [latestUnacknowledgedTestResult]
            virologyTestingInfo = mutating(virologyTestingInfo) {
                $0?.latestUnacknowledgedTestResult = nil
                $0?.unacknowledgedTestResults = newList
            }
        }

        if let testTokensInfo = virologyTestingInfo?.tokensInfo,
            testTokensInfo.contains(where: { $0.creationDay == nil }) {
            virologyTestingInfo?.tokensInfo = testTokensInfo.map { token in
                VirologyTokensInfo(
                    pollingToken: token.pollingToken,
                    creationDay: token.creationDay ?? dateProvider.currentGregorianDay(timeZone: .current),
                    diagnosisKeySubmissionToken: token.diagnosisKeySubmissionToken
                )
            }
        }
    }

    var didReceiveUnknownTestResult: Bool {
        get {
            recievedUnknownTestResultInfo != nil
        }
        set {
            recievedUnknownTestResultInfo = newValue ? UnknownTestResultInfo() : nil
        }
    }

    var virologyTestTokens: [VirologyTestTokens]? {
        if let virologyTestingInfo = virologyTestingInfo,
            let tokensInfo = virologyTestingInfo.tokensInfo {
            return tokensInfo.map { testInfo in
                guard let tokenCreationDay = testInfo.creationDay else {
                    preconditionFailure("Token creation day not set for migrated token.")
                }
                return VirologyTestTokens(
                    pollingToken: PollingToken(value: testInfo.pollingToken),
                    creationDay: tokenCreationDay,
                    diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: testInfo.diagnosisKeySubmissionToken)
                )
            }
        } else {
            return nil
        }
    }

    func saveTest(
        pollingToken: PollingToken,
        diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken
    ) {
        let virologyTokens = VirologyTokensInfo(
            pollingToken: pollingToken.value,
            creationDay: dateProvider.currentGregorianDay(timeZone: .current),
            diagnosisKeySubmissionToken: diagnosisKeySubmissionToken.value
        )
        var newList: [VirologyTokensInfo] = virologyTestingInfo?.tokensInfo ?? []
        newList.append(virologyTokens)

        virologyTestingInfo = VirologyTestingInfo(
            tokensInfo: newList,
            unacknowledgedTestResults: virologyTestingInfo?.unacknowledgedTestResults
        )
    }

    func saveResult(
        virologyTestResult: VirologyTestResult,
        diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken?,
        requiresConfirmatoryTest: Bool,
        shouldOfferFollowUpTest: Bool,
        confirmatoryDayLimit: Int? = nil
    ) {
        let testResultInfo = TestResultInfo(
            result: TestResultInfo.TestResult(virologyTestResult.testResult),
            testKitType: TestResultInfo.TestKitType(virologyTestResult.testKitType),
            endDate: virologyTestResult.endDate,
            diagnosisKeySubmissionToken: diagnosisKeySubmissionToken?.value,
            requiresConfirmatoryTest: requiresConfirmatoryTest,
            shouldOfferFollowUpTest: shouldOfferFollowUpTest,
            confirmatoryDayLimit: confirmatoryDayLimit
        )

        let newList: [TestResultInfo] = (virologyTestingInfo?.unacknowledgedTestResults ?? []) + [testResultInfo]

        virologyTestingInfo = VirologyTestingInfo(
            tokensInfo: virologyTestingInfo?.tokensInfo,
            unacknowledgedTestResults: newList
        )
    }

    func removeTestTokens(_ tokens: VirologyTestTokens) {
        let virologyTokensInfo = VirologyTokensInfo(
            pollingToken: tokens.pollingToken.value,
            creationDay: tokens.creationDay,
            diagnosisKeySubmissionToken: tokens.diagnosisKeySubmissionToken.value
        )

        var newList: [VirologyTokensInfo] = virologyTestingInfo?.tokensInfo ?? []
        newList = newList.filter { $0 != virologyTokensInfo }

        virologyTestingInfo = VirologyTestingInfo(
            tokensInfo: newList,
            unacknowledgedTestResults: virologyTestingInfo?.unacknowledgedTestResults
        )
    }

    func remove(testResult: VirologyStateTestResult) {
        if let unacknowledgedTestResults = virologyTestingInfo?.unacknowledgedTestResults {
            let newList = unacknowledgedTestResults.filter { !testEquality(savedResult: $0, testResult: testResult) }

            virologyTestingInfo = VirologyTestingInfo(
                tokensInfo: virologyTestingInfo?.tokensInfo,
                unacknowledgedTestResults: newList
            )
        }
    }

    private func testEquality(savedResult: TestResultInfo, testResult: VirologyStateTestResult) -> Bool {
        return UnacknowledgedTestResult(savedResult.result) == testResult.testResult &&
            savedResult.endDate == testResult.endDate &&
            savedResult.diagnosisKeySubmissionToken == testResult.diagnosisKeySubmissionToken?.value
    }

    func delete() {
        virologyTestingInfo = nil
        recievedUnknownTestResultInfo = nil
    }

    func deleteExpiredData() {
        virologyTestingInfo?.unacknowledgedTestResults = nil
        recievedUnknownTestResultInfo = nil
    }

    private func getRelevantTestResult(from virologyTestingInfo: VirologyTestingInfo?) -> TestResultInfo? {
        if let virologyTestingInfo = virologyTestingInfo,
            let unacknowledgedTestResults = virologyTestingInfo.unacknowledgedTestResults {
            if let positive = unacknowledgedTestResults.filter({ $0.result == .positive }).first {
                return positive
            } else if let plod = unacknowledgedTestResults.filter({ $0.result == .plod }).first {
                return plod
            } else if let negative = unacknowledgedTestResults.filter({ $0.result == .negative }).first {
                return negative
            } else if let void = unacknowledgedTestResults.filter({ $0.result == .void }).first {
                return void
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

private extension UnacknowledgedTestResult {

    init(_ testResult: TestResultInfo.TestResult) {
        switch testResult {
        case .positive:
            self = .positive
        case .plod:
            self = .plod
        case .negative:
            self = .negative
        case .void:
            self = .void
        }
    }

}

private extension TestKitType {

    init?(_ result: TestResultInfo.TestKitType?) {
        guard let result = result else { return nil }
        switch result {
        case .labResult:
            self = .labResult
        case .rapidResult:
            self = .rapidResult
        case .rapidSelfReported:
            self = .rapidSelfReported
        }
    }

}
