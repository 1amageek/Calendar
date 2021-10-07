//
//  Store.swift
//  Store
//
//  Created by nori on 2021/09/03.
//

import Foundation
import CoreGraphics

public final class Store: ObservableObject {

    @Published public var displayMode: CalendarDisplayMode
    {
        didSet {
            self.displayedDate = Self.displayedDate(self.displayedDate, displayMode: displayMode)
        }
    }

    @Published public var displayedDate: Date

    @Published public var selectedDates: [Range<Date>]

    public var displayedRange: Range<Date> {
        switch displayMode {
            case .day:
                let startDate = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: displayedDate).date!
                let endDate = startDate + 1.days
                return startDate..<endDate
            case .week:
                let startDate = calendar.dateComponents([.calendar, .timeZone, .yearForWeekOfYear, .weekOfYear], from: displayedDate).date!
                let endDate = startDate + 1.weeks
                return startDate..<endDate
            case .month:
                let startDate = calendar.dateComponents([.calendar, .timeZone, .year, .month], from: displayedDate).date!
                let endDate = startDate + 1.months
                return startDate..<endDate
            case .year:
                let startDate = calendar.dateComponents([.calendar, .timeZone, .year], from: displayedDate).date!
                let endDate = startDate + 1.years
                return startDate..<endDate
        }
    }

    public var today: Date

    public var headerTitle: String { titleFormatter.string(from: displayedDate) }

    var calendar: Foundation.Calendar

    var timeZone: TimeZone

    public init(displayMode: CalendarDisplayMode = .year, today: Date = Date(), calendar: Foundation.Calendar = Foundation.Calendar(identifier: .gregorian), timeZone: TimeZone = TimeZone.current) {
        self.today = today
        self.calendar = calendar
        self.timeZone = timeZone
        let displayedDate = Self.displayedDate(today, displayMode: displayMode)
        self._displayMode = Published(initialValue: displayMode)
        self._displayedDate = Published(initialValue: displayedDate)
        self._selectedDates = Published(initialValue: [])
    }

    static func displayedDate(_ date: Date, displayMode: CalendarDisplayMode) -> Date {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        switch displayMode {
            case .day: return calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date).date!
            case .week: return calendar.dateComponents([.calendar, .timeZone, .yearForWeekOfYear, .weekOfYear], from: date).date!
            case .month: return calendar.dateComponents([.calendar, .timeZone, .year, .month], from: date).date!
            case .year: return calendar.dateComponents([.calendar, .timeZone, .year], from: date).date!
        }
    }
}

extension Store {

    var titleFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        switch displayMode {
            case .day:
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYYMd", options: 0, locale: Locale.current)
            case .week:
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYYM", options: 0, locale: Locale.current)
            case .month:
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYYM", options: 0, locale: Locale.current)
            case .year:
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYY", options: 0, locale: Locale.current)
        }
        return dateFormatter
    }

    var dayFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }

    var monthFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "MMM"
        return dateFormatter
    }

    var weekdayFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEE", options: 0, locale: Locale.current)
        return dateFormatter
    }
}
