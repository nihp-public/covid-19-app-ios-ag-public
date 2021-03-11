//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

enum LogicalState: Equatable {
    
    enum ExposureDetectionDisabledReason {
        case authorizationDenied
        case bluetoothDisabled
    }
    
    case starting
    case appUnavailable(AppAvailabilityLogicalState.UnavailabilityReason, descriptions: LocaleString)
    case recommendingUpdate(AppAvailabilityLogicalState.RecommendationReason, titles: LocaleString, descriptions: LocaleString)
    case failedToStart
    case onboarding
    case postcodeAndLocalAuthorityRequired
    case localAuthorityRequired
    case policyAcceptanceRequired
    case authorizationRequired
    case canNotRunExposureNotification(ExposureDetectionDisabledReason)
    case fullyOnboarded
}

public struct RunningAppContext {
    public var checkInContext: CheckInContext?
    public var postcodeInfo: DomainProperty<(postcode: Postcode, localAuthority: LocalAuthority?, risk: DomainProperty<RiskyPostcodeEndpointManager.PostcodeRisk?>)?>
    public var country: DomainProperty<Country>
    public var openSettings: () -> Void
    public var openURL: (URL) -> Void
    public var selfDiagnosisManager: SelfDiagnosisManaging
    public var isolationState: DomainProperty<IsolationState>
    public var testInfo: DomainProperty<IndexCaseInfo.TestInfo?>
    public var isolationAcknowledgementState: AnyPublisher<IsolationAcknowledgementState, Never>
    public var exposureNotificationStateController: ExposureNotificationStateControlling
    public var virologyTestingManager: VirologyTestingManaging
    public var testResultAcknowledgementState: AnyPublisher<TestResultAcknowledgementState, Never>
    public var symptomsOnsetAndExposureDetailsProvider: SymptomsOnsetDateAndExposureDetailsProviding
    public var deleteAllData: () -> Void
    public var deleteCheckIn: (String) -> Void
    public var riskyCheckInsAcknowledgementState: AnyPublisher<RiskyCheckInsAcknowledgementState, Never>
    public var currentDateProvider: DateProviding
    public var exposureNotificationReminder: ExposureNotificationReminder
    public var appReviewPresenter: AppReviewPresenting
    public var getLocalAuthorities: GetLocalAuthorities
    public var storeLocalAuthorities: StoreLocalAuthorities
    public var isolationPaymentState: DomainProperty<IsolationPaymentState>
    public var currentLocaleConfiguration: DomainProperty<LocaleConfiguration>
    public var storeNewLanguage: (_ localeConfiguration: LocaleConfiguration) -> Void
    public var shouldShowDailyContactTestingInformFeature: () -> Bool
    public var dailyContactTestingEarlyTerminationSupport: () -> DailyContactTestingEarlyIsolationTerminationSupport
}

// FIXME: Move to a more suitable place
public enum DailyContactTestingEarlyIsolationTerminationSupport {
    case enabled(optOutOfIsolation: () -> Void)
    case disabled
}

public typealias GetLocalAuthorities = (_ postcode: Postcode) -> Result<Set<LocalAuthority>, PostcodeValidationError>
public typealias StoreLocalAuthorities = (_ postcode: Postcode, _ localAuthority: LocalAuthority) -> Result<Void, LocalAuthorityUnsupportedCountryError>

public enum ApplicationState {
    
    public enum AppUnavailabilityReason {
        /// OS version is too old for this app
        case iOSTooOld(descriptions: LocaleString)
        
        /// App version is too old
        case appTooOld(updateAvailable: Bool, descriptions: LocaleString)
    }
    
    public enum RecommendedUpdateReason {
        /// Recommended App update is availbale
        case newRecommendedAppUpdate(title: LocaleString, descriptions: LocaleString, dismissAction: () -> Void)
        
        /// Recommended iOS update is available
        case newRecommendedOSupdate(title: LocaleString, descriptions: LocaleString, dismissAction: () -> Void)
    }
    
    public enum ExposureDetectionDisabledReason {
        /// Authorization is denied by the user.
        case authorizationDenied(openSettings: () -> Void)
        
        /// Bluetooth is disabled.
        case bluetoothDisabled
    }
    
    /// Application is starting. This should normally be very quick.
    case starting
    
    /// Application is disabled.
    case appUnavailable(AppUnavailabilityReason)
    
    /// RecommendedUpdate
    case recommendedUpdate(RecommendedUpdateReason)
    
    /// Application can’t finish starting. There’s no standard way for the user to recover from this.
    ///
    /// This can happen, for example, if certain authorization is restricted, or if another app is using ExposureNotification API.
    case failedToStart(openURL: (URL) -> Void)
    
    /// Application needs to show onboarding.
    case onboarding(complete: () -> Void, openURL: (URL) -> Void)
    
    /// Application requires onboarding.
    case authorizationRequired(requestPermissions: () -> Void, country: DomainProperty<Country>)
    
    /// Application is set up, but can not run exposure detection. See `reason`.
    ///
    /// The user can help the app recover from this.
    case canNotRunExposureNotification(reason: ExposureDetectionDisabledReason, country: Country)
    
    /// Application requires postcode and local authority
    case postcodeAndLocalAuthorityRequired(
        openURL: (URL) -> Void,
        getLocalAuthorities: GetLocalAuthorities,
        storeLocalAuthority: StoreLocalAuthorities
    )
    
    /// Application already has a postcode and requires a local Authority
    case localAuthorityRequired(
        postcode: Postcode,
        localAuthorities: Set<LocalAuthority>,
        openURL: (URL) -> Void,
        storeLocalAuthority: StoreLocalAuthorities
    )
    
    /// Application requires user acknowledge/acceptance of new policies
    case policyAcceptanceRequired(saveCurrentVersion: () -> Void, openURL: (URL) -> Void)
    
    /// Application is properly set up and is running exposure detection
    case runningExposureNotification(RunningAppContext)
}
