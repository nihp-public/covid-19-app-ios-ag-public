//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

public struct CheckIn: Codable, Equatable, Identifiable {
    // var as modified from CheckInsStore, should probably make let
    var isRisky: Bool
    var circuitBreakerApproval: CircuitBreakerApproval
    var venueMessageType: RiskyVenue.MessageType?
    
    // var as checkedOut is modified from CheckInsStore, should probably make let
    public var venueId: String
    public var venueName: String
    public var venuePostcode: String?
    public var checkedIn: UTCHour
    public var checkedOut: UTCHour
    public var id: String
    
    var checkedInInterval: DateInterval {
        DateInterval(start: checkedIn.date, end: checkedOut.date)
    }
    
    private init(
        venueId: String,
        venueName: String,
        venuePostcode: String?,
        checkedIn: UTCHour,
        checkedOut: UTCHour,
        isRisky: Bool,
        venueMessageType: RiskyVenue.MessageType?
    ) {
        self.venueId = venueId
        self.venueName = venueName
        self.venuePostcode = venuePostcode
        self.venueMessageType = venueMessageType
        self.checkedIn = checkedIn
        self.checkedOut = checkedOut
        self.isRisky = isRisky
        id = UUID().uuidString
        circuitBreakerApproval = .pending
    }
    
    init(venue: Venue, checkedIn: UTCHour, checkedOut: UTCHour, isRisky: Bool, venueMessageType: RiskyVenue.MessageType? = nil) {
        self.init(
            venueId: venue.id,
            venueName: venue.organisation,
            venuePostcode: venue.postcode,
            checkedIn: checkedIn,
            checkedOut: checkedOut,
            isRisky: isRisky,
            venueMessageType: venueMessageType
        )
    }
    
    private enum CodingKeys: String, CodingKey {
        case isRisky
        case circuitBreakerApproval
        case venueId
        case venueName
        case venuePostcode
        case checkedIn
        case checkedOut
        case id
        case venueMessageType
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isRisky = try container.decode(Bool.self, forKey: .isRisky)
        circuitBreakerApproval = try container.decode(CircuitBreakerApproval.self, forKey: .circuitBreakerApproval)
        venueId = try container.decode(String.self, forKey: .venueId)
        venueName = try container.decode(String.self, forKey: .venueName)
        venuePostcode = try container.decodeIfPresent(String.self, forKey: .venuePostcode)
        checkedIn = try container.decode(UTCHour.self, forKey: .checkedIn)
        checkedOut = try container.decode(UTCHour.self, forKey: .checkedOut)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        venueMessageType = try container.decodeIfPresent(RiskyVenue.MessageType.self, forKey: .venueMessageType)
    }
    
}

extension CheckIn {
    init(venue: Venue, checkedInDate: Date, untilEndOfDayIn: Calendar = .current, isRisky: Bool = false, venueMessageType: RiskyVenue.MessageType? = nil) {
        let checkedIn = UTCHour(roundedDownToQuarter: checkedInDate)
        let minimumCheckout = UTCHour(roundedUpToQuarter: checkedInDate)
        let checkout = UTCHour(roundedDownToQuarter: LocalDay(date: checkedInDate, timeZone: untilEndOfDayIn.timeZone).advanced(by: 1).startOfDay)
        self.init(
            venue: venue,
            checkedIn: checkedIn,
            checkedOut: max(minimumCheckout, checkout),
            isRisky: isRisky,
            venueMessageType: venueMessageType
        )
    }
}

extension CheckIn {
    func isMoreRecentAndSevere(than other: CheckIn) -> Bool {
        let selfSeverity = venueMessageType?.severity ?? .level0
        let otherSeverity = other.venueMessageType?.severity ?? .level0
        if selfSeverity != otherSeverity {
            return selfSeverity > otherSeverity
        } else {
            return checkedIn.date > other.checkedIn.date
        }
    }
}
