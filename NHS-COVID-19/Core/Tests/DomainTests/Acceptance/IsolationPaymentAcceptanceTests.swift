//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import TestSupport
import XCTest
@testable import Domain
@testable import Integration
@testable import Scenarios

@available(iOS 13.7, *)
class IsolationPaymentAcceptanceTests: AcceptanceTestCase {
    private var cancellables = [AnyCancellable]()

    private let startDate = GregorianDay(year: 2020, month: 1, day: 1).startDate(in: .utc)
    private let endDate = GregorianDay(year: 2020, month: 1, day: 15).startDate(in: .utc)
    private var riskyContact: RiskyContact!

    override func setUp() {
        $instance.exposureNotificationManager = MockWindowsExposureNotificationManager()
        currentDateProvider.setDate(startDate)
        try! completeRunning()

        riskyContact = RiskyContact(configuration: $instance)
    }

    func testIsolationPaymentStateWithAPIResponse() throws {
        apiClient.response(for: "/isolation-payment/ipc-token/create", response: .success(.ok(with: .json("""
        {
            "ipcToken": "\(UUID().uuidString)",
            "isEnabled": true
        }
        """))))
        let currentState = try context().isolationPaymentState
        guard case .disabled = currentState.currentValue else {
            throw TestError("Unexpected state \(currentState.currentValue)")
        }

        // Mock a Risky Contact and call Background Task
        riskyContact.trigger(exposureDate: currentDateProvider.currentDate) {
            self.coordinator.performBackgroundTask(task: NoOpBackgroundTask())
        }

        // Assert that now we have enabled state
        guard case .enabled = currentState.currentValue else {
            throw TestError("Unexpected state \(currentState)")
        }

        // Advance Risky Conact to end of isolation
        currentDateProvider.setDate(endDate)

        // Assert that we are back to disabled
        guard case .disabled = currentState.currentValue else {
            throw TestError("Unexpected state \(currentState.currentValue)")
        }
    }

    func testIsolationPaymentStateIsClearedAfterDeletingAllData() throws {
        apiClient.response(for: "/isolation-payment/ipc-token/create", response: .success(.ok(with: .json("""
        {
            "ipcToken": "\(UUID().uuidString)",
            "isEnabled": true
        }
        """))))

        let currentState = try context().isolationPaymentState
        guard case .disabled = currentState.currentValue else {
            throw TestError("Unexpected state \(currentState.currentValue)")
        }

        // Mock a Risky Contact and call Background Task
        riskyContact.trigger(exposureDate: currentDateProvider.currentDate) {
            self.coordinator.performBackgroundTask(task: NoOpBackgroundTask())
        }

        // Assert that now we have enabled state
        guard case .enabled = currentState.currentValue else {
            throw TestError("Unexpected state \(currentState)")
        }

        XCTAssert($instance.encryptedStore.dataEncryptor("isolation_payment_store").hasValue)

        // Delete all data
        try context().deleteAllData()

        XCTAssertFalse($instance.encryptedStore.dataEncryptor("isolation_payment_store").hasValue)

    }

    func testIsolationPaymentIsReEvaluatedOnNewIsolationAfterDeletingAllData() throws {
        apiClient.response(for: "/isolation-payment/ipc-token/create", response: .success(.ok(with: .json("""
        {
            "ipcToken": "\(UUID().uuidString)",
            "isEnabled": true
        }
        """))))

        var currentState = try context().isolationPaymentState
        guard case .disabled = currentState.currentValue else {
            throw TestError("Unexpected state \(currentState.currentValue)")
        }

        // Mock a Risky Contact and call Background Task
        riskyContact.trigger(exposureDate: currentDateProvider.currentDate) {
            self.coordinator.performBackgroundTask(task: NoOpBackgroundTask())
        }

        // Assert that now we have enabled state
        guard case .enabled = currentState.currentValue else {
            throw TestError("Unexpected state \(currentState)")
        }

        // Delete all data
        try context().deleteAllData()

        // Complete onboarding again
        try completeReOnboarding()

        // get the new state. It _could_ have changed during de/re-onboarding.
        currentState = try context().isolationPaymentState
        guard case .noNeedToIsolate = try context().isolationState.currentValue else {
            throw TestError("Expected not to be isolating")
        }

        apiClient.response(for: "/isolation-payment/ipc-token/create", response: .success(.ok(with: .json("""
        {
            "isEnabled": false
        }
        """))))

        // Mock a Risky Contact and call Background Task
        riskyContact.trigger(exposureDate: currentDateProvider.currentDate) {
            self.coordinator.performBackgroundTask(task: NoOpBackgroundTask())
        }

        guard case .disabled = try context().isolationPaymentState.currentValue else {
            throw TestError("Unexpected state \(currentState.currentValue)")
        }

    }

    func testIsolationPaymentStateWithNoAPIResponse() throws {
        let currentState = try context().isolationPaymentState
        guard case .disabled = currentState.currentValue else {
            throw TestError("Unexpected state \(currentState.currentValue)")
        }

        // Mock a Risky Contact and call Background Task
        riskyContact.trigger(exposureDate: currentDateProvider.currentDate) {
            self.coordinator.performBackgroundTask(task: NoOpBackgroundTask())
        }

        // Assert that we are still disabled
        guard case .disabled = currentState.currentValue else {
            throw TestError("Unexpected state \(currentState.currentValue)")
        }
    }
}
