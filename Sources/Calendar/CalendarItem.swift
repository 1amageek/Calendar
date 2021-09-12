//
//  CalendarItem.swift
//  CalendarItem
//
//  Created by nori on 2021/09/06.
//

import Foundation
import RecurrenceRulePicker

public struct CalendarItem: Identifiable, Hashable {

    public enum Period: Hashable {
        case allday(Date)
        case byTime(Range<Date>)

        var occurrenceDate: Date {
            switch self {
                case .allday(let date):
                    return date
                case .byTime(let range):
                    return range.lowerBound
            }
        }
    }

    public var id: String
    public var title: String = ""
    public var occurrenceDate: Date
    public var period: Period
    public var timeZone: TimeZone
    public var recurrenceRules: [RecurrenceRule]
    public init(id: String, title: String = "", period: Period, timeZone: TimeZone = TimeZone.current, recurrenceRules: [RecurrenceRule] = []) {
        self.id = id
        self.title = title
        self.occurrenceDate = period.occurrenceDate
        self.period = period
        self.timeZone = timeZone
        self.recurrenceRules = recurrenceRules
    }


    public func duplicate(period: Period) -> CalendarItem {
        CalendarItem(id: id, title: title, period: period, timeZone: timeZone, recurrenceRules: [])
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(occurrenceDate)
        hasher.combine(period)
        hasher.combine(timeZone)
    }

    public static func == (lhs: CalendarItem, rhs: CalendarItem) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
extension CalendarItem: TimeRange {

    public var range: Range<Date> {
        switch self.period {
            case .allday(let occurrenceDate):
                let start = occurrenceDate.date(components: [.calendar, .timeZone, .year, .month, .day])
                let end = start.date(byAdding: .day, value: 1)
                return (start..<end)
            case .byTime(let range): return range
        }
    }
}
