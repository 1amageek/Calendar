//
//  Store.swift
//  Store
//
//  Created by nori on 2021/09/03.
//

import Foundation
import CoreGraphics
import SwiftUI

public final class Store: ObservableObject {

    @Published public var displayMode: CalendarDisplayMode

    @Published public var displayedDate: Date

    @Published public var selectedDates: [Range<Date>]

    public var today: Date

    public var headerTitle: String { titleFormatter.string(from: displayedDate) }

    public var calendar: Foundation.Calendar

    public var timeZone: TimeZone

    var forYearScrollToTodayAction: (() -> Void)!

    var forMonthScrollToTodayAction: (() -> Void)!

    var forWeekScrollToTodayAction: (() -> Void)!

    public init(
        displayMode: CalendarDisplayMode = .year,
        today: Date = Date(),
        calendar: Foundation.Calendar = Foundation.Calendar.autoupdatingCurrent,
        timeZone: TimeZone = TimeZone.current
    ) {
        self.today = today
        self.calendar = calendar
        self.timeZone = timeZone
        let displayedDate = Self.displayedDate(today, displayMode: displayMode, calendar: calendar)
        self._displayMode = Published(initialValue: displayMode)
        self._displayedDate = Published(initialValue: displayedDate)
        self._selectedDates = Published(initialValue: [])
    }

    public func scrollToToday() {
        withAnimation {
            switch displayMode {
                case .day: break
                case .week: forWeekScrollToTodayAction()
                case .month: forMonthScrollToTodayAction()
                case .year: forYearScrollToTodayAction()
            }
        }
    }

}

extension Store {

    static func displayedDate(_ date: Date, displayMode: CalendarDisplayMode, calendar: Foundation.Calendar) -> Date {
        switch displayMode {
            case .day: return calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date).date!
            case .week: return calendar.dateComponents([.calendar, .timeZone, .yearForWeekOfYear, .weekOfYear], from: date).date!
            case .month: return calendar.dateComponents([.calendar, .timeZone, .year, .month], from: date).date!
            case .year: return calendar.dateComponents([.calendar, .timeZone, .year], from: date).date!
        }
    }

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

    var titleFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        switch displayMode {
            case .day:
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: .current)
            case .week:
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMM", options: 0, locale: .current)
            case .month:
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMM", options: 0, locale: .current)
            case .year:
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "y", options: 0, locale: .current)
        }
        return dateFormatter
    }

    var dayFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }

    var dayLocalFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "d", options: 0, locale: .current)
        return dateFormatter
    }

    var monthFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM", options: 0, locale: .current)
        return dateFormatter
    }

    var weekdayFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEE", options: 0, locale: .current)
        return dateFormatter
    }
}
