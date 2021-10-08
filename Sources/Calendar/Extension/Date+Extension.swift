//
//  Date+Extension.swift
//  
//
//  Created by nori on 2021/10/07.
//

import Foundation

public extension Date {

    func dateAtStartOf(_ unit: Foundation.Calendar.Component) -> Date {
        let calendar = Foundation.Calendar.current
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
