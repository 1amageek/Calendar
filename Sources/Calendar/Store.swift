//
//  Store.swift
//  Store
//
//  Created by nori on 2021/09/03.
//

import Foundation
import CoreGraphics
import SwiftDate

public final class Store: ObservableObject {

    @Published public var displayMode: CalendarDisplayMode {
        didSet {
            self.displayedDate = Self.displayedDate(self.selectedDate, displayMode: displayMode)
        }
    }

    @Published public var displayedDate: Date

    @Published public var selectedDate: Date

    public var displayedRange: Range<Date> {
        switch displayMode {
            case .day:
                let startDate = displayedDate.dateAtStartOf(.day)
                let endDate = startDate + 1.days
                return startDate..<endDate
            case .week:
                let startDate = displayedDate.dateAtStartOf(.weekOfYear)
                let endDate = startDate + 1.weeks
                return startDate..<endDate
            case .month:
                let startDate = displayedDate.dateAtStartOf(.month)
                let endDate = startDate + 1.months
                return startDate..<endDate
            case .year:
                let startDate = displayedDate.dateAtStartOf(.year)
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
        self._selectedDate = Published(initialValue: today)
    }

    static func displayedDate(_ date: Date, displayMode: CalendarDisplayMode) -> Date {
        switch displayMode {
            case .day: return date.dateAtStartOf(.day)
            case .week: return date.dateAtStartOf(.weekOfYear)
            case .month: return date.dateAtStartOf(.month)
            case .year: return date.dateAtStartOf(.year)
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
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }

    var weekdayFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEEE", options: 0, locale: Locale.current)
        return dateFormatter
    }
}
