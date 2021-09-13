//
//  EventRepeatable.swift
//  EventRepeatable
//
//  Created by nori on 2021/09/13.
//

import Foundation
import RecurrenceRule

public protocol EventRepeatable: TimeRange {

    var period: Period { get }

    var occurrenceDate: Date { get }

    var recurrenceRules: [RecurrenceRule] { get }

    func duplicate(period: Period) -> Self
}

extension EventRepeatable {

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
