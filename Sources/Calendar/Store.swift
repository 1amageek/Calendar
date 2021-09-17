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

    @Published var displayedDate: Date

    @Published public var selectedDate: Date

    public var displayedRange: Range<Date> {
        switch displayMode {
            case .day:
                let startDate = displayedDate.firstDayOfTheDay
                let endDate = startDate.date(byAdding: .day, value: 1)
                return startDate..<endDate
            case .week:
                let startDate = displayedDate.firstDayOfTheWeek
                let endDate = startDate.date(byAdding: .day, value: 7)
                return startDate..<endDate
            case .month:
                let startDate = displayedDate.firstDayOfTheMonth
                let endDate = startDate.date(byAdding: .month, value: 1)
                return startDate..<endDate
            case .year:
                let startDate = displayedDate.firstDayOfTheYear
                let endDate = startDate.date(byAdding: .year, value: 1)
                return startDate..<endDate
        }
    }

    public var today: Date

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
            case .day: return date.firstDayOfTheDay
            case .week: return date.firstDayOfTheWeek
            case .month: return date.firstDayOfTheMonth
            case .year: return date.firstDayOfTheYear
        }
    }
}
