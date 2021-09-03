//
//  Store.swift
//  Store
//
//  Created by nori on 2021/09/03.
//

import Foundation


final class Store: ObservableObject {

    @Published var year: Int

    @Published var month: Int

    @Published var day: Int

    var today: Date

    var calendar: Foundation.Calendar

    var timeZone: TimeZone

    var dateComponents: DateComponents

    init(today: Date, calendar: Foundation.Calendar = Foundation.Calendar(identifier: .gregorian), timeZone: TimeZone = TimeZone.current) {
        self.today = today
        self.calendar = calendar
        self.timeZone = timeZone
        let year: Int = calendar.component(.year, from: today)
        let month: Int = calendar.component(.month, from: today)
        let day: Int = calendar.component(.day, from: today)
        self._year = Published(initialValue: year)
        self._month = Published(initialValue: month)
        self._day = Published(initialValue: day)
        self.dateComponents = DateComponents(calendar: calendar, timeZone: timeZone, year: year, month: month, day: day)
    }

    var firstWeekdayOfTheMonth: Int {
        let dateComponents = DateComponents(calendar: calendar, timeZone: timeZone, year: year, month: month)
        let firstWeekdayOfTheMonth = calendar.component(.weekday, from: dateComponents.date!)
        return firstWeekdayOfTheMonth
    }

}
