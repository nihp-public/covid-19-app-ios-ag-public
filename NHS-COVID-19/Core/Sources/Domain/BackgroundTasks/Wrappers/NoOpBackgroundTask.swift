//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct NoOpBackgroundTask: BackgroundJob {
    var identifier = ""
    var expirationHandler: (() -> Void)? {
        get {
            nil
        }
        nonmutating set {}
    }

    func setTaskCompleted(success: Bool) {}
}
