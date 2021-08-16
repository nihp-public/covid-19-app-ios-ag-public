//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

public class ApplicationServices {
    
    let application: Application
    let exposureNotificationManager: ExposureNotificationManaging
    let userNotificationsManager: UserNotificationManaging
    let processingTaskRequestManager: ProcessingTaskRequestManaging
    let notificationCenter: NotificationCenter
    let distributeClient: HTTPClient
    let apiClient: HTTPClient
    let iTunesClient: HTTPClient
    let cameraManager: CameraManaging
    let encryptedStore: EncryptedStoring
    let cacheStorage: FileStoring
    let venueDecoder: VenueDecoding
    let appInfo: AppInfo
    let postcodeValidator: PostcodeValidating
    let currentDateProvider: DateProviding
    let storeReviewController: StoreReviewControlling
    let riskyPostcodeUpdateIntervalProvider: MinimumUpdateIntervalProviding
    
    public init(
        application: Application,
        exposureNotificationManager: ExposureNotificationManaging,
        userNotificationsManager: UserNotificationManaging,
        processingTaskRequestManager: ProcessingTaskRequestManaging,
        notificationCenter: NotificationCenter,
        distributeClient: HTTPClient,
        apiClient: HTTPClient,
        iTunesClient: HTTPClient,
        cameraManager: CameraManaging,
        encryptedStore: EncryptedStoring,
        cacheStorage: FileStoring,
        venueDecoder: VenueDecoding,
        appInfo: AppInfo,
        postcodeValidator: PostcodeValidating,
        currentDateProvider: DateProviding,
        storeReviewController: StoreReviewControlling,
        riskyPostcodeUpdateIntervalProvider: MinimumUpdateIntervalProviding
    ) {
        self.application = application
        self.exposureNotificationManager = exposureNotificationManager
        self.userNotificationsManager = userNotificationsManager
        self.processingTaskRequestManager = processingTaskRequestManager
        self.notificationCenter = notificationCenter
        self.distributeClient = distributeClient
        self.apiClient = apiClient
        self.iTunesClient = iTunesClient
        self.cameraManager = cameraManager
        self.encryptedStore = encryptedStore
        self.cacheStorage = cacheStorage
        self.venueDecoder = venueDecoder
        self.appInfo = appInfo
        self.postcodeValidator = postcodeValidator
        self.currentDateProvider = currentDateProvider
        self.storeReviewController = storeReviewController
        self.riskyPostcodeUpdateIntervalProvider = riskyPostcodeUpdateIntervalProvider
    }
    
}
