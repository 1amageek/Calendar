//
//  CalendarEvent.swift
//  CalendarEvent
//
//  Created by nori on 2021/09/13.
//

import Foundation
import RecurrenceRulePicker

public enum Period: Codable, Hashable {
    case allday(Date)
    case byTimes(Range<Date>)

    var occurrenceDate: Date {
        switch self {
            case .allday(let date):
                return date
            case .byTimes(let range):
                return range.lowerBound
        }
    }
}

public protocol CalendarEventProtocol: Identifiable, Hashable {

    var id: String { get set }

    var title: String { get set }

    var location: String { get set }

    var timeZone: TimeZone { get set }

    var url: URL? { get set }

    var occurrenceDate: Date { get set }

    var period: Period { get set }

    var recurrenceRules: [RecurrenceRule] { get set }
}

extension CalendarEventProtocol {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(location)
        hasher.combine(timeZone)
        hasher.combine(url)
        hasher.combine(occurrenceDate)
        hasher.combine(period)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension CalendarEventProtocol where Self: TimeRange {

    public var range: Range<Date> {
        switch self.period {
            case .allday(let occurrenceDate):
                let start = occurrenceDate.date(components: [.calendar, .timeZone, .year, .month, .day])
                let end = start.date(byAdding: .day, value: 1)
                return (start..<end)
            case .byTimes(let range): return range
        }
    }
}
