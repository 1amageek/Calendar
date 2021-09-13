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

    @Published public var selectedDate: Date

    var today: Date

    var calendar: Foundation.Calendar

    var timeZone: TimeZone

    public init(displayMode: CalendarDisplayMode = .year, today: Date = Date(), calendar: Foundation.Calendar = Foundation.Calendar(identifier: .gregorian), timeZone: TimeZone = TimeZone.current) {
        self.today = today
        self.calendar = calendar
        self.timeZone = timeZone
        self._displayMode = Published(initialValue: displayMode)
        self._selectedDate = Published(initialValue: today)
    }
}

extension Foundation.Calendar {
    func setTime(components: DateComponents, date: Date) -> Date {
        var components = components
        let hour = self.component(.hour, from: date)
        let minute = self.component(.minute, from: date)
        let second = self.component(.second, from: date)
        components.hour = hour
        components.minute = minute
        components.second = second
        return self.date(from: components)!
    }
}
