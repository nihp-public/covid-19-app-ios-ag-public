//
// Copyright © 2020 NHSX. All rights reserved.
//

import CryptoKit
import Foundation

public struct HTTPResponseTimestampedSignatureVerifier: HTTPResponseVerifying {

    public var key: P256.Signing.PublicKey
    public var id: String

    public init(key: P256.Signing.PublicKey, id: String) {
        self.key = key
        self.id = id
    }

    public func prepare(_ request: HTTPRequest) -> HTTPRequest {
        request
    }

    public func canAccept(_ response: HTTPResponse, for request: HTTPRequest) -> Bool {
        guard
            let signatureHeader = response.headers.signatureHeader,
            let signatureDate = response.headers.signatureDate,
            signatureHeader.keyId == id
        else { return false }

        let digest = SHA256.hash(from: [
            "\(signatureDate):".data(using: .utf8)!,
            response.body.content,
        ])
        return key.isValidSignature(signatureHeader.signature, for: digest)

    }

}
