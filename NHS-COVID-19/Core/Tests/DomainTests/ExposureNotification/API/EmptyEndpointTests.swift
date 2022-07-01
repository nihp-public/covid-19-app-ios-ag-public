//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class EmptyEndpointTests: XCTestCase {

    func testEncoding() throws {

        let emptyEndpoint = EmptyEndpoint()
        let trafficObfuscator: TrafficObfuscator = .circuitBreaker

        let actual = try emptyEndpoint.request(for: trafficObfuscator).withCanonicalJSONBody()

        let expected = HTTPRequest.get("/submission/empty-submission-v2")

        TS.assert(actual, equals: expected)
    }
}
