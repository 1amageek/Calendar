//
//  Date+Extension.swift
//  
//
//  Created by nori on 2021/10/07.
//

import Foundation

public extension Date {

    var calendar: Foundation.Calendar { Foundation.Calendar.autoupdatingCurrent }

    // MARK: - Date Components
    var year: Int { calendar.component(.year, from: self) }

    /// Represented month
    var month: Int { calendar.component(.month, from: self) }

    /// Day unit of the receiver.
    var day: Int { calendar.component(.day, from: self) }

    /// Day of year unit of the receiver
    var dayOfYear: Int { calendar.ordinality(of: .day, in: .year, for: self)! }

    /// Hour unit of the receiver.
    var hour: Int { calendar.component(.hour, from: self) }

    /// Minute unit of the receiver.
    var minute: Int { calendar.component(.minute, from: self) }

    /// Second unit of the receiver.
    var second: Int { calendar.component(.second, from: self) }

    /// Nanosecond unit of the receiver.
    var nanosecond: Int { calendar.component(.nanosecond, from: self) }

    /// Weekday unit of the receiver.
    /// The weekday units are the numbers 1-N (where for the Gregorian calendar N=7 and 1 is Sunday).
    var weekday: Int { calendar.component(.weekday, from: self) }

    func dateAtStartOf(_ unit: Foundation.Calendar.Component) -> Date {
        let calendar = Foundation.Calendar.autoupdatingCurrent
        switch unit {
            case .era: return calendar.dateComponents([.era], from: self).date!
            case .year: return calendar.dateComponents([.era, .calendar, .timeZone, .year], from: self).date!
            case .month: return calendar.dateComponents([.era, .calendar, .timeZone, .year, .month], from: self).date!
            case .day: return calendar.dateComponents([.era, .calendar, .timeZone, .year, .month, .day], from: self).date!
            case .hour: return calendar.dateComponents([.era, .calendar, .timeZone, .year, .month, .day, .hour], from: self).date!
            case .minute: return calendar.dateComponents([.era, .calendar, .timeZone, .year, .month, .day, .hour, .minute], from: self).date!
            case .second: return calendar.dateComponents([.era, .calendar, .timeZone, .year, .month, .day, .hour, .minute, .second], from: self).date!
            case .weekday: return calendar.dateComponents([.era, .calendar, .timeZone, .year, .month, .day, .hour], from: self).date!
            case .weekdayOrdinal: return calendar.dateComponents([.era, .calendar, .timeZone, .year, .month, .day, .weekdayOrdinal], from: self).date!
            case .quarter: return calendar.dateComponents([.era, .calendar, .timeZone, .year, .month, .quarter], from: self).date!
            case .weekOfMonth: return calendar.dateComponents([.era, .calendar, .timeZone, .year, .month, .day, .hour], from: self).date!
            case .weekOfYear: return calendar.dateComponents([.era, .calendar, .timeZone, .yearForWeekOfYear, .weekOfYear], from: self).date!
            case .yearForWeekOfYear: return calendar.dateComponents([.era, .calendar, .timeZone, .yearForWeekOfYear], from: self).date!
            case .nanosecond: return calendar.dateComponents([.era, .calendar, .timeZone, .year, .month, .day, .hour, .minute, .second, .nanosecond], from: self).date!
            case .calendar: return calendar.dateComponents([.era, .calendar], from: self).date!
            case .timeZone: return calendar.dateComponents([.era, .calendar, .timeZone], from: self).date!
            @unknown default: return self
        }
    }
}
