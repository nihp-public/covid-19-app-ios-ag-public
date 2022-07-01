//
// Copyright © 2021 DHSC. All rights reserved.
//

import BackgroundTasks
import Common
import Domain
import ExposureNotification
import Foundation
import Logging
import UIKit

extension ApplicationServices {

    private static let logger = Logger(label: "ApplicationServices")

    @available(iOSApplicationExtension, unavailable)
    public convenience init(
        standardServicesFor environment: Environment,
        dateProvider: DateProviding = DateProvider(),
        riskyPostcodeUpdateIntervalProvider: MinimumUpdateIntervalProviding = DefaultMinimumUpdateIntervalProvider(),
        exposureNotificationManager: ExposureNotificationManaging = ENManager(),
        cameraManager: CameraManaging? = nil,
        venueDecoder: VenueDecoding? = nil,
        application: Application = SystemApplication()
    ) {
        Self.logger.debug("initialising", metadata: .describing(environment.identifier))
        self.init(
            application: application,
            exposureNotificationManager: exposureNotificationManager,
            userNotificationsManager: UserNotificationManager(),
            processingTaskRequestManager: ProcessingTaskRequestManager(
                identifier: environment.backgroundTaskIdentifier,
                scheduler: BGTaskScheduler.shared
            ),
            notificationCenter: .default,
            distributeClient: environment.distributionClient,
            apiClient: environment.apiClient,
            iTunesClient: environment.iTunesClient,
            cameraManager: cameraManager ?? CameraManager(),
            encryptedStore: EncryptedStore(service: environment.identifier),
            cacheStorage: FileStorage(forCachesOf: environment.identifier),
            venueDecoder: venueDecoder ?? environment.venueDecoder,
            appInfo: environment.appInfo,
            postcodeValidator: PostcodeValidator(),
            currentDateProvider: dateProvider,
            storeReviewController: StoreReviewController(),
            riskyPostcodeUpdateIntervalProvider: riskyPostcodeUpdateIntervalProvider
        )
    }

}
