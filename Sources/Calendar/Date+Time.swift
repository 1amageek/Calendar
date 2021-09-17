//
//  Date+Time.swift
//  Date+Time
//
//  Created by nori on 2021/09/05.
//

import Foundation

extension Foundation.Calendar {

    public func firstDayOfTheYear(date: Date) -> Date {
        let dateComponents = self.dateComponents([.calendar, .timeZone, .year], from: date)
        return self.date(from: dateComponents)!
    }

    public func firstDayOfTheMonth(date: Date) -> Date {
        let dateComponents = self.dateComponents([.calendar, .timeZone, .year, .month], from: date)
        return self.date(from: dateComponents)!
    }

    public func firstDayOfTheWeek(date: Date) -> Date {
        let dateComponents = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: dateComponents)!
    }

    public func firstDayOfTheDay(date: Date) -> Date {
        let dateComponents = self.dateComponents([.calendar, .timeZone, .year, .month, .day], from: date)
        return self.date(from: dateComponents)!
    }
}

extension Date {

    public var time: Int { Int(floor(self.timeIntervalSince1970)) }

    public var firstDayOfTheYear: Date {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        return calendar.firstDayOfTheYear(date: self)
    }

    public var firstDayOfTheMonth: Date {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        return calendar.firstDayOfTheMonth(date: self)
    }

    public var firstDayOfTheWeek: Date {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        return calendar.firstDayOfTheWeek(date: self)
    }

    public var firstDayOfTheDay: Date {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        return calendar.firstDayOfTheDay(date: self)
    }

    public func date(dayOfWeek: Int) -> Date {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        let dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let startDay = calendar.date(from: dateComponents)!
        return calendar.date(byAdding: .day, value: dayOfWeek, to: startDay)!
    }

    public func date(weekOfYear: Int) -> Date {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        let dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let startDay = calendar.date(from: dateComponents)!
        return calendar.date(byAdding: .weekOfYear, value: weekOfYear, to: startDay)!
    }

    public func date(weekOfMonth: Int) -> Date {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        let dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let startDay = calendar.date(from: dateComponents)!
        return calendar.date(byAdding: .weekOfMonth, value: weekOfMonth, to: startDay)!
    }

    public func date(byAdding: Foundation.Calendar.Component, value: Int) -> Date {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        return calendar.date(byAdding: byAdding, value: value, to: self)!
    }

    public func date(components: Set<Foundation.Calendar.Component>) -> Date {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        let dateComponents = calendar.dateComponents(components, from: self)
        return calendar.date(from: dateComponents)!
    }

    public var weekday: Int {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        return calendar.component(.weekday, from: self)
    }

    public var day: Int {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        return calendar.component(.day, from: self)
    }

    public var month: Int {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        return calendar.component(.month, from: self)
    }

    public var year: Int {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        return calendar.component(.year, from: self)
    }
}

extension Range where Bound == Date {
    public var time: Range<Int> { self.lowerBound.time..<self.upperBound.time }
}

extension Int {
    public var date: Date { Date(timeIntervalSince1970: TimeInterval(self)) }
}

