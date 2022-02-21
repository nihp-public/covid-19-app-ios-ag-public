//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct VirologyTestResultsHandler: RequestHandler {
    var paths = ["/virology-test/v2/results"]
    
    var dataProvider: MockDataProvider
    
    var response: Result<HTTPResponse, HTTPRequestError> {
        let daysAgo = dataProvider.testResultEndDateDaysAgo
        let date = GregorianDay.today.advanced(by: -daysAgo).startDate(in: .utc)
        let dateString = ISO8601DateFormatter().string(from: date)
        let testResult = MockDataProvider.testResults[dataProvider.receivedTestResult]
        let testKit = MockDataProvider.testKitType[dataProvider.testKitType]
        let diagnosisKeySubmissionSupported = dataProvider.keySubmissionSupported
        let requiresConfirmatoryTest = dataProvider.requiresConfirmatoryTest
        let confirmatoryDayLimit = dataProvider.confirmatoryDayLimit
        let shouldOfferFollowUpTest = dataProvider.shouldOfferFollowUpTest
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
        "testEndDate": "\#(dateString)",
        "testResult": "\#(testResult)",
        "testKit": "\#(testKit)",
        "diagnosisKeySubmissionSupported": \#(diagnosisKeySubmissionSupported),
        "requiresConfirmatoryTest": \#(requiresConfirmatoryTest),
        "shouldOfferFollowUpTest": \#(shouldOfferFollowUpTest),
        \#(value(named: "confirmatoryDayLimit", content: confirmatoryDayLimit))
        }
        """#))
        return Result.success(response)
    }
}
