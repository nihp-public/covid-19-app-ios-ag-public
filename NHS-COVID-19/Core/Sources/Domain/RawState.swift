//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

struct RawState: Equatable {
    var appAvailability: AppAvailabilityMetadata
    var completedOnboardingForCurrentSession: Bool
    var exposureState: ExposureNotificationStateController.CombinedState
    var userNotificationsStatus: UserNotificationsStateController.AuthorizationStatus
    var postcodeState: PostcodeStoreState
    var shouldRecommendUpdate: Bool
    var shouldShowPolicyUpdate: Bool
    
    var logicalState: LogicalState {
        let logicalStateIgnoringOnboarding = self.logicalStateIgnoringOnboarding
        switch logicalStateIgnoringOnboarding {
        case .postcodeAndLocalAuthorityRequired where !completedOnboardingForCurrentSession:
            // Show onboarding just before postcode
            return .onboarding
        default:
            return logicalStateIgnoringOnboarding
        }
    }
    
    private var logicalStateIgnoringOnboarding: LogicalState {
        switch appAvailability.state {
        case .available:
            return postAvailabilityLogicalState
        case .unavailable(let reason):
            return .appUnavailable(reason, descriptions: appAvailability.descriptions)
        case .recommending(let reason) where shouldRecommendUpdate:
            return .recommendingUpdate(reason, titles: appAvailability.titles, descriptions: appAvailability.descriptions)
        case .recommending:
            return postAvailabilityLogicalState
        }
    }
    
    private var postAvailabilityLogicalState: LogicalState {
        switch exposureState.activationState {
        case .inactive, .activating:
            return .starting
        case .activationFailed:
            return .failedToStart
        case .activated:
            return postActivationState
        }
    }
    
    private var authorizationErrorState: LogicalState? {
        switch exposureState.authorizationState {
        case .unknown, .authorized:
            return nil
        case .restricted:
            return .failedToStart
        case .notAuthorized:
            return .canNotRunExposureNotification(.authorizationDenied)
        }
    }
    
    private var postActivationState: LogicalState {
        if let authorizationErrorState = authorizationErrorState {
            return authorizationErrorState
        }
        
        if case .empty = postcodeState {
            return .postcodeAndLocalAuthorityRequired
        }
        
        if case .onlyPostcode = postcodeState {
            return .localAuthorityRequired
        }
        
        guard !shouldShowPolicyUpdate else {
            return .policyAcceptanceRequired
        }
        
        switch exposureState.authorizationState {
        case .unknown:
            return .authorizationRequired
        default:
            return postAuthorizedState
        }
    }
    
    private var postAuthorizedState: LogicalState {
        switch exposureState.exposureNotificationState {
        case .unknown:
            assertionFailure("Encountered unknown state after activation. This should not be possible.")
            return .failedToStart
        case .restricted:
            return .failedToStart
        case .active, .disabled, .bluetoothOff:
            switch userNotificationsStatus {
            case .unknown:
                return .starting
            case .notDetermined:
                return .authorizationRequired
            case .authorized, .denied:
                return .fullyOnboarded
            }
        }
    }
    
}
